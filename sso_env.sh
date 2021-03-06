#!/usr/bin/env bash
#CERTIFICATES

CAALIAS=ca_sso
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
SSODB_USERNAME=r
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
