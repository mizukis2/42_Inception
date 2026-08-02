#!/bin/bash

# 1. Check: has the database already been initialized before?
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # 2. First run - do the one-time setup
    #    - initialize the base MariaDB system tables
    #    - create your wordpress database
    #    - create your two users
    #    - set their passwords/privileges
    echo "First run - initializing database..."
    # ... your setup commands / .sql script go here
fi

# 3. Always, every time - actually start the server in the foreground
exec mysqld
