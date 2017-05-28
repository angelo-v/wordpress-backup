#!/bin/bash
set -e
cd "`dirname $0`"

TEST_IMG=test-wordpress-backup
TEST_CTN=test-wordpress-backup

# Build test image
docker build -t $TEST_IMG ..

# Cleanup last run (if it failed)
docker kill $TEST_CTN-backup 2> /dev/null || true
docker rm -v $TEST_CTN-backup 2> /dev/null || true
docker kill $TEST_CTN-restore 2> /dev/null || true
docker rm -v $TEST_CTN-restore 2> /dev/null || true
docker kill $TEST_CTN-mysql 2> /dev/null || true
docker rm -v $TEST_CTN-mysql 2> /dev/null || true
rm -fr backups

# Create backup folder
mkdir -p backups

# Create database
docker run -d --name $TEST_CTN-mysql -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=wordpress -e MYSQL_USER=user -e MYSQL_PASSWORD=123456 mysql

# Prepare test containers
docker run -d -v /var/www/html -v "$(pwd)/backups:/backups" --link $TEST_CTN-mysql:mysql --name $TEST_CTN-backup $TEST_IMG
docker run -d -v /var/www/html -v "$(pwd)/backups:/backups" --link $TEST_CTN-mysql:mysql --name $TEST_CTN-restore $TEST_IMG
docker exec $TEST_CTN-backup sh -c "echo > /var/www/html/wp-config.php"

# Add file1 in data container
docker exec $TEST_CTN-backup dd count=1 bs=1000000 if=/dev/urandom of=/var/www/html/file1

# Backup
docker exec $TEST_CTN-backup backup

# Restore
LAST_BACKUP_FILE="`ls -1 backups/*.tar.gz|sort|tail -1`"
LAST_BACKUP_ID=`echo $LAST_BACKUP_FILE|cut -d_ -f2|cut -d. -f1`
docker exec $TEST_CTN-backup sh -c "echo > /var/www/html/wp-config.php"
docker exec $TEST_CTN-restore restore $LAST_BACKUP_ID

# Check that the file has been restored
docker exec $TEST_CTN-restore ls /var/www/html | grep file1

# Add file2 in data container
docker exec $TEST_CTN-backup dd count=1 bs=1000000 if=/dev/urandom of=/var/www/html/file2

# Backup
sleep 1 # make sure timestamp is different
docker exec $TEST_CTN-backup backup

# Restore
LAST_BACKUP_FILE="`ls -1 backups/*.tar.gz|sort|tail -1`"
LAST_BACKUP_ID=`echo $LAST_BACKUP_FILE|cut -d_ -f2|cut -d. -f1`
docker exec $TEST_CTN-restore restore $LAST_BACKUP_ID

# Check that the files are restored
docker exec $TEST_CTN-restore ls /var/www/html | grep file1
docker exec $TEST_CTN-restore ls /var/www/html | grep file2

# Cleanup
docker kill $TEST_CTN-backup
docker rm -v $TEST_CTN-backup
docker kill $TEST_CTN-restore
docker rm -v $TEST_CTN-restore
docker kill $TEST_CTN-mysql
docker rm -v $TEST_CTN-mysql
rm -fr backups
