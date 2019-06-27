#!/bin/bash
echo "---sleep---"
sleep infinity
CUR_V="$"
INS_V="$(find ${SERVER_DIR} -name *.installed)"

echo "---Checking for Minecraft Bedrock Server executable ---"
if [ ! -f ${SERVER_DIR}/${GAME_VERSION}.installed ]; then
	cd ${SERVER_DIR}
	echo "---Downloading Minecraft Bedrock Server ${GAME_VERSION}---"
    wget -qi ${GAME_VERSION}.zip https://minecraft.azureedge.net/bin-linux/bedrock-server-${GAME_VERSION}.zip
    sleep 2
    unzip -o ${GAME_VERSION}.zip
    rm ${GAME_VERSION}.zip
    touch ${GAME_VERSION}.installed
    if [ ! -f ${SERVER_DIR}/${GAME_VERSION} ]; then
    	echo "----------------------------------------------------------------------------------------------------"
    	echo "---Something went wrong, please install Minecraft Bedrock Server manually. Putting server into sleep mode---"
        echo "----------------------------------------------------------------------------------------------------"
        sleep infinity
    fi
else
	echo "---Minecraft Server Bedrock executable found---"
fi

echo "---Preparing Server---"
echo "---Checking for 'server.properties'---"
if [ ! -f ${SERVER_DIR}/server.properties ]; then
    echo "---No 'server.properties' found, downloading...---"
    wget -qi ${SERVER_DIR}/server.properties https://raw.githubusercontent.com/ich777/docker-minecraft-basic-server/master/config/server.properties
else
    echo "---'server.properties' found..."
fi
chmod -R 770 ${DATA_DIR}
if [ ! -f $SERVER_DIR/eula.txt ]; then
	:
else
	if [ "${ACCEPT_EULA}" == "false" ]; then
		if grep -rq 'eula=true' ${SERVER_DIR}/eula.txt; then
			sed -i '/eula=true/c\eula=false' ${SERVER_DIR}/eula.txt
		fi
		echo
		echo "-------------------------------------------------------"
    	echo "------EULA not accepted, you must accept the EULA------"
    	echo "---to start the Server, putting server in sleep mode---"
    	echo "-------------------------------------------------------"
    	sleep infinity
    fi
fi
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;

echo "---Starting Server---"
cd ${SERVER_DIR}
screen -S Minecraft -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/runtime/${RUNTIME_NAME}/bin/java -Xmx${XMX_SIZE}M -Xms${XMS_SIZE}M -jar ${SERVER_DIR}/${JAR_NAME}.jar nogui ${GAME_PARAMS}
sleep 2
if [ ! -f $SERVER_DIR/eula.txt ]; then
	echo "---EULA not found please stand by...---"
	sleep 30
fi
if [ "${ACCEPT_EULA}" == "true" ]; then
	if grep -rq 'eula=false' ${SERVER_DIR}/eula.txt; then
    	sed -i '/eula=false/c\eula=true' ${SERVER_DIR}/eula.txt
		echo "---EULA accepted, please restart server---"
        sleep infinity
    fi
elif [ "${ACCEPT_EULA}" == "false" ]; then
	echo
	echo "-------------------------------------------------------"
    echo "------EULA not accepted, you must accept the EULA------"
    echo "---to start the Server, putting server in sleep mode---"
    echo "-------------------------------------------------------"
    sleep infinity
else
	echo "---Something went wrong, please check EULA variable---"
fi
echo "---Waiting for logs, please stand by...---"
sleep 30
if [ -f ${SERVER_DIR}/logs/latest.log ]; then
        tail -F ${SERVER_DIR}/logs/latest.log
else
        tail -f ${SERVER_DIR}/masterLog.0
fi