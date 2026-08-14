#!/bin/bash

set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req -x509 -noenc -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=NL/ST=NoordHolland/L=Amsterdam/O=Codam/OU=Inception/CN=mmatsui.42.fr"
fi

exec nginx -g "daemon off;"
