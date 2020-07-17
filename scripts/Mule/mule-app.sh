#!/bin/bash

# mule-app.sh - a deploy script for Mule Applications
#
# Script can:
#  - fetch the application's status (running or not)
#  - deploy
#  - undeploy
#  - redeploy
#

##### Constants

APPLICATION=""
HOST=""
USER="mule"
TARGET_TMP="/home/mule/repository"
APPS_FOLDER=""

##### Functions

display_usage()
{ 
    printf "Usage: mule-app.sh [command] [environment]\n" 
    printf "\n\t[command]: one of 'status', 'deploy', 'undeploy', 'redeploy'.\n"
    printf "\t[environment]: one of 'local', 'tst', 'qas', 'prd'.\n"
    printf "\tRemember: it's always a good idea to 'tail -f' the application's logs when deploying.\n\n"
}

# If less than two arguments supplied, display usage 
if [  $# -le 1 ]; then
    display_usage
    exit 1
fi

get_application_info()
{
    edition_string=$(xmlstarlet sel -N  x="http://www.mulesoft.com/tooling/project" -t -v "/x:mule-project/@runtimeId" mule-project.xml)
    mule_version=$(xmlstarlet sel -N  x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:properties/x:mule.version" pom.xml)
    artifact_id=$(xmlstarlet sel -N  x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:artifactId" pom.xml)
    version=$(xmlstarlet sel -N  x="http://maven.apache.org/POM/4.0.0" -t -v "/x:project/x:version" pom.xml)
}

get_application_info

# Set appliction name and server apps folder
APPLICATION="$artifact_id"
if [ "$edition_string" == "org.mule.tooling.server.3.9.0.ee" ]; then
    APPS_FOLDER="/opt/mule-enterprise-standalone-3.9.0/apps"
elif [ "$edition_string" == "org.mule.tooling.server.3.9.0" ]; then
    APPS_FOLDER="/opt/mule-community-standalone-3.9.0/apps"
else
    printf "Not a recognized edition_string: %s.\n" $edition_string
    exit 1
fi

# Set environment and host
set-env()
{
    ENV="$1"
    if [ "$ENV" == "local" ]; then
	HOST="localhost"
    elif [ "$ENV" == "tst" ]; then
	HOST="dg-qas-esb-01"
    elif [ "$ENV" == "qas" ]; then
	HOST="do-qas-esb-01"
    elif [ "$ENV" == "prd" ]; then 
        HOST="do-prd-esb-02"
    else
        :
    fi
}

find_anchor_file()
{
    # Finding the anchorfile uses a regex. This regex assumes an anchor file of the
    # following form, eg.: borndigital-poller-2.0.0-71dfac4-anchor.txt
    anchor_file=$(ssh $USER@$HOST "ls $APPS_FOLDER | egrep '$APPLICATION-[v]?[0-9\.]*\-?[a-z0-9]{0,8}-anchor\.txt'")
    printf "anchor_file is %s\n" $anchor_file
}

get_latest_artifact()
{
    # Quite sub-optimal: this functions assumes alphabetical order of the
    # artifacts
    latest_artifact=$(ls ./target/$APPLICATION* | tail -n 1)
    latest_artifact_filename=$(basename $latest_artifact)
}

show_latest_artifact()
{
    get_latest_artifact
    printf "Latest artifact is: %s.\n" $latest_artifact
}

copy_artifact_to_apps()
{
    printf "Copying artifact from %s to %s.\n" $TARGET_TMP $APPS_FOLDER
    ssh $USER@$HOST "cp $TARGET_TMP/$latest_artifact_filename $APPS_FOLDER"
}

get_status()
{
    find_anchor_file
    if [ -z "$anchor_file" ]; then
        IS_RUNNING=false
    else
        IS_RUNNING=true
    fi
}

status()
{
    printf "Mule Runtime is: %s.\n" $edition_string
    show_latest_artifact
    get_status
    if $IS_RUNNING; then
        printf "%s seems to be running on %s.\n" $APPLICATION $HOST
    else
        printf "%s seems to be down on %s.\n" $APPLICATION $HOST
    fi
}

delete_anchor_file()
{
    printf "Deleting anchorfile %s for %s on %s.\n" $anchor_file $APPLICATION $HOST
    ssh $USER@$HOST "rm $APPS_FOLDER/$anchor_file"
}

deploy()
{
    get_status
    if $IS_RUNNING; then
        printf "%s seems to already be running on %s. Aborting...\n" $APPLICATION $HOST
    else
        get_latest_artifact
        printf "Latest artifact is: %s.\n" $latest_artifact_filename
        printf "Deploying %s to %s.\n" $latest_artifact_filename $HOST
        scp $latest_artifact $USER@$HOST:$TARGET_TMP
        #ssh $USER@$HOST "ls $TARGET_TMP/$APPLICATION*"
        copy_artifact_to_apps
    fi
}   # end of deploy

undeploy()
{
    get_status
    if ! $IS_RUNNING; then
        printf "%s seems to be down on %s. Aborting...\n" $APPLICATION $HOST
    else
        printf "Undeploying %s from %s.\n" $anchor_file $HOST
        delete_anchor_file
    fi

}   # end of undeploy

redeploy()
{
    printf "Redeploying %s on %s.\n" $APPLICATION $HOST
    undeploy
    deploy
}   # end of redeploy


##### Main script

if [ "$2" == "local" ]; then
    set-env local
elif [ "$2" == "tst" ]; then
    set-env tst
elif [ "$2" == "qas" ]; then
    set-env qas
elif [ "$2" == "prd" ]; then 
    set-env prd
elif [ "$2" == "" ]; then 
    printf "No environment specified. Please specify one of 'local', 'tst', 'qas', 'prd'.\n"
    exit 0
else
    printf "Unrecognized environment '%s'. Must be one of: 'local', 'tst', 'qas', 'prd'.\n" $2
fi

if [ "$1" == "status" ]; then
    status
elif [ "$1" == "deploy" ]; then
    deploy
elif [ "$1" == "undeploy" ]; then 
    undeploy
elif [ "$1" == "redeploy" ]; then 
    redeploy
elif [ "$1" == "" ]; then 
    printf "No command specified. Please specify one of 'status', 'deploy', 'undeploy', 'redeploy'.\n"
    exit 0
else
    printf "Unrecognized command '%s'. Must be one of 'status', 'deploy', 'undeploy', 'redeploy'.\n" $1
fi

