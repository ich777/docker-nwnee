FROM ubuntu

MAINTAINER ich777

RUN apt-get update
RUN apt-get -y install gcc-6 g++-6 libmysqlclient-dev libpq-dev libseccomp-dev ruby-dev ant wget curl unzip mariadb-server screen redis-server

ENV SERVER_DIR="/serverfiles"
ENV NWNEE_V="latest"
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
ENV UMASK=000
ENV UID=99
ENV GID=100

RUN mkdir $SERVER_DIR
RUN useradd -d $SERVER_DIR -s /bin/bash --uid $UID --gid $GID nvnee
RUN chown -R nvnee $SERVER_DIR

RUN ulimit -n 2048

RUN /etc/init.d/mysql start && \
	mysql -u root -e "CREATE USER IF NOT EXISTS 'nwnee'@'%' IDENTIFIED BY 'nwnee';FLUSH PRIVILEGES;" && \
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS nwnee;" && \
	mysql -u root -e "GRANT ALL ON nwnee.* TO 'nwnee'@'%' IDENTIFIED BY 'nwnee';" && \
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'nwneeroot';FLUSH PRIVILEGES;"

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/
RUN chown -R nvnee /opt/scripts
RUN chown -R nvnee:users /var/lib/mysql
RUN chmod -R 770 /var/lib/mysql
RUN chown -R nvnee:users /var/run/mysqld
RUN chmod -R 770 /var/run/mysqld
RUN chown -R nvnee /var/lib/redis
RUN chown -R nvnee /usr/bin/redis-server
RUN chown -R nvnee /usr/bin/redis-cli

USER nvnee

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]