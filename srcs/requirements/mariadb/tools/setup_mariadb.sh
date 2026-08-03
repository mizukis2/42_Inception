#!/bin/bash

echo "Starting MariaDB container"

mkdir -p /run/mysqld

chown -R mysql:mysql /run/mysqld

# 1. Check: has the database already been initialized before?
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql
    
    mariadb --user=mysql &
    until mysqladmin ping -u root --silent; do
        sleep 1
    done

    mysql -u root <<-EOSQL
        CREATE DATABASE wordpress;
        CREATE USER 'wp_user'@'%' IDENTIFIED BY 'password';
        GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
    EOSQL

    mysqladmin -u root shutdown
fi

exec mysqld --user=mysql


#database name, user, password will be replaced as env or secret
