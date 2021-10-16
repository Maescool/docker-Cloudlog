#!/bin/bash

source /start-preload.sh

exec /usr/sbin/cron -f
