# Setting up the OpenShift CLI client

## Abstract

In this tutorial we will install, setup and configure the **OpenShift CLI client** (as well as `kubectl`: the Kubernetes command-line tool).

## Prerequisites

- VPN access, see:
	- [VPN Documentation](https://viaadocumentation.atlassian.net/wiki/spaces/IK/pages/21037101/VPN+Documentation)
	- [VPN Access on Linux (using OpenVPN)](https://viaadocumentation.atlassian.net/wiki/spaces/SI/pages/900694036/VPN+Access+on+Linux+using+OpenVPN)

## Installation

Detailed installation instructions for the binaries can be found here: https://docs.okd.io/latest/cli_reference/get_started_cli.html.

Afterwards, check the installation, for example, with:

	$ oc --help

## Setup and configuration

The `oc login` command is the best way to initially set up the CLI, and it serves as the entry point for most users. The interactive flow helps you establish a session to an OKD server with the provided credentials. The information is automatically saved in a [CLI configuration file](https://docs.okd.io/latest/cli_reference/get_started_cli.html#cli-configuration-files) that is then used for subsequent commands.

You can view the current (and most likely, empty) configuration via the `oc config view` command.

```shell
$ oc login
(1) Server [https://localhost:8443]: https://do-prd-okp-m0.do.viaa.be:8443
The server uses a certificate signed by an unknown authority.
You can bypass the certificate check, but any data you send to the server could be intercepted by others.
(2) Use insecure connections? (y/n): y

(3) Authentication required for https://do-prd-okp-m0.do.viaa.be:8443 (openshift)
Username: admin
Password: 
Login successful.

You have access to the following projects and can switch between them with 'oc project <projectname>':

    ...
    ci-cd
  * default
    intake-frontend
    ...

Using project "default".
Welcome! See 'oc help' to get started.
```

(1) The host for VIAA's OpenShift server: https://do-prd-okp-m0.do.viaa.be:8443  
(2) The certificate is self-signed. Just answer yes.  
(3) Credentials can be obtained via the VIAA OpenShift administrators ([@Tina](https://github.com/orgs/viaacode/people/violetina), [@Herwig](https://github.com/orgs/viaacode/people/hbog))
