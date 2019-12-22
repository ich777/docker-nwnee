#!/bin/bash
sleep infintiy

export NWNX_DOTNET_SKIP=y
export LD_PRELOAD="./NWNX_Core.so"
export NWNX_METRICS_INFLUXDB_HOST=127.0.0.1
export NWNX_METRICS_INFLUXDB_PORT=3306
export NWNX_REDIS_HOST=127.0.0.1
export NWNX_SQL_USERNAME=nwnee
export NWNX_SQL_PASSWORD=nwnee
export NWNX_SQL_DATABASE=nwnee
CUR_V="$(find ${SERVER_DIR} -name build* | cut -d 'd' -f2)"
CUR_V_BIN="$(find ${SERVER_DIR} -name binaries* | cut -d 's' -f2)"
LAT_V="$(curl -s https://api.github.com/repos/nwnxee/unified/releases/latest | grep tag_name | cut -d '"' -f4 | cut -d 'd' -f2)"
if [ "${NWNEE_V}" == "latest" ]; then
	NWNEE_V=$LAT_V
fi
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Starting MariaDB...---"
screen -S MariaDB -L -Logfile ${SERVER_DIR}/MariaDBLog.0 -d -m mysqld_safe
sleep 5

echo "---Starting Redis Server---"
screen -S RedisServer -L -Logfile ${SERVER_DIR}/RedisLog.0 -d -m /usr/bin/redis-server
sleep 5

if [ -z "$CUR_V" ]; then
	echo "---NWN:EE Dedicated Server not found, installing v${NWNEE_V}!---"
	cd ${SERVER_DIR}
	if wget https://nwnx.io/nwnee-dedicated-${NWNEE_V}.zip ; then
		echo "---Sucessfully downloaded NWN:EE Dedicated Server---"
	else
		echo "---Something went wrong, can't download NWN:EE Dedicated Server, putting server in sleep mode---"
		sleep infinity
	fi
	unzip -o ${SERVER_DIR}/nwnee-dedicated-${NWNEE_V}.zip
	touch ${SERVER_DIR}/build${NWNEE_V}
    rm ${SERVER_DIR}/nwnee-dedicated-${NWNEE_V}.zip
fi

if [ -z "$CUR_V_BIN" ]; then
	echo "---NWN:EE Binaries not found, installing v${NWNEE_V}!---"
	cd ${SERVER_DIR}/bin/linux-x86
	if wget https://github.com/nwnxee/unified/releases/download/build${NWNEE_V}/NWNX-EE.zip ; then
		echo "---Sucessfully downloaded NWN:EE Dedicated Server---"
	else
		echo "---Something went wrong, can't download NWN:EE Dedicated Server, putting server in sleep mode---"
		sleep infinity
	fi
	unzip -o ${SERVER_DIR}/bin/linux-x86/NWNX-EE.zip
    mv ${SERVER_DIR}/bin/linux-x86/Binaries/* ${SERVER_DIR}/bin/linux-x86
    rm -R ${SERVER_DIR}/bin/linux-x86/Binaries
	touch ${SERVER_DIR}/binaries${NWNEE_V}
    rm ${SERVER_DIR}/bin/linux-x86/NWNX-EE.zip
fi

echo "---Prepare Server---"
echo "---Checking if everything is in place---"
if [ ! -d ${SERVER_DIR}/redis ]; then
	mkdir ${SERVER_DIR}/redis
fi
if [ ! -d ${SERVER_DIR}/user ]; then
	mkdir ${SERVER_DIR}/user
fi
echo "---Configuring Redis---"
sleep 5
echo "CONFIG SET dir ${SERVER_DIR}/redis" | redis-cli
echo "CONFIG SET dbfilename redis.rdb" | redis-cli
echo "BGSAVE" | redis-cli
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "MariaDBLog.0" -exec rm -f {} \;
find ${SERVER_DIR} -name "RedisLog.0" -exec rm -f {} \;

chmod -R 777 ${SERVER_DIR}

echo "---Start Server---"
cd ${SERVER_DIR}/bin/linux-x86
${SERVER_DIR}/bin/linux-x86/nwserver-linux -maxclients ${MAX_CLIENTS} -minlevel ${MINLEVEL} -maxlevel ${MAXLEVEL} -pauseandplay ${PAUSEAPLAY} -pvp ${PVP} -servervault ${SERVERVAULT} -elc ${ELC} -ilr ${ILR} -oneparty ${ONEPARTY} -difficulty ${DIFF} -autosaveinterval ${AUTO_SAV_I} -playerpassword ${PPW} -adminpassword ${APWD} -servername ${SRV_NAME} -publicserver ${PUBLIC_SRV} -reloadwhenempty ${RLD_W_E} -port ${GAME_PORT} -userdirectory ${SERVER_DIR}/user