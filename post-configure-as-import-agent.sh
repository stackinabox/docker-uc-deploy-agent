#!/bin/bash

if [ -n $USE_AS_DEFAULT_FOR_IMPORTS ]; then


	# setup localagent as the default source config importer
	localagentId=`curl -s -u admin:admin \
		 -H 'Content-Type: application/json' \
		 -X GET \
		 http://${UCD_SERVER}:${UCD_SERVER_HTTP_PORT}/rest/agent | python -c \
"import json; import sys;
data=json.load(sys.stdin);
for item in data:
	if item['name'] == 'localagent':
		print item['id']"`

	echo "localagentId = $localagentId"

	# curl -s -u admin:admin \
	# 	 -H 'Content-Type: application/json' \
	# 	 -X GET \
	# 	 http://192.168.27.100:8080/rest/agent/$localagentId/restart

	curl -s -u admin:admin \
		 -H 'Content-Type: application/json' \
		 -X PUT \
		 -d "
	{
		\"externalURL\": \"http\://"$UCD_SERVER"\:"$UCD_SERVER_HTTP_PORT"\",
		\"externalUserURL\": \"http\://"$UCD_SERVER"\:"$UCD_SERVER_HTTP_PORT"\",
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
		\"historyCleanupTimeOfDay\": 1463184001196,
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
		\"artifactAgent\": \""$localagentId"\",
		\"artifactAgentName\": \"localagent\",
		\"serverLicenseType\": \"No License\",
		\"serverLicenseBackupType\": \"No License\",
		\"rclServerUrl\": \"27000@licenses.example.com\",
		\"agentAutoLicense\": false,
		\"defaultLocale\": \"\",
		\"defaultSnapshotLockType\": \"ALL\"
	}
	" \
	http://$UCD_SERVER:$UCD_SERVER_HTTP_PORT/rest/system/configuration
fi

exit 0