#!/bin/bash
#update UCD agent properties
sed -i "s/localhost/$DEPLOY_SERVER_HOSTNAME/" /opt/ibm-ucd/agent/conf/agent/installed.properties
sed -i "s/localagent/$AGENT_NAME/" /opt/ibm-ucd/agent/conf/agent/installed.properties 
sed -i "s/7918/$DEPLOY_SERVER_JMS_PORT/" /opt/ibm-ucd/agent/conf/agent/installed.properties

set -e

IFC=$(ifconfig | grep '^[a-z0-9]' | awk '{print $1}' | grep -e ns -e eth0)
IP_ADDRESS=$(ifconfig $IFC | grep 'inet addr' | awk -F : {'print $2'} | awk {'print $1'} | head -n 1)
echo "This node has an IP of " $IP_ADDRESS

if [ -z "$PUBLIC_HOSTNAME" ]; then  
  PUBLIC_HOSTNAME=$AGENT_NAME
fi

echo "$IP_ADDRESS $PUBLIC_HOSTNAME" >> /etc/hosts

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf