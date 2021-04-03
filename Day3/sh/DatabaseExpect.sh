#!/bin/expect -f
spawn mysql_secure_installation
expect "Enter current password for root (enter for none):\r"
send -- "\r"
expect "Set root password? \[Y\/n\]\r"
send -- "Y\r"
expect "New password:\r"
send -- "alex\r"
expect "Re-enter new password:\r"
send -- "alex\r"
expect "Remove anonymous users? \[Y\/n\]\r"
send -- "Y\r"
expect "Disallow root login remotely? \[Y\/n\]\r"
send -- "Y\r"
expect "Remove test database and access to it? \[Y\/n\]\r"
send -- "Y\r"
expect "Reload privilege tables now? \[Y\/n\]\r"
send -- "Y\r"
expect eof