FROM ich777/debian-baseimage:bullseye_amd64

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-nwnee"

RUN apt-get update && \
	apt-get -y install --no-install-recommends gcc-10 g++-10 default-libmysqlclient-dev libpq-dev libseccomp-dev ruby-dev ant libluajit-5.1-2 curl unzip mariadb-server screen redis-server jq libbsd0 && \
	cd /tmp && \
	wget -q -nc --show-progress --progress=bar:force:noscroll -O /tmp/libsndio6.1_1.1.0-3_amd64.deb https://debian-archive.at.mirror.anexia.com/debian/pool/main/s/sndio/libsndio6.1_1.1.0-3_amd64.deb && \
	dpkg -i /tmp/libsndio6.1_1.1.0-3_amd64.deb && \
	rm /tmp/libsndio6.1_1.1.0-3_amd64.deb && \
	rm -R /usr/share/man/man1 && \
	rm -rf /var/lib/apt/lists/*

ENV SERVER_DIR="/nwnee"
ENV NWNEE_V="latest"
ENV MOD_NAME=""
ENV MAX_CLIENTS=4
ENV MINLEVEL=1
ENV MAXLEVEL=40
ENV PAUSEAPLAY=0
ENV PVP=0
ENV SERVERVAULT=0
ENV ELC=0
ENV ILR=0
ENV ONEPARTY=0
ENV DIFF=1
ENV AUTO_SAV_I=5
ENV PPW="Docker"
ENV APWD="adminDocker"
ENV SRV_NAME="Docker NWN:EE"
ENV PUBLIC_SRV=0
ENV RLD_W_E=1
ENV GAME_PARAMS=""
ENV GAME_PORT=5121
ENV LOG_LVL=6
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="nwnee"

RUN mkdir $SERVER_DIR && \
	useradd -d $SERVER_DIR -s /bin/bash $USER && \
	chown -R $USER $SERVER_DIR && \
	ulimit -n 2048 && \
	/etc/init.d/mariadb start && \
	mysql -u root -e "CREATE USER IF NOT EXISTS 'nwnee'@'%' IDENTIFIED BY 'nwnee';FLUSH PRIVILEGES;" && \
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS nwnee;" && \
	mysql -u root -e "GRANT ALL ON nwnee.* TO 'nwnee'@'%' IDENTIFIED BY 'nwnee';" && \
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'nwneeroot';FLUSH PRIVILEGES;"

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]