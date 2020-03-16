#!/bin/bash
export COMPOSE_DOCKER_CLI_BUILD=1 
export DOCKER_BUILDKIT=1

mkdir -p ./Library
mkdir -p ./SiteAssets
mkdir -p ./data
mkdir -p ./var/caches/chameleon_cache/
mkdir -p ./var/log/

if [ ! -f ./.svnauth ]; then
    read -p "Subversion Username on https://repos.nextthought.com: " user
    read -sp "Subversion password for '$user': " pass

    echo "$user $pass">./.svnauth;
    echo "";
fi

ssh-add -K ~/.ssh/id_rsa

# docker-compose build
docker build --no-cache --secret id=svnauth,src=./.svnauth --ssh default ./configs -t nti-dataserver