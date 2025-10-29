#!/bin/sh
set -e

# Wait for MariaDB to be ready
until mysql -h mariadb -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "USE $MYSQL_DATABASE;" &> /dev/null; do
    echo "Waiting for database $MYSQL_DATABASE..."
    sleep 2
done

cd /var/www/html

# Download WordPress if not exists
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    
    # Try wp-cli first, if it fails use curl
    if ! wp core download --allow-root 2>/dev/null; then
        echo "WP-CLI failed, downloading with curl..."
        curl -O https://wordpress.org/latest.tar.gz
        tar -xzf latest.tar.gz --strip-components=1
        rm latest.tar.gz
    fi
    
    echo "Creating wp-config.php..."
    wp config create \
      --dbname="$MYSQL_DATABASE" \
      --dbuser="$MYSQL_USER" \
      --dbpass="$MYSQL_PASSWORD" \
      --dbhost="mariadb:3306" \
      --allow-root
fi

# Install WordPress if tables are missing
if ! wp core is-installed --allow-root 2>/dev/null; then
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
