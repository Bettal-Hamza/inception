FROM alpine:3.18

RUN apk add --no-cache \
    php81 php81-fpm php81-mysqli \
    curl mariadb-client

RUN mkdir -p /run/php

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Make php-fpm listen on all interfaces
RUN sed -i 's|127.0.0.1:9000|0.0.0.0:9000|' /etc/php81/php-fpm.d/www.conf

CMD ["/entrypoint.sh"]