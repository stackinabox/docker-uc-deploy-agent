FROM stackinabox/ibm-supervisord:3.2.2

MAINTAINER Tim Pouyer <tpouyer@us.ibm.com>

# Pass in the location of the UCD agent install zip 
ARG ARTIFACT_DOWNLOAD_URL 
ARG ARTIFACT_VERSION

# Add startup.sh script and addtional supervisord config
ADD startup.sh /opt/startup.sh
ADD supervisord.conf /tmp/supervisord.conf

# Copy in installation properties
ADD install.properties /tmp/install.properties
ADD post-configure-as-import-agent.sh /root/post-configure-as-import-agent.sh

# get UCD server to connect to and agent name
ENV DEPLOY_SERVER_URL=${DEPLOY_SERVER_URL:-} \
    DEPLOY_SERVER_HOSTNAME=${DEPLOY_SERVER_HOSTNAME:-localhost} \
    DEPLOY_SERVER_JMS_PORT=${DEPLOY_SERVER_JMS_PORT:-7918} \
    AGENT_NAME=${AGENT_NAME:-localagent}

# Install UCD agent
RUN mkdir -p /file-import && \
	wget -Nv $ARTIFACT_DOWNLOAD_URL && \
	unzip -q ibm-ucd-agent-$ARTIFACT_VERSION.zip -d /tmp && \
	/tmp/ibm-ucd-agent-install/install-agent-from-file.sh /tmp/install.properties && \
	cat /tmp/supervisord.conf >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /tmp/my.install.properties /tmp/ibm-ucd-agent-install ibm-ucd-agent-$ARTIFACT_VERSION.zip /tmp/supervisord.conf

VOLUME ["/file-import"]

ENTRYPOINT ["/opt/startup.sh"]
CMD []
