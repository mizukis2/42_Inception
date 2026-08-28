FROM debian:bookworm
RUN apt update && apt install -y \
    php-fpm \
    php-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer

RUN wget https://github.com/vrana/adminer/releases/download/v6.0.1/adminer-6.0.1.php \
    -O /var/www/adminer/adminer.php

RUN chmod 644 /var/www/adminer/adminer.php

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

CMD ["php-fpm8.2", "-F"]