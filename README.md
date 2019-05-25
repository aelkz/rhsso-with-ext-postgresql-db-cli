# Using the JBoss CLI to configure an external Postgresql database with Red Hat SSO for Openshift

Example of configuring and using an external Postgresql database with the Red Hat Single Sign On (SSO) container for 
Openshift.

This example does not add a Postgresql JDBC driver as the Red Hat SSO image currently provides a version of the Postgresql
JDBC driver.  Please be aware that this could change in future versions of the RHSSO image where third party JDBC drivers
might not be provided and would need to be installed.  A datasource is created at deploy time that uses the Postgresql 
JDBC driver.  This example assumes that the Postgresql database is visible to pods via DNS alone.

**NOTE:** This example requires that specifics for the Posgresql database be provided. 
 Look at the [actions.cli](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/extensions/actions.cli) 
 file for database specific settings.

This repository provides a working reference which includes:

- An `.s2i` directory that includes an `environment` [file](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/.s2i/environment) 
  that sets `CUSTOM_INSTALL_DIRECTORIES=extensions`.  This is used by scripts provided in the Red Hat SSO image to allow for customization to take place at pod deploy time.
- An `extensions` directory that includes
  - a [install.sh](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/extensions/install.sh) 
    file that copies required files/scripts into the container.
  - a [postconfigure.sh](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/extensions/postconfigure.sh) 
    file that executes a JBoss cli batch file.
  - a JBoss cli batch file [actions.cli](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/extensions/actions.cli) 
    that creates and configures the Postgresql datasource
- A [template file](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml) 
  that is derived from an [example template](https://github.com/jboss-container-images/redhat-sso-7-openshift-image/blob/v7.3.1.GA/templates/sso73-https.json) 
  provided by Red Hat.  The template is [set to use](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml#L334-#L341) 
  the [RHSSO 7.3 imagestream](https://access.redhat.com/containers/#/registry.access.redhat.com/redhat-sso-7/sso73-openshift).  
- The template contains the following modifications: 
  - Added a [buildconfig](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml#L322-#L360) 
    to allow the inclusion of files from this git repo into the image.
  - Added an [imagestream definition](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml#L316-#L321) 
    for the resulting RHSSO container that we are creating.
  - Added [parameters](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml#L78-#L98) 
    for building from a git repository
  - Added [secret](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml#L299-#L315) containig a jboss-cli script that
    configure the kyecloak datasource using [SSODB_URL](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml#L124-#L127), 
    [SSODB_USERNAME](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml#L116-#L119)  and 
    [SSODB_PASSWORD](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml#L120-#L123) parameters


## How it works

The modified template [sso73-https-postgresql-external-cli.yaml](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso73-https-postgresql-external-cli.yaml) 
is used to introduce a buildconfig that will incorporate files contained within a Git repository.  The default repository 
is [this repo](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli).  The build process clones this git repository 
into a build pod that performs a build of the RHSSO container.  The Openshift build process produces a container image to 
be used for an RHSSO pod.

When the resulting container image is used to produce an RHSSO pod, the pod is configured at deploy time to include 
datasource settings provided by the [actions.cli](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/extensions/actions.cli).  
During the deployment phase, the [postconfigure.sh](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/extensions/postconfigure.sh) 
executes the [actions.cli](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/extensions/actions.cli) 
file in turn configuring the RHSSO based container to include a Postgresql datasource representing the external database.


## Requirements
- [Openshift command line client (oc)](https://www.okd.io/download.html)
- Openssl
- Java keytool


## Steps to use this example

- Create a project.

~~~
oc new-project sso
~~~

Edit [sso_env.sh](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/sso_env.sh) to configure 
the install script.

~~~bash
#!/usr/bin/env bash
#CERTIFICATES
CAALIAS=ca_rhsso
CACERT_FILENAME=ca.cer
CAKEY_FILENAME=ca.key
CAPASS=Y9g7WDkd
CA_COMMON_NAME=ca.acme.self
HOSTNAME_HTTPS=
HOSTNAME_HTTP=
HTTPS_KEYSTORE_FILENAME=httpskey.jceks
HTTPS_NAME=sso
HTTPS_PASSWORD=
HTTPS_SECRET=sso-app-secret
JGROUPS_ENCRYPT_KEYSTORE=jgroups.jceks
JGROUPS_ENCRYPT_NAME=jgroups
JGROUPS_ENCRYPT_PASSWORD=
SSOCERT=sso.cer
SSOSIGNREQ=sso-request.cer
SSO_TRUSTSTORE_FILENAME=truststore.jks
SSO_TRUSTSTORE_PASSWORD=
SOURCE_REPOSITORY_URL=https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli.git

SSO_NAMESPACE=sso
APPLICATION_NAME=ssodev

# DATABASE
DB_MIN_POOL_SIZE=10
DB_MAX_POOL_SIZE=250
SSODB_USERNAME=
SSODB_PASSWORD=
SSODB_URL='jdbc\:postgresql\://acme.postgres.com\:5432/rh-sso?currentSchema=mySchema&ssl=true&sslmode=require'

## SSO USERS
#ADMIN
SSO_ADMIN_USERNAME=admin
SSO_ADMIN_PASSWORD=admin
#USER
SSO_SERVICE_USERNAME=sso
SSO_SERVICE_PASSWORD=
SSO_REALM=myapp
~~~

then run the [install](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/startupscript.sh) to configure script

~~~bash
bash startupscript.sh
~~~

At this point you should see a build process initiate followed by a deployment of the RHSSO pod.

To remove all the ocp objects and files created by the install scripts and template, run the [cleanup](https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli/blob/master/cleanup.sh) script.

~~~bash
bash cleanup.sh
~~~


