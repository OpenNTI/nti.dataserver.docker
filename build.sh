#!/bin/bash
export COMPOSE_DOCKER_CLI_BUILD=1 
export DOCKER_BUILDKIT=1

mkdir -p ./content/{sites,wiktionary}
mkdir -p ./var/{caches,data,log,maildir,site-assets}
mkdir -p ./var/caches/chameleon_cache

if [ ! -f ./.svnauth ]; then
    read -p "Subversion Username on https://repos.nextthought.com: " user
    read -sp "Subversion password for '$user': " pass

    echo "$user $pass">./.svnauth;
    echo "";
fi

if [ ! -f ./content/wiktionary/dict.db ]; then
    (
        cd ./content;
        curl -# -o ./wiktionary.tar.bz2 https://downloads.nextthought.com/library/wiktionary.tar.bz2
        tar -xf ./wiktionary.tar.bz2
        rm ./wiktionary.tar.bz2
    )
fi

ssh-add -K ~/.ssh/id_rsa

docker image build \
    --secret id=svnauth,src=./.svnauth \
    --ssh default \
    ./configs \
    -t nti-dataserver
# --squash # still behind experimental flag