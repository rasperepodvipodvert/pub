FROM linuxserver/duplicati

RUN apt update \
    && apt install -y \
    mysql-client

RUN chown abc:abc /backups