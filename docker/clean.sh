#!/bin/bash

set -x

docker rm -f $(docker ps -a -q)
docker rmi -f account_rails
docker image prune -f 
