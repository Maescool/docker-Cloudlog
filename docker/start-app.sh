#!/bin/bash

source /start-preload.sh

if [ $(mysql -h ${DB_HOST} -u ${DB_USERNAME} -p${DB_PASSWORD} -s -e "select count(*) from information_schema.tables where table_schema='${DB_DATABASE}' and table_name='options';") -eq 0 ]
then
  echo "table options not found, installing db tables"
  mysql -h ${DB_HOST} -u ${DB_USERNAME} -p${DB_PASSWORD} ${DB_DATABASE} < /var/www/install/assets/install.sql
fi

# removing install dir
if [ -d "/var/www/install" ]
then
  echo "removing install dir, not needed anymore"
  rm -rf /var/www/install/
fi

sed -i "s#listen = /run/php/php${PHPVER}-fpm.sock#listen = 9000#g" /etc/php/${PHPVER}/fpm/pool.d/www.conf

echo "starting php-fpm"

exec /usr/sbin/php-fpm${PHPVER} -F -c /etc/php/${PHPVER}/fpm/php-fpm.conf
