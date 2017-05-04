[![Build Status](https://travis-ci.org/stackinabox/docker-uc-deploy-agent.svg?branch=master)](https://travis-ci.org/stackinabox/docker-uc-deploy-agent)

# docker-urbancode-deploy-agent
Containerised UrbanCode Deploy Agent

#### **Build Image:**<br />

`git clone https://github.com/stackinabox/docker-uc-deploy-agent.git`

Change into the newly cloned directory:  

`cd docker-uc-deploy-agent`  

create a new file callled build.rc and add the following values:

`export ARTIFACT_URL=%URL to webserver containing UCD installable artifacts%

# the steam is the name of a file that will tell us the version of UCD to download.  Using this method you can create multiple
# automated builds that can operate on many different "branches" of UCD like dev, test, qa, or some previous release from 2 years ago
# i.e.:
#  wget -Nv $ARTIFACT_URL/$ARTIFACT_STREAM
#  ARTIFACT_VERSION=$(cat $ARTIFACT_STREAM.txt)
#  ARTIFACT_DOWNLOAD_URL=$$ARTIFACT_URL/$ARTIFACT_VERSION/ibm-ucd-agent-$ARTIFACT_VERSION.zip
export ARTIFACT_STREAM=%name of file available at ARTIFACT_URL that contains the version of UCD you will be installing%

export DOCKER_EMAIL=%your email address%
export DOCKER_USERNAME=%your docker registry username%
export DOCKER_PASSWORD=%your docker registry password%`

Fill in with the appropriate values for your situation.
	
now run a build:  

`./build.sh`

#### **Run Image:**<br />
`docker run -d -e "DEPLOY_SERVER_URL=http://192.168.27.100:8080" -e "AGENT_NAME=my-agent" --name localagent stackinabox/urbancode-deploy-agent:%tag%` 
  

#### Environment variables:  

DEPLOY_SERVER_URL - External url of UCD server agent should use to connect to UCD server.  
AGENT_NAME - name to use for agent; defaults to localagent; if set to `importagent` then this agent will be configured as the default agent for imports on the UCD server. 

