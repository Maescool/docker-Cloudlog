#!/bin/bash

source /start-preload.sh

echo "Starting Supervisor"
# Start Supervisor
rm -rf /var/run/supervisor.sock
exec /usr/bin/supervisord -nc /etc/supervisor/supervisord.conf
