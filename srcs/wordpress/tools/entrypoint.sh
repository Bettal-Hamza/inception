#!/bin/sh

# Copy wp-config.php if not already there
if [ ! -f /var/www/html/wp-config.php ]; then
    sleep 5
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" /var/www/html/wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" /var/www/html/wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" /var/www/html/wp-config.php
    sed -i "s/localhost/mariadb:3306/" /var/www/html/wp-config.php
fi

# Run PHP-FPM in foreground
exec php-fpm81 --nodaemonize
