#!/usr/bin/env sh

#### 
#  The following variables must be set in the build.rc file before executing this script
####
ARTIFACT_URL=${ARTIFACT_URL:-http://artifactory.stackinabox.io/artifactory}
#ARTIFACT_STREAM=

#DOCKER_EMAIL=
#DOCKER_USERNAME=
#DOCKER_PASSWORD=

source ./build.rc

####
# UCD_VERSION will be read from the stream file on the artifact server so no need to set it
####
UCD_AGT_VERSION=${UCD_VERSION:-latest}
UCD_AGT_DOWNLOAD_URL="$ARTIFACT_URL/urbancode-snapshot-local/urbancode/ibm-ucd-agent/$UCD_AGT_VERSION/ibm-ucd-agent.zip"

rm -rf artifacts/*

echo "artifact url: $ARTIFACT_URL"
echo "ucd version:  $UCD_AGT_VERSION"
echo "ucd download url: $UCD_AGT_DOWNLOAD_URL"

curl -u$ARTIFACT_USERNAME:$ARTIFACT_PASSWORD -O $UCD_AGT_DOWNLOAD_URL
unzip -q ibm-ucd-agent.zip -d artifacts/
rm -f ibm-ucd-agent.zip

docker login -e="$DOCKER_EMAIL" -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
docker build -t stackinabox/urbancode-deploy-agent:$UCD_AGT_VERSION .
docker push stackinabox/urbancode-deploy-agent:$UCD_AGT_VERSION
