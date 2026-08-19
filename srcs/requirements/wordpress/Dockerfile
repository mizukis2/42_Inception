FROM debian:bookworm
RUN apt update && apt install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-xml \
    php-zip \
    wget \
    tar \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

#tar could be removed if there is in debian:bookworm by default    

WORKDIR /var/www/html

RUN wget https://wordpress.org/wordpress-7.0.3.tar.gz

RUN tar -xzvf wordpress-7.0.3.tar.gz --strip-components=1 && \
    rm wordpress-7.0.3.tar.gz

RUN chown -R www-data:www-data /var/www/html

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

RUN chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp 

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./tools/setup_wordpress.sh /setup_wordpress.sh

RUN chmod +x /setup_wordpress.sh

EXPOSE 9000

ENTRYPOINT ["/setup_wordpress.sh"]