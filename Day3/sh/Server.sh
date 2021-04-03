#!/bin/bash

# Intall expect to make input automatic
sudo yum install expect -y

# Set SELinux to permissive mode
sudo setenforce 0 && sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

# Install and enable httpd
sudo dnf -y install @httpd
sudo systemctl enable --now httpd

# Install Zabbix server and agent
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/8/x86_64/zabbix-release-5.0-1.el8.noarch.rpm
sudo dnf clean all
sudo dnf -y install zabbix-server-mysql zabbix-web-mysql zabbix-apache-conf zabbix-agent

# Install Maria DB
sudo dnf -y install mariadb-server && sudo systemctl start mariadb && sudo systemctl enable mariadb

# Set root password for database with automatic input
sudo ./DatabaseExpect.sh

# Create database
sudo mysql -uroot -p'alex' -e "create database zabbix character set utf8 collate utf8_bin;"
sudo mysql -uroot -p'alex' -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbixDBpass';"

# To avoid MySQL error “ERROR 1118 (42000) at line 1284: Row size too large (> 8126)” 
sudo mysql -uroot -p'alex' zabbix -e "set global innodb_strict_mode='OFF';"

# Import database shema for Zabbix sever
sudo zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p'zabbixDBpass' zabbix

# Enable strict mode
sudo mysql -uroot -p'alex' zabbix -e "set global innodb_strict_mode='ON';"

# Set database password in configuration file
sudo sh -c "echo 'DBPassword=zabbixDBpass'>> /etc/zabbix/zabbix_server.conf"

# Start Zabbix server
sudo systemctl restart zabbix-server 
sudo systemctl enable zabbix-server

# Configure firewall
sudo firewall-cmd --add-service={http,https} --permanent
sudo firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent
sudo firewall-cmd --reload

# Set timezone to php-fpm
sudo sh -c "echo 'php_value[date.timezone] = Europe/Moscow' >> /etc/php-fpm.d/zabbix.conf"

# Restart server 
sudo systemctl restart httpd php-fpm
sudo systemctl enable httpd php-fpm

# Restart agent
sudo systemctl enable zabbix-agent.service
sudo systemctl restart zabbix-agent.service