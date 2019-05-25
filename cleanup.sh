#!/usr/bin/env bash

#EXIT ON ERROR
#set -e

BASEDIR=$(dirname "$0")
. ${BASEDIR}/sso_env.sh

rm ${CACERT_FILENAME} ${CAKEY_FILENAME} *.srl ${HTTPS_KEYSTORE_FILENAME} ${JGROUPS_ENCRYPT_KEYSTORE} ${SSOCERT} ${SSOSIGNREQ} ${SSO_TRUSTSTORE_FILENAME}


echo "switch to ${SSO_NAMESPACE} project"
error=$(oc project ${SSO_NAMESPACE})

if [ $? -eq 0 ]; then
    echo "OK! "
else
    echo $error
    exit 1
fi

#oc delete secret env-datasource
oc delete secret cli-scripts -n ${SSO_NAMESPACE}
oc delete secret ${HTTPS_SECRET} -n ${SSO_NAMESPACE}
oc policy remove-role-from-user view system:serviceaccount:$(oc project -q):sso-service-account
oc delete serviceaccount sso-service-account -n ${SSO_NAMESPACE}

oc delete -f ${BASEDIR}/sso73-https-postgresql-external-cli.yaml -n ${SSO_NAMESPACE}
