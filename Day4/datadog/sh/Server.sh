#!/bin/bash

sudo setenforce 0

sudo systemctl stop firewalld

sudo DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=96d6784d8fdd8ef20a543fe52eeacde8 DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

sudo mkdir /etc/datadog-agent/conf.d/logs.d
cat << EOF | sudo tee /etc/datadog-agent/conf.d/logs.d/conf.yaml
logs:
  - type: file
    service: tomcat
    source: tomcat
    path: /var/log/tomcat/*
EOF

sudo chown dd-agent:dd-agent -R /etc/datadog-agent/conf.d/logs.d/

sudo sed -i '/logs_enabled/a logs_enabled: true' /etc/datadog-agent/datadog.yaml

sudo yum install -y tomcat tomcat-webapps tomcat-admin-webapps
sudo chmod -R 775 /var/log/tomcat

sudo systemctl enable tomcat
sudo systemctl restart tomcat

sudo systemctl enable datadog-agent
sudo systemctl restart datadog-agent