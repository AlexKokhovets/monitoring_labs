#!/bin/bash

IP=${1}

sudo yum install tomcat -y
sudo yum install tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp tomcat-javadoc -y

sudo systemctl start tomcat
sudo systemctl enable tomcat
sudo chown -R tomcat:tomcat /var/log/tomcat

sudo cp /tmp/conf/clusterjsp.war /usr/share/tomcat/webapps

sudo yum install logstash -y

sudo usermod -a -G tomcat logstash

sudo systemctl start logstash.service

sed -i "s|ADDRESS|$IP|g" /tmp/conf/es.conf
sudo cp /tmp/conf/es.conf /etc/logstash/conf.d/es.conf

sudo systemctl restart logstash.service