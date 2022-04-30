# NeverwinterNights-EE Dedicated Server in Docker optimized for Unraid
This Docker will download and install Neverwinter Nights: Enhanced Edition and run it (by default this container has a MariaDB and Redis Server integrated).

**First Start:** Enter the Module name to load in the variable down below (without the .mod extension) start the container and wait for it until the log displays the message that the modules folder is empty, stop the container and place your mod file in the folder (.../Neverwinter Nights/modules) and restart the container (You can also place a mod file from your local installed game into the server eg.: .../Neverwinter Nights/data/mod/Contest of Champions 0492).

**ATTENTION:** First Startup can take very long since it downloads the gameserver files!

**Update Notice:** Simply restart the container if a newer version of the game is available.

**CONSOLE:** To connect to the console open up the terminal on the host machine and type in: 'docker exec -u nwnee -ti NAMEOFYOURCONTAINER screen -xS nwnee' (without quotes) to exit the screen session press CTRL+A and then CTRL+D or simply close the terminal window in the first place.


## Env params

| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefiles | /nwnee |
| LOG_LVL | Set the log level (from 2=only fatal errors to 7=very verbose) | 4 |
| MOD_NAME | Enter the module name to load here (located in your serverdirectory 'Neverwinter Nights/modules' without the .mod extension) | YOURMODULENAMEHERE |
| MAX_CLIENTS | Set the maximum number of connections to the game server. | 4 |
| MINLEVEL | Set the minimum character level required by the server. | 1 |
| MAXLEVEL | Set the maximum character level allowed by the server. | 40 |
| PAUSEAPLAY | Set if a player or DM can pause the game (0 = game can only be paused by DM, 1 = game can by paused by players) | 0 |
| PVP | Set wich PVP mode do you want (0 = none, 1 = party, 2 = full) | 0 |
| SERVERVAULT | Set if local or server characters (0 = local characters only. 1 = server characters only) | 0 |
| ELC | Set enforcing legal characters (0 = don't enforce legal characters, 1 = do enforce legal characters) | 0 |
| ILR | Set enforcing item level restriction (0 = don't enforce item level restrictions, 1 = do enforce item level restrictions) | 0 |
| ONEPARTY | Set if one or more parties are allowed (0 = allow only one party, 1 = allow multiple parties) | 0 |
| DIFF | Set difficutly (1 = easy, 2 = normal, 3 = D&D hardcore, 4 = very difficult) | 1 |
| AUTO_SAV_I | Set how frequently (in minutes) to autosave. 0 disables autosave. | 5 |
| SRV_NAME | Set the name this server appears as in the mulitplayer game listing. | Docker NWNEE |
| PPW | Set the password required by players to join the game. | Docker |
| APWD | Set the password required to remotely administer the game. Currently unused. | adminDocker |
| PUBLIC_SRV | Set if you want to list the game publicly (0 = do not list server with the matching service. 1 = list server with the matching service). | 0 |
| RLD_W_E | Restart module if server becomes empty (0 = module state is persistant as long as server is running, 1 = module state is reset when the server becomes empty). | 0 |
| GAME_PARAMS | Enter your extra game startup parameters if needed here (eg: '-dmpassword supersecretpassword -quiet' without quotes). | empty |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

# Run example
```
docker run --name NeverwinterNights-EE -d \
   -p 5121:5121/udp \
   --env 'LOG_LVL=4' \
   --env 'MOD_NAME=YOURMODULENAMEHERE' \
   --env 'MAX_CLIENTS=4' \
   --env 'MINLEVEL=1' \
   --env 'MAXLEVEL=40' \
   --env 'PAUSEAPLAY=0' \
   --env 'PVP=0' \
   --env 'SERVERVAULT=4' \
   --env 'ELC=0' \
   --env 'ILR=0' \
   --env 'ONEPARTY=0' \
   --env 'DIFF=1' \
   --env 'AUTO_SAV_I=5' \
   --env 'SRV_NAME=Docker NWNEE' \
   --env 'PPW=Docker' \
   --env 'APWD=adminDocker' \
   --env 'PUBLIC_SRV=0' \
   --env 'RLD_W_E=0' \
   --env 'UID=99' \
   --env 'GID=100' \
   --env 'BASIC_URL=https://dl.xonotic.org/' \
   --volume /path/to/nwnee:/nwnee \
   --restart=unless-stopped \
   ich777/nwnee-server
```

This Docker was mainly created for the use with Unraid, if you don’t use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/