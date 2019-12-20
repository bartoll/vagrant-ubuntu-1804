#!/bin/bash

#set -x

# Local variables
mysql_username='root'
mysql_password='root'
subnet=`echo "${private_ip}" | sed 's:[^.]*$:0/255.255.255.0:'`

# Replace all placeholders in overwriten filen
find $HOME/guest_overwrite -type f -exec sed -i "s:\${private_ip}:${subnet}:g" {} +

# Overwrite default files
sudo cp -r $HOME/guest_overwrite/* /
sudo rm -rf $HOME/guest_overwrite
      
# Enable additional configurations
sudo a2enconf vhosts-permissions.conf

# Allow remote access for mysql
query="
CREATE USER '${mysql_username}'@'${subnet}' IDENTIFIED BY '$mysql_password' REQUIRE NONE PASSWORD EXPIRE DEFAULT ACCOUNT UNLOCK;
GRANT ALL PRIVILEGES ON *.* TO '${mysql_username}'@'${subnet}' WITH GRANT OPTION;
GRANT PROXY ON ''@'' TO '${mysql_username}'@'${subnet}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"
#echo "$query"

sudo mysql -u $mysql_username -p"$mysql_password" -e "$query"

# Restart LAMP
sudo service apache2 restart
sudo service php7.2-fpm restart
sudo service mysql restart
