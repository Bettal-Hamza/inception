FROM alpine:3.21

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-json \
    php83-phar \
    php83-mbstring \
    php83-iconv \
    curl \
    mariadb-client

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN sed -i 's|127.0.0.1:9000|0.0.0.0:9000|' /etc/php83/php-fpm.d/www.conf

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]