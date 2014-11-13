#!/bin/bash

echo "Starting cron daemon..."
cron

if ! [ -f backup-cron ]
then
  echo "Creating cron entry to start backup at: $BACKUP_TIME"
  echo "$BACKUP_TIME /backup  > /dev/null 2>&1" > backup-cron
  crontab backup-cron
fi

echo "Current crontab:"
crontab -l

exec "$@"
