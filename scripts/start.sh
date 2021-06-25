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
chown -R root:${GID} /opt/scripts
chmod -R 750 /opt/scripts
chown -R ${UID}:${GID} /var/lib/mysql
chown -R ${UID}:${GID} /var/run/mysqld
chown -R ${UID}:${GID} /var/lib/redis
chown -R ${UID}:${GID} /usr/bin/redis-server
chown -R ${UID}:${GID} /usr/bin/redis-cli
chmod -R 770 /var/lib/mysql
chmod -R 770 /var/run/mysqld
chown -R ${UID}:${GID} ${SERVER_DIR}

term_handler() {
	screenpid="$(su $USER -c "screen -list | grep "Detached" | grep "nwnee" | cut -d '.' -f1")"
	su $USER -c "screen -S nwnee -X stuff 'exit^M'" >/dev/null
	tail --pid="${screenpid//[[:blank:]]/}" -f 2>/dev/null
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