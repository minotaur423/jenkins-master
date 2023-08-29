#! /bin/bash

GRADLE_PROXY_OPTIONS="-Djdk.http.auth.tunneling.disabledSchemes= -Djdk.https.auth.tunneling.disabledSchemes="

JAVA_OPTS="${GRADLE_PROXY_OPTIONS}"

/usr/local/bin/jenkins.sh "--prefix=${JENKINS_PREFIX}" $@
