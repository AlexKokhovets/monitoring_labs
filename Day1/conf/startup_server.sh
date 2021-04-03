#!/bin/bash

PASSWORD=${1}

sudo yum install -y --disablerepo=google-cloud-sdk --disablerepo=google-compute-engine openldap openldap-servers openldap-clients
sudo systemctl start slapd
sudo systemctl enable slapd

sudo slappasswd -s ${PASSWORD} > hash
sudo sed -i "s%PASSWORD%$(cat hash)%" /tmp/conf/ldaprootpasswd.ldif /tmp/conf/ldapdomain.ldif /tmp/conf/ldapuser.ldif

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/conf/ldaprootpasswd.ldif
sudo cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
sudo chown -R ldap:ldap /var/lib/ldap/
sudo systemctl restart slapd

sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif 
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/conf/ldapdomain.ldif

sudo ldapadd -w ${PASSWORD} -x -D "cn=Manager,dc=devopslab,dc=com" -f /tmp/conf/baseldapdomain.ldif
sudo ldapadd -w ${PASSWORD} -x -D "cn=Manager,dc=devopslab,dc=com" -f /tmp/conf/ldapgroup.ldif
sudo ldapadd -w ${PASSWORD} -x -D "cn=Manager,dc=devopslab,dc=com" -f /tmp/conf/ldapuser.ldif

sudo yum install --disablerepo=google-cloud-sdk --disablerepo=google-compute-engine -y epel-release
sudo yum install --disablerepo=google-cloud-sdk --disablerepo=google-compute-engine -y phpldapadmin
sudo sed -i "397s%// %%" /etc/phpldapadmin/config.php
sudo sed -i "398s%^%// %" /etc/phpldapadmin/config.php
sudo sed -i "s/Require local/Require all granted/g" /etc/httpd/conf.d/phpldapadmin.conf

sudo systemctl restart httpd