#!/bin/bash
while true
do
	if ! pgrep bedrock_server >/dev/null ; then
		kill "$(pidof tail)"
		exit 0
	fi
	sleep 60
done