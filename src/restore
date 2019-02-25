#!/bin/bash
set -e

if ! [[ "$1" ]]
then
    echo "Error: Backup name missing"
    echo "Please specify a backup name, e.g. 'restore 20141104'"
    echo "Finished: FAILURE"
    exit 1
fi

if [ -z "$MYSQL_ENV_MYSQL_HOST" ]; then echo "Error: MYSQL_ENV_MYSQL_HOST not set"; echo "Finished: FAILURE"; exit 1; fi
if [ -z "$MYSQL_ENV_MYSQL_USER" ]; then echo "Error: MYSQL_ENV_MYSQL_USER not set"; echo "Finished: FAILURE"; exit 1; fi
if [ -z "$MYSQL_ENV_MYSQL_DATABASE" ]; then echo "Error: MYSQL_ENV_MYSQL_DATABASE not set"; echo "Finished: FAILURE"; exit 1; fi
if [ -z "$MYSQL_ENV_MYSQL_PASSWORD" ]; then echo "Error: MYSQL_ENV_MYSQL_PASSWORD not set"; echo "Finished: FAILURE"; exit 1; fi
if [ -z "$MYSQL_PORT_3306_TCP_PORT" ]; then echo "Error: MYSQL_PORT_3306_TCP_PORT not set"; echo "Finished: FAILURE"; exit 1; fi

if ! [[ $1 =~ ^[a-zA-Z0-9_-]+$ ]]
then
  echo "The given backup name does not match the expected pattern: only characters, digits, underscore and dash are allowed ([a-zA-Z0-9_-])."
  echo 'Finished: FAILURE'
  exit 1
fi

FILES_ARCHIVE="/backups/backup_$1.tar.gz"
SQL_ARCHIVE="/backups/backup_$1.sql.bz2"

if [[ ! -f "${FILES_ARCHIVE}" ]]
then
  echo "The file $FILES_ARCHIVE does not exist. Aborting."
  echo "Finished: FAILURE."
  exit 1
fi

if [[ ! -f "${SQL_ARCHIVE}" ]]
then
  echo "The file $SQL_ARCHIVE does not exist. Aborting."
  echo "Finished: FAILURE."
  exit 1
fi


# cleanup html folder
echo "deleting files from /var/www/html/"
rm -R /var/www/html/*

# restore files
echo "restoring files from $FILES_ARCHIVE to /var/www/html"
tar -xzf "${FILES_ARCHIVE}" --directory="/var/www/html/"

# update wp-config.php
sed -i s/"define('DB_NAME', '.*');"/"define('DB_NAME', '$MYSQL_ENV_MYSQL_DATABASE');"/g /var/www/html/wp-config.php
sed -i s/"define('DB_USER', '.*');"/"define('DB_USER', '$MYSQL_ENV_MYSQL_USER');"/g /var/www/html/wp-config.php
sed -i s/"define('DB_PASSWORD', '.*');"/"define('DB_PASSWORD', '$MYSQL_ENV_MYSQL_PASSWORD');"/g /var/www/html/wp-config.php
sed -i s/"define('DB_HOST', '.*');"/"define('DB_HOST', '$MYSQL_ENV_MYSQL_HOST:$MYSQL_PORT_3306_TCP_PORT');"/g /var/www/html/wp-config.php

# set correct file owner
chown -R www-data:www-data /var/www/html

# restore database
echo "restoring data from mysql dump file $SQL_ARCHIVE"
bunzip2 < "${SQL_ARCHIVE}" | mysql --user="${MYSQL_ENV_MYSQL_USER}" --password="${MYSQL_ENV_MYSQL_PASSWORD}" --host="${MYSQL_ENV_MYSQL_HOST}" "${MYSQL_ENV_MYSQL_DATABASE}"

echo 'Finished: SUCCESS'
