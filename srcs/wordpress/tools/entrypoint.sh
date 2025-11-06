#!/bin/sh

until mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "USE $MYSQL_DATABASE;" 2>/dev/null; do
    sleep 2
done

cd /var/www/html

if [ ! -f wp-config.php ]; then
    wp core download --allow-root
    
    wp config create \
      --dbname="$MYSQL_DATABASE" \
      --dbuser="$MYSQL_USER" \
      --dbpass="$MYSQL_PASSWORD" \
      --dbhost="mariadb:3306" \
      --allow-root
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    wp core install \
      --url="https://$DOMAIN_NAME" \
      --title="$WP_TITLE" \
      --admin_user="$WP_ADMIN_N" \
      --admin_password="$WP_ADMIN_P" \
      --admin_email="$WP_ADMIN_E" \
      --allow-root

    wp user create "$WP_U_NAME" "$WP_U_EMAIL" \
      --role="$WP_U_ROLE" \
      --user_pass="$WP_U_PASS" \
      --allow-root
fi

exec php-fpm83 -F
