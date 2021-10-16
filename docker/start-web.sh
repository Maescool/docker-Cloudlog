#!/bin/bash

sed -i "s#fastcgi_pass unix:/run/php/php$PHPVER-fpm.sock;#fastcgi_pass app:9000;#g" /etc/nginx/sites-enabled/default

exec /usr/sbin/nginx
