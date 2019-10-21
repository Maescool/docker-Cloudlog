#!/usr/bin/env bash

set -x -e

cd /usr/src
unzip master.zip

rm -rf /var/www/*
cp -a /usr/src/Cloudlog-master/* /var/www/
chown -R www-data: /var/www

echo "Done"
exit 0
