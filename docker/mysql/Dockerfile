FROM ubuntu:16.04

ADD image /image

RUN /image/install.sh

#COPY /image/init_database.sql /usr/local/bin/init_database.sh

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

CMD ["mysqld"]
