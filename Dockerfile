FROM stackinabox/supervisord:3.2.2

ADD supervisord.conf /etc/supervisord.conf
ADD startup.sh /opt/startup.sh

RUN /usr/bin/yum -y update && \
  /usr/bin/yum -y install java-1.8.0-openjdk && \
  yum clean packages

#Pass in the location of the UCD agent install zip 
ARG AGENT_MEDIA_URL 

#get UCD server to connect to and agent name
ENV UCD_SERVER=${UCD_SERVER:-localhost} \
  AGENT_NAME=${AGENT_NAME:-localagent}
# Get installation files
ADD $AGENT_MEDIA_URL /tmp/
#Copy in installation properties
ADD my.install.properties /tmp/

#unzip
RUN unzip /tmp/ibm-ucd-agent.zip -d /tmp

#Install UCD agent
RUN /tmp/ibm-ucd-agent-install/install-agent-from-file.sh /tmp/my.install.properties && \
	rm -rf /tmp/ibm-ucd-agent-install /tmp/ibm-ucd-agent.zip

CMD ["/opt/startup.sh"] 
