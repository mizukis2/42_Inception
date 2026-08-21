#!/bin/bash

set -e

echo "Starting MariaDB container"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Database not initialized. Running setup..."

    mariadb-install-db --user=mysql
    mariadbd --user=mysql --skip-networking &

    until mariadb-admin ping -u root --silent; do
        sleep 1
    done

    echo "Temporary server ready. Setting root password..."

    MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
    mariadb -u root <<-EOSQL
        ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    EOSQL

    echo "Root password set. Creating database and user..."

    MYSQL_PASSWORD="$(cat /run/secrets/db_password)"

    mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

    echo "Database initialized."

else
    echo "DATABASE ALREADY EXISTS: Skipping initialization"

fi

echo "Starting MariaDB server"
exec mariadbd --user=mysql

