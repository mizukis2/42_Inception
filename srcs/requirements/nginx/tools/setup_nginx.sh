#!/bin/bash

set -e

mkdir -p /etc/nginx/ssl

if [ ! -f /etc/nginx/ssl/server.crt ]; then
    openssl req -x509 -noenc -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/C=NL/ST=NoordHolland/L=Amsterdam/O=Codam/OU=Inception/CN=${DOMAIN_NAME}"
fi

envsubst '${DOMAIN_NAME}' \
    < /etc/nginx/templates/default.conf.template \
    > /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
