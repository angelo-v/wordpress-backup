wordpress-backup
=========

wordpress-backup is a simple [Docker][1] container that helps you backup and restore your WordPress blog.

 [1]: https://www.docker.com/

## Quick start

Precondition: Given you have a WordPress blog and the corresponding MySQL database running in Docker containers. If not, see section "Migrate your blog to Docker", to see how to move your existing blog into a Docker container within minutes.

*Step 1*: Create and run a backup container linked to your WordPress and MySQL containers

`docker run --name backup-my-blog --volumes-from=your-wordpress-container --link=your-mysql-container:mysql -d aveltens/wordpress-backup`

Replace the following values according to your system:

`your-wordpress-container`: The name of the Docker container hosting your blog  
`your-mysql-container`: The name of the Docker container hosting your blogs MySQL database

*Step 2*: Backup your blog

`docker exec backup-my-blog backup`

Yep. That's all you need to create a complete backup of your blog HTML pages and database content. The backup is stored in the container, so you won't see any file on your host system for now, but we will come to this later.

*Step 3*: Restore the backup from a specific day

`docker exec backup-my-blog restore 20141114`

Replace 20141114 by the date, you actually made a backup.

All backups are timestamped with the date of the backup. So your blog can move back to any day in history on that you created a backup. The format of the timestamp is `yyyyMMdd` (4 digit year, 2 digit month, 2 digit day). But I am sure you noticed that already.

## Create and run the backup container

The Docker image is available on the public Docker hub under the name aveltens/wordpress-backup.

wordpress-backup is a separte container, performing backup and restore operations. The WordPress and MySQL containers of your blog are linked to wordpress-backup, but they are not modified in any way.

To run a backup container, you use the `docker run` command, linking your WordPress and MySQL containers:

`docker run --name <backup-container-name> --volumes-from=<your-wordpress-container> --link=<your-mysql-container>:mysql -d aveltens/wordpress-backup`

You have to replace the placeholders:

`<backup-container-name>`: A name of your choice to identify the backup container  
`<your-wordpress-container>`: The name of the WordPress container  
`<your-mysql-container>`: The name of your MySQL container  

You may also specify a volume to be able to access the backup files on the Docker host:

`docker run --name <backup-container-name> -v </host/path/to/backups>:/backups --volumes-from=<your-wordpress-container> --link=<your-mysql-container>:mysql -d aveltens/wordpress-backup`

`</host/path/to/backups>`: an absolute path on the system hosting the containers

After creating a backup you find the backup files on that path on your host system.

## Manual backup

To manually create a backup of your WordPress blog use `docker exec` to run the backup command:

`docker exec <backup-container-name> backup`

`<backup-container-name>`: The name you chose when you created the container with `docker run`.

> Note that `docker exec` requires at leat Docker 1.3.

This will create two archive files under `/backups` in the container. If you mapped a volume you may see those files in the according directory on your host now. They should be named something like `backup_20141030.sql.bz2` and `backup_20141030.tar.gz`.

The number within the filenames is a date in the format `yyyyMMdd` (4 digit year, 2 digit month, 2 digit day). This means there can only be one backup per day. If you do multiple backups a day the files will be replaced by the latest backup.

> You do not have to backup manually. See Section "Automatic backups".

## Restore

To restore a backup of your WordPress blog use `docker exec` to run the restore command:

`docker exec <backup-container-name> restore <date>`

`<date>`: The timestamp of the backup to restore, in the format `yyyyMMdd`.

> Note that `docker exec` requires at leat Docker 1.3.

This will restore the database as well as the HTML content of your WordPress installation.

## Automatic backups

Per default wordpress-backup will automatically create a backup at 03:00 am every day. You can adjust that time by setting a cron expression to the variable BACKUP_TIME when creating the container. E.g. the following statement will create a container that does a backup at 2:00 am every day:

`docker run --name <backup-container-name> --volumes-from=<your-wordpress-container> --link=<your-mysql-container>:mysql -d -e "BACKUP_TIME=0 2 * * *" aveltens/wordpress-backup`

## Migrate your blog to docker

TODO: Explain how one can backup a blog manually and restore it with wordpress-backup to a docker container.

## Contact

Please contact me for any questions & feedback: angelo.veltens@online.de

