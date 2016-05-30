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

# get UCD server to connect to and agent name
ENV UCD_SERVER=${UCD_SERVER:-localhost} \
  AGENT_NAME=${AGENT_NAME:-localagent}

# Install UCD agent
RUN wget $ARTIFACT_DOWNLOAD_URL && \
	unzip -q ibm-ucd-agent-$ARTIFACT_VERSION.zip -d /tmp && \
	/tmp/ibm-ucd-agent-install/install-agent-from-file.sh /tmp/install.properties && \
	cat /tmp/supervisord.conf >> /etc/supervisor/conf.d/supervisord.conf && \
	rm -rf /tmp/my.install.properties /tmp/ibm-ucd-agent-install ibm-ucd-agent-$ARTIFACT_VERSION.zip /tmp/supervisord.conf

ENTRYPOINT ["/opt/startup.sh"]
CMD []
