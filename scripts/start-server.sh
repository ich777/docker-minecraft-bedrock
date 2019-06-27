#!/bin/bash
INS_V="$(find ${SERVER_DIR} -name *.installed | cut -d '-' -f 3 | awk -F ".installed" '{print $1}')"

if [ -z "$INS_V" ]; then
	echo "---Minecraft Bedrock not found, Downloading v${GAME_VERSION}---"
	cd ${SERVER_DIR}
	wget -qi https://minecraft.azureedge.net/bin-linux/bedrock-server-${GAME_VERSION}.zip
    sleep 2
    unzip -o bedrock-server-${GAME_VERSION}.zip
    rm bedrock-server-${GAME_VERSION}.zip
    touch bedrock-server-${GAME_VERSION}.installed
    mv ${SERVER_DIR}/server.properties ${SERVER_DIR}/vanilla.server.properties
    wget -qi https://raw.githubusercontent.com/ich777/docker-minecraft-bedrock/master/config/server.properties
    if [ ! -f ${SERVER_DIR}/bedrock-server-${GAME_VERSION}.installed ]; then
    	echo "----------------------------------------------------------------------------------------------------"
    	echo "---Something went wrong, please install Minecraft Bedrock Server manually. Putting server into sleep mode---"
        echo "----------------------------------------------------------------------------------------------------"
        sleep infinity
    fi
elif [ "${GAME_VERSION}" != "$INS_V" ]; then
	echo "---Version missmatch Installed: v$INS_V - Prefered:${GAME_VERSION}, downloading v${GAME_VERSION}---"
	rm ${SERVER_DIR}/bedrock-server-$INS_V.installed
	cd ${SERVER_DIR}
	wget -qi https://minecraft.azureedge.net/bin-linux/bedrock-server-${GAME_VERSION}.zip
	sleep 2
    echo "---Creating Backup of config files---"
    mkdir ${SERVER_DIR}/backup_config_files
    mv ${SERVER_DIR}/server.properties ${SERVER_DIR}/backup_config_files/server.properties
    mv ${SERVER_DIR}/permissions.json ${SERVER_DIR}/backup_config_files/permissions.json
    mv ${SERVER_DIR}/whitelist.json ${SERVER_DIR}/backup_config_files/whitelist.json
    echo "---Installing v${GAME_VERSION}---"
	unzip -o bedrock-server-${GAME_VERSION}.zip
	rm bedrock-server-${GAME_VERSION}.zip
    echo "---Copying Backup config files back to server directory---"
    mv ${SERVER_DIR}/backup_config_files/server.properties ${SERVER_DIR}/server.properties
    mv ${SERVER_DIR}/backup_config_files/permissions.json ${SERVER_DIR}/permissions.json
    mv ${SERVER_DIR}/backup_config_files/whitelist.json ${SERVER_DIR}/whitelist.json
    rm -R ${SERVER_DIR}/backup_config_files
	touch bedrock-server-${GAME_VERSION}.installed
	if [ ! -f ${SERVER_DIR}/bedrock-server-${GAME_VERSION}.installed ]; then
		echo "----------------------------------------------------------------------------------------------------"
		echo "---Something went wrong, please install Minecraft Bedrock Server manually. Putting server into sleep mode---"
		echo "----------------------------------------------------------------------------------------------------"
		sleep infinity
	fi
elif [ "${GAME_VERSION}" == "$INS_V" ]; then
	echo "---Minecraft Bedrock Server Version up-to-date---"
else
	echo "---Something went wrong, putting server in sleep mode---"
	sleep infinity
fi

echo "---Preparing Server---"
chmod -R 770 ${DATA_DIR}

echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;

echo "---Starting Server---"
cd ${SERVER_DIR}
LD_LIBRARY_PATH=. && screen -S Minecraft -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/bedrock_server ${GAME_PARAMS}
sleep 2
echo "---Waiting for logs, please stand by...---"
tail -f ${SERVER_DIR}/masterLog.0