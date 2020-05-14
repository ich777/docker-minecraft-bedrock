#!/bin/bash
echo "---Checking if UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Checking if GID: ${GID} matches user---"
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
if [ -f /opt/scripts/user.sh ]; then
	echo "---Found optional script, executing---"
	chmod +x /opt/scripts/user.sh
	/opt/scripts/user.sh
else
	echo "---No optional script found, continuing---"
fi

echo "---Starting...---"
chown -R ${UID}:${GID} /opt/scripts
chown -R ${UID}:${GID} ${DATA_DIR}
killpid=0
term_handler() {
	if [ $killpid -ne 0 ]; then
		screenpid="$(su $USER -c "screen -list | grep "Detached" | grep "Minecraft" | cut -d '.' -f1")"
		su $USER -c "screen -S Minecraft -X stuff 'stop^M'" >/dev/null
		while [ -e /proc/${screenpid//[[:blank:]]/} ]
		do
			sleep 1
		done
		echo "---Shutdown successful!---"
		sleep 0.5
	fi
	exit 143;
}

trap 'kill ${!}; term_handler' SIGTERM
su ${USER} -c "/opt/scripts/start-server.sh" &
killpid="$!"
while true
do
	wait $killpid
	exit 0;
done