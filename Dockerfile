FROM ubuntu 

MAINTAINER Angelo Veltens <angelo.veltens@online.de>

RUN apt-get update
RUN apt-get install mysql-client -y

RUN mkdir /backups

ADD backup /
ADD restore /

VOLUME /backups

CMD BASH
