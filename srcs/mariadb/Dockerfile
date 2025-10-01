FROM alpine:3.18

RUN apk update && apk add mariadb

# Create folders and copy config
RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld /var/lib/mysql

# Copy entrypoint script
COPY tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY tools/my.cnf /etc/my.cnf

CMD ["/entrypoint.sh"]