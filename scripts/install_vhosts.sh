#!/bin/bash

#set -x

function add_new_vhost () {

  # Get values from arguments or defaults
  local domain=${1:-"vagrant.sample"}
  local type=${2:-"fixed"}
  local pool=${3:-"vagrant"}

  #echo "domain: $domain"
  #echo "type: $type"
  #echo "pool: $pool"

  # Create new user's directory
  sudo mkdir -p /var/www/$pool/
  #sudo chown -R ${pool}:${pool} /var/www/$pool

  cd /etc/apache2/sites-available

  # Add fixed-root host entry
  if [ "$type" == 'fixed' ]
  then

    # Add new vhost's entry to config file
    file="vhosts-fixed-root.conf"
    tempfile=tempfile$$

    sudo awk -v new_entry="Use VHostFixedRoot $domain $pool" '

      BEGIN { RS="\n\n"; ORS="\n\n"; }
      ! /(# )?Use VHostFixedRoot.*/ { print; }
      /(# )?Use VHostFixedRoot.*/ { print $0 "\n" new_entry; }

    ' $file > $tempfile && sudo mv "$tempfile" "$file"

    # Create new vhost's directory
    sudo mkdir -p /var/www/$pool/$domain
    #sudo chown -R ${pool}:${pool} /var/www/$pool/$domain
  fi

  # Add virtual-root host entry
  if [ "$type" == 'virtual' ]
  then

    # Add new vhost's entry to config file
    file="vhosts-virtual-root.conf"
    tempfile=tempfile$$

    sudo awk -v new_entry="Use VHostVirtualRoot $domain $pool" '

      BEGIN { RS="\n\n"; ORS="\n\n"; }
      ! /(# )?Use VHostVirtualRoot.*/ { print; }
      /(# )?Use VHostVirtualRoot.*/ { print $0 "\n" new_entry; }

      ' $file > $tempfile && sudo mv "$tempfile" "$file"

    # Create new vhost's directory
    sudo mkdir -p /var/www/$pool/demo1.${domain}
    #sudo chown -R ${pool}:${pool} /var/www/$pool/demo1.${domain}

    # Add index.php file
    cd /var/www/$pool/demo1.${domain}
    sudo echo "<?php
      phpinfo();" > index.php
  fi
}

# Add fixed hosts to template file
for domain in `echo $vhosts_fixed | jq -r '.[]'`; do
  add_new_vhost $domain "fixed" "vagrant"
done

# Add virtual hosts to template file
for domain in `echo $vhosts_virtual | jq -r '.[]'`; do
  add_new_vhost $domain "virtual" "vagrant"
done

# Enable vhosts
sudo a2ensite vhosts-virtual-root.conf
sudo a2ensite vhosts-fixed-root.conf

# Restart LAMP
sudo service apache2 restart
sudo service php7.2-fpm restart
sudo service mysql restart


