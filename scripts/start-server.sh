#!/bin/bash
export NWNX_SQL_TYPE=mysql
export NWNX_SQL_HOST=localhost
export NWNX_SQL_USERNAME=nwnee
export NWNX_SQL_PASSWORD=nwnee
export NWNX_SQL_DATABASE=nwnee
export NWNX_SQL_QUERY_METRICS=true
export NWNX_CORE_LOG_LEVEL=${LOG_LVL}
export NWNX_CORE_LOAD_PATH=/nwnx/binaries

CUR_V="$(find ${SERVER_DIR} -name build* | cut -d 'd' -f2)"
CUR_V_BIN="$(find ${SERVER_DIR} -name binariesbuild* | cut -d 'd' -f2)"
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
	if [ ! -d ${SERVER_DIR}/binaries ]; then
		mkdir ${SERVER_DIR}/binaries
	fi
	cd ${SERVER_DIR}/binaries
	if wget https://github.com/nwnxee/unified/releases/download/build${NWNEE_V}/NWNX-EE.zip ; then
		echo "---Sucessfully downloaded NWN:EE Binaries---"
	else
		echo "---Something went wrong, can't download NWN:EE Binaries, putting server in sleep mode---"
		sleep infinity
	fi
	unzip -o ${SERVER_DIR}/binaries/NWNX-EE.zip
	mv ${SERVER_DIR}/binaries/Binaries/* ${SERVER_DIR}/binaries
	rm -R ${SERVER_DIR}/binaries/Binaries
	touch ${SERVER_DIR}/binariesbuild${NWNEE_V}
	rm ${SERVER_DIR}/binaries/NWNX-EE.zip
fi

echo "---Server Version Check---"
if [ "${NWNEE_V}" != "$CUR_V" ]; then
	echo "---Version missmatch v$CUR_V installed, installing v${NWNEE_V}---"
    rm ${SERVER_DIR}/build$CUR_V
    rm -R ${SERVER_DIR}/bin
    rm -R ${SERVER_DIR}/data
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
elif [ "${NWNEE_V}" == "$CUR_V" ]; then
	echo "---Server versions match! Installed: v$CUR_V | Preferred: v${NWNEE_V}---"
fi

echo "---Binaries Version Check---"
if [ "${NWNEE_V}" != "$CUR_V_BIN" ]; then
	echo "---Version missmatch v$CUR_V_BIN installed, installing v${NWNEE_V}---"
    rm ${SERVER_DIR}/binariesbuild$CUR_V_BIN
    rm -R ${SERVER_DIR}/binaries
    mkdir ${SERVER_DIR}/binaries
	cd ${SERVER_DIR}/binaries
	if wget https://github.com/nwnxee/unified/releases/download/build${NWNEE_V}/NWNX-EE.zip ; then
		echo "---Sucessfully downloaded NWN:EE Binaries---"
	else
		echo "---Something went wrong, can't download NWN:EE Binaries, putting server in sleep mode---"
		sleep infinity
	fi
	unzip -o ${SERVER_DIR}/binaries/NWNX-EE.zip
	mv ${SERVER_DIR}/binaries/Binaries/* ${SERVER_DIR}/binaries
	rm -R ${SERVER_DIR}/binaries/Binaries
	touch ${SERVER_DIR}/binariesbuild${NWNEE_V}
	rm ${SERVER_DIR}/binaries/NWNX-EE.zip
elif [ "${NWNEE_V}" == "$CUR_V_BIN" ]; then
	echo "---Binaries versions match! Installed: v$CUR_V_BIN | Preferred: v${NWNEE_V}---"
fi

echo "---Prepare Server---"
echo "---Checking if everything is in place---"
if [ ! -d ${SERVER_DIR}/redis ]; then
	mkdir ${SERVER_DIR}/redis
fi
if [ ! -d ${SERVER_DIR}/user ]; then
	mkdir ${SERVER_DIR}/user
fi
if [ ! -d "${SERVER_DIR}/Neverwinter Nights" ]; then
	mkdir "${SERVER_DIR}/Neverwinter Nights"
fi
if [ ! -d "${SERVER_DIR}/Neverwinter Nights/modules" ]; then
	mkdir "${SERVER_DIR}/Neverwinter Nights/modules"
fi
if [ ! -d "${SERVER_DIR}/Neverwinter Nights/hak" ]; then
	mkdir "${SERVER_DIR}/Neverwinter Nights/hak"
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

if [ ! "$(ls -A "${SERVER_DIR}/Neverwinter Nights/modules")" ]; then
	echo "-----------------------------------------------------------------"
	echo "---------Your 'modules' folder is empty, please put your---------"
	echo "---required 'module' files in the 'Neverwinter Nights/modules'---"
	echo "------------folder and restart the container, putting------------"
    echo "---------------------server into sleep mode----------------------"
	echo "-----------------------------------------------------------------"
	sleep infinity
fi

cd ${SERVER_DIR}/bin/linux-x86
LD_PRELOAD=/nwnee/binaries/NWNX_Core.so ${SERVER_DIR}/bin/linux-x86/nwserver-linux -module "${MOD_NAME}" -maxclients ${MAX_CLIENTS} -minlevel ${MINLEVEL} -maxlevel ${MAXLEVEL} -pauseandplay ${PAUSEAPLAY} -pvp ${PVP} -servervault ${SERVERVAULT} -elc ${ELC} -ilr ${ILR} -oneparty ${ONEPARTY} -difficulty ${DIFF} -autosaveinterval ${AUTO_SAV_I} -playerpassword ${PPW} -adminpassword ${APWD} -servername "${SRV_NAME}" -publicserver ${PUBLIC_SRV} -reloadwhenempty ${RLD_W_E} -port ${GAME_PORT} -userdirectory "${SERVER_DIR}/Neverwinter Nights"