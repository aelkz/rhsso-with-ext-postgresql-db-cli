#!/usr/bin/env bash

#EXIT ON ERROR
#set -e

rm  ca.cer  ca.key  ca.srl  httpskey.jceks  jgroups.jceks sso.cer  sso-request.cer truststore.jks

. sso_env.sh

echo "switch to ${SSO_NAMESPACE} project"
error=$(oc project ${SSO_NAMESPACE})

if [ $? -eq 0 ]; then
    echo "OK! "
else
    echo $error
    exit 1
fi

#oc delete secret env-datasource
oc delete secret db-cli-script
oc delete secret sso-app-secret
oc policy remove-role-from-user view system:serviceaccount:$(oc project -q):sso-service-account
oc delete serviceaccount sso-service-account

oc delete all --all -n ${SSO_NAMESPACE}
