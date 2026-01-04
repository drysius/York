FROM ubuntu:22.04

# Configurar ambiente não interativo
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

LABEL author="Drysius" maintainer="danielolxlol@gmail.com"
LABEL org.opencontainers.image.source="https://github.com/drysius/York"
LABEL org.opencontainers.image.licenses=MIT

RUN apt-get update -y \
    && apt-get install -y wget curl ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN cp ./jre-8u471-linux-x64.tar.gz /tmp/jre8.tar.gz  \
    && tar -xzf /tmp/jre8.tar.gz -C /opt/ \
    && rm /tmp/jre8.tar.gz \
    && mv /opt/jre1.8.0_471/ /opt/jre1.8.0_471

ENV JAVA_HOME=/opt/jre1.8.0_471
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apt-get update -y \
    && apt-get install -y lsof zip unzip openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Verificar instalação
RUN java -version

RUN useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh
CMD ["/bin/bash", "/entrypoint.sh"]
