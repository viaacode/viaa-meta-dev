# Setting up a Jenkins pipeline

## Pipeline definition

A pipeline definition is required for Jenkins to know which projects to build. The pipeline definition has a few pieces of configuration that need to be set up:

- A SCM repository (optionally also credentials)
- The branches and/or tags that it needs to build
- The pipeline or path to the Jenkinsfile that describes the pipeline
- The way the build should be triggered

### SCM repository

The SCM can be SVN, Mercurial, Git, ...

### Branches or tags that need to be built

A suggested approach is to run builds and tests on ALL branches, even feature branches. This would improve the code quality on these branches and prevent any non-buildable projects to be merged with the environment-specific branches.

### Jenkinsfile

The Jenkinsfile can be (and ideally is) part of the SCM repository. The example below is a simple Jenkinsfile to build a java project and deploy it to a Maven repository.

```
pipeline {
    agent {
      node {
        // spin up a pod to run this build on
        label 'maven'
      }
    }
    options {
        // set a timeout of 20 minutes for this pipeline
        timeout(time: 40, unit: 'MINUTES')
    }
    stages {
        stage ('Build') {
            steps {
              configFileProvider([configFile(fileId: '452256a3-4cec-48ed-9194-8437ff991435', variable: 'MAVEN_SETTINGS_XML')]) {
                sh 'mvn -s $MAVEN_SETTINGS_XML package'
              }
            }
        }
        stage ('Deploy') {
            steps {
              configFileProvider([configFile(fileId: '452256a3-4cec-48ed-9194-8437ff991435', variable: 'MAVEN_SETTINGS_XML')]) {
                sh 'mvn -s $MAVEN_SETTINGS_XML deploy'
              }
            }
        }
    }
}
```

In this case, a node with label `maven` is used. This will set the pipeline to be executed on nodes with the `maven` label.

#### Build stage

The build stage only has one step, which is the `package` goal from Maven.

#### Deploy stage

The deploy stage also has one step, executing the `deploy` goal from Maven.

#### Config File Provider Plugin

The [Config File Provider Plugin](https://wiki.jenkins.io/display/JENKINS/Config+File+Provider+Plugin) provides Maven with a `settings.xml` file. The file will be copied into the working directory of the node running the pipeline and it also exposes a variable (called `MAVEN_SETTINGS_XML` in this case) that can be used to reference that file (since its path cannot be determined beforehand).
The fileId points to the Id of a file, in this case, a global settings.xml file that's set up under 'Manage Jenkins' → 'Managed files'.

The maven commands within the 2 stages are called upon with the `-s $MAVEN_SETTINGS_XML` parameter, which will replace the `$MAVEN_SETTINGS_XML` with the actual location of the file:

```sh
mvn -s /tmp/workspace/java-test/fxp_service@tmp/config2636344598172271014tmp deploy
```

This allows Maven to deploy the artifact to a Maven repository, whilst the global file provides the credentials.

Read below under 'Managed files' for more information.

### Build trigger

Builds can be triggered in a few different ways, including:

- Periodically
- With a hook
- Polling
- Remotely

#### Hook

[Github can be set up to send a notification to Jenkins](https://dzone.com/articles/adding-a-github-webhook-in-your-jenkins-pipeline) when certain events occur (like a new commit). This is an ideal scenario as it means Jenkins is idle for as long as there's no activity on the repository. However, for this to work, Jenkins needs to be externally accessible.

#### Polling

If Jenkins is not exposed to the outside world (or Github in our case), polling has to be used. Polling allows you to specify a CRON schedule to be used to check for any changes.

### Managed files

A managed file (in this case, a `settings.xml` file) can be created to provide your Maven projects with one global file. When creating a managed file, the file will have an ID and a name. The ID is what's referenced in the [Config File Provider Plugin](https://wiki.jenkins.io/display/JENKINS/Config+File+Provider+Plugin).

#### Credentials within Managed files

Credentials don't have to be hardcoded inside a Managed file. Jenkins can be set up to use [credentials](https://jenkins.io/doc/book/using/using-credentials/) to dynamically fill in the username/password combinations for servers within the `settings.xml` file.

**Example:**

```xml
<server>
   <id>viaa-releases-do</id>
   <username>masked</username>
   <password>masked</password>
</server>
```

When the managed file is set up with [a set of credentials belonging to a ServerId](https://imgur.com/0hcv0bQ), the 'masked' values will be replaced with the actual credentials.

## Configuration screenshot

![Example](https://i.imgur.com/Hzkrtz0.png "Example Jenkins configuration")
