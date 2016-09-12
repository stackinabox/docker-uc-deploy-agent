#!/bin/bash

if [ "$AGENT_NAME" == "importagent" ]; then

    # UCD Server takes a few seconds to startup. If we call this function too early it will fail
    # loop until it succeeds or fail after # of attempts
	attempt=0
	until $(curl -k -u admin:admin --output /dev/null --silent --head --fail "${DEPLOY_SERVER_URL}/cli/systemConfiguration"); do
		attempt=$(($attempt + 1))
		sleep 10
		if [ "$attempt" -gt "18" ]; then
			echo "Failed to connect to ucd server at ${DEPLOY_SERVER_URL}. Please check the environment variable DEPLOY_SERVER_URL for a valid value."
			exit 1
		fi
	done

	echo "Successfully connected to UCD server at ${DEPLOY_SERVER_URL}"

	# It can sometimes take a couple of seconds for the agent to be "registered" with the UCD server
	# if we call this function and it fails to find the agent try again until success or fail after # of attempts
	localAgentId=
	attempt=1
	until [ -n "$localAgentId" ]; do
		attempt=$(($attempt + 1))

		echo "Searching for registered agent with name ${AGENT_NAME}... $attempt"
		# setup localagent as the default source config importer
		localAgentId=`curl -s -u admin:admin \
			-H 'Content-Type: application/json' \
			-X GET \
			"${DEPLOY_SERVER_URL}/rest/agent" | python -c \
"import json; import sys;
data=json.load(sys.stdin);
for item in data:
    if item['name'] == 'importagent':
	    print item['id']"`

		if [ "$attempt" -gt "18" ]; then
			echo "Failed to locate a registered ucd agent with name ${AGENT_NAME} on UCD ${DEPLOY_SERVER_URL}."
			exit 1
		fi

		if [ -z "$localAgentId" ]; then
			sleep 10
		fi
	done

	echo "Successfully located registered Agent \"${AGENT_NAME}\" with id ${localAgentId}"

	# curl -s -u admin:admin \
	# 	 -H 'Content-Type: application/json' \
	# 	 -X GET \
	# 	 http://192.168.27.100:8080/rest/agent/$localagentId/restart

	newDefaultImportAgentId=
	attempt=0
	until [ -n "$newDefaultImportAgentId" ]; do
		attempt=$(($attempt + 1))
		
		echo "Attempting to register Agent ${AGENT_NAME} as default for imports on UCD server ${DEPLOY_SERVER_URL}... $attempt"

		curl -s -u admin:admin \
			 -H 'Content-Type: application/json' \
			 -X PUT \
			 -d "
		{
			\"externalURL\": \""$DEPLOY_SERVER_URL"\",
			\"externalUserURL\": \""$DEPLOY_SERVER_URL"\",
			\"repoAutoIntegrationPeriod\": 300000,
			\"deployMailHost\": \"smtp.example.com\",
			\"deployMailPassword\": \"\",
			\"deployMailPort\": 25,
			\"deployMailSecure\": false,
			\"deployMailSender\": \"sender@example.com\",
			\"deployMailUsername\": \"username\",
			\"cleanupHourOfDay\": 0,
			\"cleanupDaysToKeep\": -1,
			\"cleanupCountToKeep\": -1,
			\"cleanupArchivePath\": \"\",
			\"historyCleanupTimeOfDay\": 1473379223743,
			\"historyCleanupDaysToKeep\": 730,
			\"historyCleanupDuration\": 23,
			\"historyCleanupEnabled\": false,
			\"enableInactiveLinks\": false,
			\"enablePromptOnUse\": false,
			\"enableAllowFailure\": false,
			\"validateAgentIp\": false,
			\"skipCollectPropertiesForExistingAgents\": false,
			\"requireComplexPasswords\": false,
			\"minimumPasswordLength\": 0,
			\"enableUIDebugging\": false,
			\"enableMaintenanceMode\": false,
			\"isCreateDefaultChildren\": false,
			\"requireCommentForProcessChanges\": false,
			\"failProcessesWithUnresolvedProperties\": true,
			\"enforceDeployedVersionIntegrity\": true,
			\"artifactAgent\": \""$localAgentId"\",
			\"artifactAgentName\": \""$AGENT_NAME"\",
			\"serverLicenseType\": \"No License\",
			\"serverLicenseBackupType\": \"No License\",
			\"rclServerUrl\": \""$RCL_URL"\",
			\"agentAutoLicense\": false,
			\"defaultLocale\": \"en_US\",
			\"defaultSnapshotLockType\": \"ALL\"
		}
		" \
		"${DEPLOY_SERVER_URL}/rest/system/configuration"

		# setup localagent as the default source config importer
		newDefaultImportAgentId=`curl -s -u admin:admin \
			-H 'Content-Type: application/json' \
			-X GET \
			"${DEPLOY_SERVER_URL}/cli/systemConfiguration" | python -c \
"import json; import sys;
data=json.load(sys.stdin);
print data['artifactAgentName']"`

		if [ "$attempt" -gt "18" ]; then
			echo "Failed to register Agent ${AGENT_NAME} as default for imports on UCD server ${DEPLOY_SERVER_URL}."
			exit 1
		fi

		if [ -z "$newDefaultImportAgentId" ]; then
			sleep 10
		fi

	done

	echo "Successfully configured Agent \"${AGENT_NAME}\" as the default for imports on UCD server ${DEPLOY_SERVER_URL}"
fi

exit 0