#!/bin/bash
echo "---Ensuring UID: ${UID} matches user---"
usermod -u ${UID} ${USER}
echo "---Ensuring GID: ${GID} matches user---"
groupmod -g ${GID} ${USER} > /dev/null 2>&1 ||:
usermod -g ${GID} ${USER}
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for optional scripts---"
cp -f /opt/custom/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:
cp -f /opt/scripts/user.sh /opt/scripts/start-user.sh > /dev/null 2>&1 ||:

if [ -f /opt/scripts/start-user.sh ]; then
    echo "---Found optional script, executing---"
    chmod -f +x /opt/scripts/start-user.sh ||:
    /opt/scripts/start-user.sh || echo "---Optional Script has thrown an Error---"
else
    echo "---No optional script found, continuing---"
fi

echo "---Taking ownership of data...---"
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

echo "---Starting...---"
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