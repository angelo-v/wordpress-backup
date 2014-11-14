wp-backup
=========

wp-backup is a simple docker container that helps you backup and restore your wordpress blog.

## Quick start

Create and run a backup container linked to your wordpress and mysql container:

`docker run -ti --name backup-my-blog --volumes-from=your-wordpress-container --link=your-mysql-container:mysql -d aveltens/backup-wordpress`

Backup your blog:

`docker exec backup-my-blog backup`

Restore the backup from 2014-11-14:

`docker exec backup-my-blog restore 20141114`

## Create and run container

The docker image is available on the public docker hub under the name aveltens/backup-wordpress.

To run a backup container, link your wordpress and mysql containers

`docker run -ti --name backup-my-blog --volumes-from=your-wordpress-container --link=your-mysql-container:mysql -d aveltens/backup-wordpress`

TODO: explain placeholders

You may also specify a volume to be able to access the backup files on the docker host:

`docker run -ti --name backup-my-blog -v /host/path/to/backups:/backups --volumes-from=your-wordpress-container --link=your-mysql-container:mysql -d aveltens/backup-wordpress`

TODO: explain volume

## Manual backup

## Restore

## Automatic backups

## Contact

Please contact me for any questions & feedback: angelo.veltens@online.de

