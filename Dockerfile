FROM ubuntu:22.04

ENV PHPVER 8.1

# Update and install ubuntu packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common locales

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install supervisor cron nginx php$PHPVER php$PHPVER-cli php$PHPVER-fpm php$PHPVER-mbstring php$PHPVER-xml php$PHPVER-curl php$PHPVER-gd php$PHPVER-mysql php-redis php$PHPVER-readline mariadb-client wget git unzip curl

# Prepare nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log
COPY docker/nginx.conf /etc/nginx/sites-enabled/default
RUN sed -i "s/php{{phpver}}/php$PHPVER/" /etc/nginx/sites-enabled/default

# Copy PHP config
COPY docker/php.ini /etc/php/$PHPVER/fpm/conf.d/cloudlog.ini

ADD https://github.com/magicbug/Cloudlog/archive/master.zip /usr/src/master.zip

# Build site
COPY docker/build.sh /build.sh
RUN chmod +x /build.sh
RUN /build.sh

# Disable development environment - needed for CloudLog 2
RUN sed -i s/define\(\'ENVIRONMENT\',\ \'development\'\)\;/define\(\'ENVIRONMENT\',\ \'production\'\)\;/ /var/www/index.php

# Copy supervisor configs
COPY docker/supervisor/*.conf /etc/supervisor/conf.d/
# Make sure php run dir exists
RUN mkdir /run/php

# Copy crontab config
COPY docker/cron-cloudlog /etc/cron.d/cloudlog
# Make sure permissions are correct, else it doesn't run.
RUN chmod 644 /etc/cron.d/cloudlog

# Add start script
COPY docker/start*.sh /
RUN chmod +x /start*.sh

# Cleanup packages
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/archives/* /build.sh

# Define default command.
CMD /start.sh

# Expose ports.
EXPOSE 80

