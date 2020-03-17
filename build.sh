#!/bin/bash
export COMPOSE_DOCKER_CLI_BUILD=1 
export DOCKER_BUILDKIT=1

mkdir -p ./content/{sites,wiktionary}
mkdir -p ./site-assets
mkdir -p ./data
mkdir -p ./var/{caches,log,maildir}

if [ ! -f ./content/wiktionary/dict.db ]; then
    curl -L -o ./content/wiktionary/dict.tar.gz https://downloads.nextthought.com/wiktionary.tar.gz
    tar -xf ./content/wiktionary/dict.tar.gz
fi

if [ ! -f ./.svnauth ]; then
    read -p "Subversion Username on https://repos.nextthought.com: " user
    read -sp "Subversion password for '$user': " pass

    echo "$user $pass">./.svnauth;
    echo "";
fi

ssh-add -K ~/.ssh/id_rsa

docker image build \
    --no-cache \
    --secret id=svnauth,src=./.svnauth \
    --ssh default \
    ./configs \
    -t nti-dataserver
# --squash # still behind experimental flag