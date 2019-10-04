# Minecraft Bedrock Server in Docker optimized for Unraid
This is a Basic Minecraft Bedrock Edition Server.
It will download the specified version of Minecraft Bedrock Edition.

If you want to update the server simply enter the version wich you want to download, you also can downgrade your server (no guarantee that it works if you downgrade much versions).

>**CONSOLE:** To connect to the console open up the terminal for this docker and type in: 'screen -xS Minecraft' (without quotes).

## Env params
| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefile | /serverdata/serverfiles |
| GAME_VERSION | Enter your preferred game version | 1.11.4.2 |
| GAME_PARAMS | Extra startup Parameters if needed (leave empty if not needed) | |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name MinecraftBedrockServer -d \
	-p 19132:19132 -p 19132:19132/udp \
	--env 'GAME_VERSION=1.11.4.2' \
	--env 'UID=99' \
	--env 'GID=100' \
	--volume /mnt/user/appdata/minecraftedrockserver:/serverdata/serverfiles \
	ich777/minecraftbedrockserver
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/