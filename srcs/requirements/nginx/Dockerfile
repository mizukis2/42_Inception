FROM debian:bookworm

RUN apt update && apt install -y nginx openssl \
    && rm -rf /var/lib/apt/lists/*

COPY ./tools/setup_nginx.sh /setup_nginx.sh

RUN chmod +x /setup_nginx.sh

EXPOSE 443

ENTRYPOINT ["/setup_nginx.sh"]