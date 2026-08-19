#!/bin/bash

set -e

echo "Starting WordPress container"

echo "Waiting for MariaDB to be ready..."

until mariadb-admin ping -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    sleep 1
done

echo "MariaDB is ready!"
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp config create --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" --dbhost=mariadb \
        --path=/var/www/html --allow-root
    wp core install --url=https://mmatsui.42.fr --title=inception \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --path=/var/www/html --allow-root
       
    echo "WordPress is initialized."

else
    echo "WordPress already initialized. Skipping setup."

fi

echo "Starting PHP-FPM..."

exec php-fpm8.2 -F
