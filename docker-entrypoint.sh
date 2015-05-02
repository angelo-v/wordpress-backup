#!/bin/bash

if ! [ -f backup-cron ]
then
  echo "Creating cron entry to start backup at: $BACKUP_TIME"
  # Note: Must use tabs with indented 'here' scripts.
  cat <<-EOF >> backup-cron
	MYSQL_ENV_MYSQL_USER=$MYSQL_ENV_MYSQL_USER
	MYSQL_ENV_MYSQL_DATABASE=$MYSQL_ENV_MYSQL_DATABASE
	MYSQL_ENV_MYSQL_PASSWORD=$MYSQL_ENV_MYSQL_PASSWORD
	$BACKUP_TIME backup
	EOF
  crontab backup-cron
fi

echo "Current crontab:"
crontab -l

exec "$@"
