#!/bin/bash

source /start-preload.sh

sed -i "s#listen = /run/php/php${PHPVER}-fpm.sock#listen = 9000#g" /etc/php/${PHPVER}/fpm/pool.d/www.conf

exec /usr/sbin/php-fpm${PHPVER} -F -c /etc/php/${PHPVER}/fpm/php-fpm.conf
