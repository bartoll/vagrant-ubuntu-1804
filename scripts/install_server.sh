#!/bin/bash

#set -x

# Set timezone
sudo timedatectl set-timezone 'Europe/Warsaw'

# Adding universe repo
sudo apt-get update

# Install system tools
sudo -u root -H apt-get install -y apt-rdepends mc curl meld git jq

# install Apache 2.4
sudo apt-get install -y apache2

# Switch from event to worker
sudo a2dismod mpm_event
sudo a2enmod mpm_worker

# Install PHP 7.2 with extensions
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update

sudo apt-get install -y php7.2 php7.2-fpm php7.2-cli php7.2-common php7.2-mysql php7.2-opcache php7.2-bcmath php7.2-curl php7.2-gd php7.2-intl php7.2-mbstring php7.2-soap php7.2-xsl php7.2-zip php7.2-json  

# Install APCu cache
sudo apt-get -y install php7.2-opcache php-apcu

# Install deprecated mcrypt.so library
sudo apt-get install -y php-pear
sudo apt-get install -y php7.2-dev
sudo apt-get install -y gcc make autoconf libc-dev pkg-config
sudo apt-get install -y libmcrypt-dev
println "\n" | sudo pecl install mcrypt-1.0.1

# Enable modules
sudo a2enmod proxy_fcgi vhost_alias rewrite ssl setenvif macro info status

# Enable config
sudo a2enconf php7.2-fpm.conf

# Restart Apache & PHP
sudo service apache2 restart
sudo service php7.2-fpm restart

# Install system tools
sudo apt-get install -y composer

# Install MySQL
mysql_username='root'
mysql_password='root'
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_password"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_password"
sudo apt-get install -y mysql-server mysql-common mysql-client

# Install Letsencrypt certbot script
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y python-certbot-apache

# Install OVH plugin for dns ACME challenge
sudo apt-get install -y python3-pip
sudo -H pip3 install certbot-dns-ovh

# Restart Apache
sudo service apache2 restart
sudo service php7.2-fpm restart
sudo service mysql restart

echo "----------------------------"
echo "VPS Server has been installed for you"
echo "----------------------------"


