#!/bin/sh
set -e

# Wait for MariaDB to be ready
until mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "USE $MYSQL_DATABASE;" &> /dev/null; do
    echo "Waiting for database $MYSQL_DATABASE..."
    sleep 2
done

cd /var/www/html

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."
    wp config create \
      --dbname="$MYSQL_DATABASE" \
      --dbuser="$MYSQL_USER" \
      --dbpass="$MYSQL_PASSWORD" \
      --dbhost="mariadb:3306" \
      --allow-root
fi

# Install WordPress if tables are missing
if ! wp db tables --allow-root | grep -q "wp_posts"; then
    echo "Installing WordPress..."
    wp core install \
      --url="https://$DOMAIN_NAME" \
      --title="$WP_TITLE" \
      --admin_user="$WP_ADMIN_N" \
      --admin_password="$WP_ADMIN_P" \
      --admin_email="$WP_ADMIN_E" \
      --skip-email \
      --allow-root

    echo "Creating additional WordPress user..."
    wp user create "$WP_U_NAME" "$WP_U_EMAIL" \
      --role="$WP_U_ROLE" \
      --user_pass="$WP_U_PASS" \
      --allow-root
fi

# Run php-fpm
exec php-fpm81 -F
