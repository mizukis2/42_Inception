FROM debian:bookworm
RUN apt update && apt install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/mysql/*

COPY ./conf/mariadb.cnf /etc/mysql/mariadb.cnf
COPY ./tools/setup_mariadb.sh /setup_mariadb.sh

RUN chmod +x /setup_mariadb.sh

EXPOSE 3306

ENTRYPOINT ["/setup_mariadb.sh"]