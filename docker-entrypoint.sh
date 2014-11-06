#!/bin/bash

# start cron deamon
cron

#TODO: only create cron entry first time starting

# create cron entry
echo "$BACKUP_TIME /backup  > /dev/null 2>&1" > backup-cron
crontab backup-cron
rm backup-cron

exec "$@"
