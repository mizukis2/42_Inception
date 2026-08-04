#!/bin/bash

set -e

echo "Starting MariaDB container"

mkdir -p /run/mysqld

chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Database not initialized. Running setup..."

    mariadb-install-db --user=mysql
    
    mysqld --user=mysql --skip-networking &
    until mysqladmin ping -u root --silent; do
        sleep 1
    done

    mysql -u root <<-EOSQL
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL

    mysqladmin -u root shutdown

    echo "Database initialized."

else
    echo "DATABASE ALREADY EXISTS: Skipping initialization"

fi

echo "Starting MariaDB server"

exec mysqld --user=mysql

