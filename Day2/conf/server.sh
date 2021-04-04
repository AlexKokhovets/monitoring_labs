#!/bin/bash
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

sudo yum install -y wget

sudo yum install elasticsearch -y

sudo systemctl start elasticsearch.service

sudo systemctl restart elasticsearch.service

sudo yum install kibana -y
sudo systemctl daemon-reload
sudo systemctl start kibana.service

sudo firewall-cmd --permanent --zone=public --add-port=5601/tcp
sudo firewall-cmd --permanent --zone=public --add-port=9200/tcp
sudo firewall-cmd --reload

sudo sed -i '$ a \server.host: "0.0.0.0"' /etc/kibana/kibana.yml
sudo systemctl restart kibana.service

sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=2048
sudo /sbin/mkswap /var/swap.1
sudo chmod 600 /var/swap.1
sudo /sbin/swapon /var/swap.1

sudo wget https://artifacts.elastic.co/downloads/logstash/logstash-7.12.0-x86_64.rpm
sudo rpm -ivh logstash-*

sudo cp /tmp/sh/input.conf /etc/logstash/conf.d/input.conf
sudo cp /tmp/sh/filter.conf /etc/logstash/conf.d/filter.conf
sudo cp /tmp/sh/output.conf /etc/logstash/conf.d/output.conf

sudo systemctl start logstash