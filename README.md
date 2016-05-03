# docker-urbancode-deploy-agent
Containerised UrbanCode Deploy Agent

#### **Build Image:**<br />
`git clone` this repo <br />
`docker build -t stackinabox/urbancode-deploy-agent:latest --build-arg AGENT_MEDIA_URL=http://192.168.27.100:8080/tools/ibm-ucd-agent.zip .`<br />

Change AGENT_MEDIA_URL as appropriate, can be local filesystem or remote URL

#### **Run Image:**<br />
`docker run -d -e "UCD_SERVER=192.168.27.100" --name localagent stackinabox/urbancode-deploy-agent`<br />

Environment variables:
UCD_SERVER - IP/hostname of UCD server agent should connect to default port 7918 assumed
AGENT_NAME - name to use for agent; defaults to localagent

