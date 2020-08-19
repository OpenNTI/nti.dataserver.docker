#!/bin/bash
set -e;
export COMPOSE_DOCKER_CLI_BUILD=1 
export DOCKER_BUILDKIT=1

NOCACHE=""
if [[ "$1" == "-force" ]]; then
    NOCACHE="--no-cache"
fi

mkdir -p ./content/{sites,wiktionary}
mkdir -p ./var/{data,log}
mkdir -p ./var/assets/default-assets/site-assets/shared
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

./configs/nginx/gen-cert.sh

if [[ "$OSTYPE" == "darwin"* ]]; then
    ssh-add -K ~/.ssh/id_rsa
else
    ssh-add ~/.ssh/id_rsa
    # SELinux blocks mounting local volumees, this allows it.
    # sudo chcon -Rt svirt_sandbox_file_t .
fi

# --squash # still behind experimental flag
docker image build $NOCACHE \
    --secret id=svnauth,src=./.svnauth \
    --ssh default \
    ./configs \
    -t nti-dataserver