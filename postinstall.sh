#!/bin/bash
set -e;
if [ ! -z `docker-compose ps -q nginx` ] && [ ! -z `docker ps -q --no-trunc | grep $(docker-compose ps -q nginx)` ]; then
  docker-compose restart nginx
fi
