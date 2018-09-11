FROM ubuntu:16.04

ADD image /image

RUN /image/install.sh

VOLUME ["/var/lib/mysql"]

EXPOSE 3306

CMD ["mysqld"]
