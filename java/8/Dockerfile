FROM ubuntu:22.04

ADD https://download.oracle.com/java/GA/jdk8/1.8.0_471-b09/jdk-8u471-linux-x64.tar.gz /tmp/

RUN tar -xzf /tmp/jdk-8u471-linux-x64.tar.gz -C /opt/ \
    && rm /tmp/jdk-8u471-linux-x64.tar.gz \
    && update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_471/bin/java 1

ENV JAVA_HOME=/opt/jdk1.8.0_471
ENV PATH=$JAVA_HOME/bin:$PATH

LABEL       author="Drysius" maintainer="danielolxlol@gmail.com"

LABEL       org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL       org.opencontainers.image.licenses=MIT

RUN 		apt-get update -y \
 			&& apt-get install -y lsof curl ca-certificates zip unzip openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 \
 			&& useradd -d /home/container -m container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./../entrypoint.sh /entrypoint.sh
CMD         [ "/bin/bash", "/entrypoint.sh" ]
