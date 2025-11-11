FROM alpine:3.21

RUN apk update && apk add mariadb mariadb-client

RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY tools/my.cnf /etc/my.cnf

CMD ["/entrypoint.sh"]