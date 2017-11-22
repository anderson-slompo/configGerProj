#!/bin/bash

BASEDIR=$(dirname "$0")

echo "Iniciando Instalação ProMind"

if [[ $(id -u) -ne 0 ]] ; then echo "Por favor executar como root" ; exit 1 ; fi

#pacotes do PHP
apt install php-apc \
php-pear \
php5 \
php5-apcu \
php5-cli \
php5-common \
php5-curl \
php5-dev \
php5-fpm \
php5-gd \
php5-json \
php5-mcrypt \
php5-memcache \
php5-memcached \
php5-mysql \
php5-pgsql \
php5-readline \
php5-xdebug \
pkg-php-tools \
libpcre3-dev \
gcc \
make \
git -y

#instalação phalcon PHP
cd cphalcon/build
./install

#memcached
apt install memcached -y

#NGINX
apt install nginx \
nginx-common \
nginx-core -y

#postgres
apt install postgresql-9.3 postgresql-client-9.3 -y

#configurações
cd $BASEDIR
cp -f etc/php-fpm/www.conf /etc/php5/fpm/pool.d/
rm -f /etc/nginx/nginx.conf
rm -f /etc/nginx/conf.d/*
cp -rf etc/nginx/* /etc/nginx/

service php-fpm restart
service nginx restart

cd /var/www/html/

git clone https://github.com/anderson-slompo/wsGerProj.git wsProMind
git clone https://github.com/anderson-slompo/cliGerProj.git cliProMind

chown www-data:www-data * -rf

echo "127.0.0.1 localhost.clipromind localhost.wspromind" >> /etc/hosts

sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'senha';"
service postgresql restart

#criação da base de dados

sudo -u postgres psql -c "CREATE DATABASE promind_novo WITH OWNER = postgres ENCODING = 'UTF8' LC_COLLATE = 'pt_BR.UTF-8';"
sudo -u postgres psql -d promind_novo -a -f /var/www/html/wsProMind/sql/full.sql


echo "Instalação OK"