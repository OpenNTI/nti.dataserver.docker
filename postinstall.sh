#!/bin/bash
set -e;

if [ "$NTI_SKIP_DOCKER" != "" ]; then
	exit 0;
fi

if [ ! command -v docker &> /dev/null ] || [ ! command -v docker-compose &> /dev/null ]; then
	echo 'docker command line tools are not available';
	exit 0;
fi

if [ ! -z `docker-compose ps -q nginx` ] && [ ! -z `docker ps -q --no-trunc | grep $(docker-compose ps -q nginx)` ]; then
  docker-compose restart nginx
fi
