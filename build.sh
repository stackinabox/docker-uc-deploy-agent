#!/bin/sh

#### 
#  The following variables must be set in the build.rc file before executing this script
####
#ARTIFACT_URL=
#ARTIFACT_STREAM=

#DOCKER_EMAIL=
#DOCKER_USERNAME=
#DOCKER_PASSWORD=

source ./build.rc

####
# UCD_VERSION will be read from the stream file on the artifact server so no need to set it
####
UCD_AGT_VERSION=

curl -O "$ARTIFACT_URL/urbancode/ibm-ucd-agent/$ARTIFACT_STREAM.txt"
UCD_AGT_VERSION=`cat $ARTIFACT_STREAM.txt`  # i.e. latest or dev or qa or vnext etc... file will contain just the version number
rm -f $ARTIFACT_STREAM.txt

docker login -e="$DOCKER_EMAIL" -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
docker build -t stackinabox/urbancode-deploy-agent:$UCD_AGT_VERSION --build-arg AGENT_MEDIA_URL=$ARTIFACT_URL/urbancode/ibm-ucd-agent/$UCD_AGT_VERSION/ibm-ucd-agent.zip .
docker push stackinabox/urbancode-deploy-agent:$UCD_AGT_VERSION
