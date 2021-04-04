#!/bin/bash
sudo yum install -y wget

cd /opt

sudo wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz
sudo tar -xzf prometheus-2.26.0.linux-amd64.tar.gz

sudo useradd prometheus
sudo chmod -R 755 prometheus-2.26.0.linux-amd64
sudo chown -R prometheus:prometheus prometheus-2.26.0.linux-amd64

sudo cp /tmp/conf/prometheus.service /etc/systemd/system/prometheus.service

sudo systemctl daemon-reload
sudo systemctl start prometheus.service

sudo wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.18.0/blackbox_exporter-0.18.0.linux-amd64.tar.gz
sudo tar -xzf blackbox_exporter-0.18.0.linux-amd64.tar.gz

sudo chown -R prometheus:prometheus blackbox_exporter-0.18.0.linux-amd64.tar.gz

sudo cp /tmp/conf/blackbox.service /etc/systemd/system/blackbox.service
sudo systemctl daemon-reload

sudo systemctl start blackbox.service

sudo systemctl restart prometheus.service

sudo yum install grafana -y
sudo systemctl start grafana-server