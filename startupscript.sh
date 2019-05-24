#!/usr/bin/env bash

#EXIT ON ERROR
set -e


BASEDIR=$(dirname "$0")
. ${BASEDIR}/sso_env.sh


echo "Create CA key and cert"
openssl req -new -newkey rsa:4096 -x509 -keyout ${CAKEY_FILENAME} -out ${CACERT_FILENAME} -days 365 -subj "/CN=${CA_COMMON_NAME}" -passin pass:${CAPASS} -passout pass:${CAPASS}
echo "Create HTTPS keystore"
keytool -genkeypair -keyalg RSA -keysize 2048 -dname "CN=${HOSTNAME_HTTPS}" -alias ${HTTPS_NAME} -keystore ${HTTPS_KEYSTORE_FILENAME} -keypass ${HTTPS_PASSWORD} -storepass ${HTTPS_PASSWORD}
echo "Create HTTPS cert request"
keytool -certreq -keyalg rsa -alias ${HTTPS_NAME} -keystore ${HTTPS_KEYSTORE_FILENAME} -file ${SSOSIGNREQ} -keypass ${HTTPS_PASSWORD} -storepass ${HTTPS_PASSWORD}
echo "Create SSO cert"
openssl x509 -trustout -req -CA ${CACERT_FILENAME} -CAkey ${CAKEY_FILENAME} -in ${SSOSIGNREQ} -out ${SSOCERT} -days 365 -CAcreateserial -passin pass:${CAPASS}
echo "Add CA cert to HTTPS keystore"
keytool -import -noprompt -trustcacerts -file ${CACERT_FILENAME} -alias ${CAALIAS} -keystore ${HTTPS_KEYSTORE_FILENAME} -keypass ${HTTPS_PASSWORD} -storepass ${HTTPS_PASSWORD}
echo "Add SSO cert to HTTPS keystore"
keytool -import -noprompt -trustcacerts -file ${SSOCERT} -alias ${HTTPS_NAME} -keystore ${HTTPS_KEYSTORE_FILENAME} -keypass ${HTTPS_PASSWORD} -storepass ${HTTPS_PASSWORD}
echo "Add CA cert to SSO truststore"
keytool -import -noprompt -trustcacerts -file ${CACERT_FILENAME} -alias ${CAALIAS} -keystore ${SSO_TRUSTSTORE_FILENAME} -keypass ${CAPASS} -storepass ${SSO_TRUSTSTORE_PASSWORD}
echo "Create JGROUPS keystore"
keytool -genseckey -alias ${JGROUPS_ENCRYPT_NAME} -storetype JCEKS -keypass ${JGROUPS_ENCRYPT_PASSWORD} -storepass ${JGROUPS_ENCRYPT_PASSWORD} -keystore ${JGROUPS_ENCRYPT_KEYSTORE}



echo "switch to ${SSO_NAMESPACE} project"
error=$(oc project ${SSO_NAMESPACE})

if [ $? -eq 0 ]; then
    echo "OK! "
else
    echo $error
    exit 1
fi

echo "Create SSO Service Account"
oc create serviceaccount sso-service-account
oc policy add-role-to-user view system:serviceaccount:$(oc project -q):sso-service-account

echo "Create one secret for all stores"
oc create secret generic ${HTTPS_SECRET} --from-file=${JGROUPS_ENCRYPT_KEYSTORE} --from-file=${HTTPS_KEYSTORE_FILENAME} --from-file=${SSO_TRUSTSTORE_FILENAME}
oc secret add sa/sso-service-account secret/${HTTPS_SECRET}

echo "Start Deployment"

oc process -f  sso73-https-postgresql-external-cli.yaml  \
-p APPLICATION_NAME=${APPLICATION_NAME} \
-p SSODB_PASSWORD=${SSODB_PASSWORD} \
-p SSODB_USERNAME=${SSODB_USERNAME} \
-p SOURCE_REPOSITORY_URL=${https://github.com/luigidemasi/rhsso-with-ext-postgresql-db-cli.git}
-p SSODB_URL=${SSODB_URL} \
-p DB_MIN_POOL_SIZE=${DB_MIN_POOL_SIZE} \
-p DB_MAX_POOL_SIZE=${DB_MAX_POOL_SIZE} \
-p HOSTNAME_HTTP=${HOSTNAME_HTTP} \
-p HOSTNAME_HTTPS=${HOSTNAME_HTTPS} \
-p HTTPS_KEYSTORE=${HTTPS_KEYSTORE_FILENAME} \
-p HTTPS_KEYSTORE_TYPE=jks \
-p HTTPS_NAME=${HTTPS_NAME} \
-p HTTPS_PASSWORD=${HTTPS_PASSWORD} \
-p JGROUPS_ENCRYPT_SECRET=${HTTPS_SECRET} \
-p JGROUPS_ENCRYPT_KEYSTORE=${JGROUPS_ENCRYPT_KEYSTORE} \
-p JGROUPS_ENCRYPT_NAME=${JGROUPS_ENCRYPT_NAME} \
-p JGROUPS_ENCRYPT_PASSWORD=${JGROUPS_ENCRYPT_PASSWORD} \
-p SSO_ADMIN_USERNAME=${SSO_ADMIN_USERNAME} \
-p SSO_ADMIN_PASSWORD=${SSO_ADMIN_PASSWORD} \
-p SSO_REALM=${SSO_REALM} \
-p SSO_SERVICE_USERNAME=${SSO_SERVICE_USERNAME} \
-p SSO_SERVICE_PASSWORD=${SSO_SERVICE_PASSWORD} \
-p SSO_TRUSTSTORE=${SSO_TRUSTSTORE_FILENAME} \
-p SSO_TRUSTSTORE_PASSWORD=${SSO_TRUSTSTORE_PASSWORD} \
-p SSO_TRUSTSTORE_SECRET=${HTTPS_SECRET} \
| oc create -f -
