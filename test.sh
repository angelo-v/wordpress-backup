#!/bin/sh

docker run --rm -t \
  -v $(pwd):/project \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aveltens/docker-testinfra
