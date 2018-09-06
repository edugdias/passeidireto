#!/bin/bash 
set -e

######### Basic packages installation

apt-get update
apt-get install -y wget gzip debconf-utils sysv-rc-conf

######### MySQL 5.7 installation

export DEBIAN_FRONTEND=noninteractive
apt-get update 
apt-get install -y mysql-server

mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

sysv-rc-conf mysql on
        
sed -i.bkp 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf

service mysql start

mysql -u root < /image/init_database.sql

service mysql stop
