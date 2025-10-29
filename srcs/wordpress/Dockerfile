FROM alpine:3.18

RUN apk update && apk add --no-cache \
    php81 \
    php81-fpm \
    php81-phar \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    curl \
    mariadb-client

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Make php-fpm listen on all interfaces
RUN sed -i 's|127.0.0.1:9000|0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf

CMD ["/entrypoint.sh"]