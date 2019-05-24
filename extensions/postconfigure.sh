#!/usr/bin/env bash
echo "Executing actions.cli"
$JBOSS_HOME/bin/jboss-cli.sh --file=$JBOSS_HOME/extensions/actions.cli
echo "Done"
echo "new standalone-openshift.xml:"
cat /opt/eap/standalone/configuration/standalone-openshift.xml
