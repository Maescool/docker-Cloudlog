#!/bin/bash

# Directory checks (check if mounted volumes have their base data)
if [ -z "$(ls -A /var/www/backup)" ]; then
  echo "Looks like backupdir is empty, copying original data from source"
  cp -a /usr/src/Cloudlog-master/backup/* /var/www/backup/
fi
if [ -z "$(ls -A /var/www/updates)" ]; then
  echo "Looks like updatesdir is empty, copying original data from source"
  cp -a /usr/src/Cloudlog-master/updates/* /var/www/updates/
fi
echo "Making sure volumed directories have right perms"
chown -R www-data: /var/www/application/logs /var/www/backup /var/www/updates /var/www/uploads
chmod 775 /var/www/application/logs /var/www/backup /var/www/updates /var/www/uploads

# Config file checks and creation
CONFIGFILE=/var/www/application/config/config.php
SAMPLE_CONFIGFILE=/var/www/application/config/config.sample.php
DBCONFIGFILE=/var/www/application/config/database.php
SAMPLE_DBCONFIGFILE=/var/www/application/config/database.sample.php
if [ ! -f ${CONFIGFILE} ]; then
    echo "No config file, creating one based on template"
    if [ -f ${SAMPLE_CONFIGFILE} ]; then
        # Copy template
        cp ${SAMPLE_CONFIGFILE} ${CONFIGFILE}

        # Update config
        sed -ri "s|\['base_url'\] = '([^\']*)+'\;|\['base_url'\] = '${WEB_BASE_URL:-http://localhost/}'\;|g" ${CONFIGFILE}
        sed -ri "s|\['directory'\] = '([^\']*)+'\;|\['directory'\] = '${WEB_DIRECTORY}'\;|g" ${CONFIGFILE}

        sed -ri "/\['callbook'\] =/ s/= .*/= \"${CALLBOOK}\"\;/" ${CONFIGFILE}
        sed -ri "/\['hamqth_username'\] =/ s/= .*/= \"${HAMQTH_USERNAME}\"\;/" ${CONFIGFILE}
        sed -ri "/\['hamqth_password'\] =/ s/= .*/= \"${HAMQTH_PASSWORD}\"\;/" ${CONFIGFILE}
        sed -ri "/\['qrz_username'\] =/ s/= .*/= \"${QRZ_USERNAME}\"\;/" ${CONFIGFILE}
        sed -ri "/\['qrz_password'\] =/ s/= .*/= \"${QRZ_PASSWORD}\"\;/" ${CONFIGFILE}

        sed -ri "s|\['sess_driver'\] = '([^\']*)+'\;|\['sess_driver'\] = '${SESSION_DRIVER:-files}'\;|g" ${CONFIGFILE}
        sed -ri "s|\['sess_save_path'\] = '([^\']*)+'\;|\['sess_save_path'\] = '${SESSION_SAVE_PATH:-/tmp}'\;|g" ${CONFIGFILE}
        sed -ri "s|\['sess_expiration'\] = '([^\']*)+'\;|\['sess_expiration'\] = '${SESSION_EXPIRATION:-0}'\;|g" ${CONFIGFILE}

        sed -ri "s|\['index_page'\] = 'index.php'\;|\['index_page'\] = ''\;|g" ${CONFIGFILE}
        sed -ri "s|\['proxy_ips'\] = '([^\']*)+'\;|\['proxy_ips'\] = '${PROXY_IPS:-172.16.0.0/12}'\;|g" ${CONFIGFILE}
        echo "Config file has been created."
        chown www-data: ${CONFIGFILE}

    else
        echo "No config template found.. can't start"
        exit 1
    fi
fi
if [ ! -f ${DBCONFIGFILE} ]; then
    echo "No DB config file, creating one based on template"
    if [ -f ${SAMPLE_DBCONFIGFILE} ]; then

        # Copy template
        cp ${SAMPLE_DBCONFIGFILE} ${DBCONFIGFILE}

        # Update config for custom mysql
        sed -ri "s/'hostname' => '([^\']*)+',/'hostname' => '${MYSQL_HOSTNAME:-mariadb}',/g" ${DBCONFIGFILE}
        sed -ri "s/'username' => '([^\']*)+',/'username' => '${MYSQL_USER}',/g" ${DBCONFIGFILE}
        sed -ri "s/'password' => '([^\']*)+',/'password' => '${MYSQL_PASSWORD//\//\\/}',/g" ${DBCONFIGFILE}
        sed -ri "s/'database' => '([^\']*)+',/'database' => '${MYSQL_DATABASE}',/g" ${DBCONFIGFILE}
        sed -ri "s/utf8mb4_0900_ai_ci/utf8mb4_general_ci/g" ${DBCONFIGFILE}
        echo "DB Config file has been created."
        chown www-data: ${DBCONFIGFILE}

    else
        echo "No DB config template found.. can't start"
        exit 1
    fi
fi

# Parse DB info from config, just in case it's mounted config.
DB_HOST=${DB_HOST:-$(egrep -oh "'hostname' => '([^\']*)+'," ${DBCONFIGFILE}|tail -1 | sed -r "s/'hostname' => '([^\']*)+',/\1/")}
DB_USERNAME=${DB_USERNAME:-$(egrep -oh "'username' => '([^\']*)+'," ${DBCONFIGFILE}|tail -1 | sed -r "s/'username' => '([^\']*)+',/\1/")}
DB_PASSWORD=${DB_PASSWORD:-$(egrep -oh "'password' => '([^\']*)+'," ${DBCONFIGFILE}|tail -1 | sed -r "s/'password' => '([^\']*)+',/\1/")}
DB_DATABASE=${DB_DATABASE:-$(egrep -oh "'database' => '([^\']*)+'," ${DBCONFIGFILE}|tail -1 | sed -r "s/'database' => '([^\']*)+',/\1/")}
echo "Wating for mysql to come up"
while ! mysql -h ${DB_HOST} -u ${DB_USERNAME} -p${DB_PASSWORD} -e ";" ${DB_DATABASE} > /dev/null 2>&1 ; do
    echo -n "."
    sleep 1
done
echo "done"


