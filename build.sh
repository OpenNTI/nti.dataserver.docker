#!/bin/bash
set -e;
export COMPOSE_DOCKER_CLI_BUILD=1
export DOCKER_BUILDKIT=1

if [ "$NTI_SKIP_DOCKER" != "" ]; then
	echo "NTI_SKIP_DOCKER is set. aborting."
	exit 0;
fi

if ! command -v docker > /dev/null; then
	echo "docker is not on installed or not on the path. aborting."
	exit 0;
fi


date > ./configs/updated
if [ ! -f ./configs/origin ]; then
	date > ./configs/origin
fi

NOCACHE=""
FORCE=false
# if [ "$NTI_WORKSPACE_REFRESH" == "true" ]; then
# 	FORCE=true
# fi

while test $# -gt 0; do
	case "$1" in
		--no-cache)
			NOCACHE="--no-cache"
			shift
		;;
		--force)
			FORCE=true
			shift
		;;
		*)
      		break
    	;;
	esac
done

if $FORCE; then
	echo "Forcing code update";
	date > ./configs/origin

	# see solr comment at the bottom as to why this needs `sudo`
	# We're dropping just the conf, not data
	sudo rm -rf ./var/solr/nti/conf
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

function __load_identity {
	if [[ "$OSTYPE" == "darwin"* ]]; then
		ssh-add -K $1
	else
		ssh-add $1
	fi
}

find ~/.ssh \
	! -path ~/.ssh \
	-prune -name 'id_*' \
	! -name '*.pub' \
	| while read file; do __load_identity "$file"; done


# SELinux blocks mounting local volumees, this allows it.
# sudo chcon -Rt svirt_sandbox_file_t .

docker image prune -f
# --squash # still behind experimental flag
docker image build $NOCACHE \
    --secret id=svnauth,src=./.svnauth \
    --ssh default \
    ./configs \
    -t nti-dataserver


#setup host side of solr container
if [ ! -d ./var/solr/nti/conf ]; then
	# ensure the main directory exists
	mkdir -p ./var/solr/nti

	# See note below as to why we need to take ownership.
	# This will allow us to update the config without destroying data.
	sudo chown -R $(id -u):$(id -g) ./var/solr

	# make sure our core.properties file exists
	if [ ! -f ./var/solr/nti/core.properties ]; then
		echo 'name=nti' > ./var/solr/nti/core.properties
	fi

	TMP=$(date +%s);
	# create a temp container from the built image...
	ID=`docker create -ti --name nti.temp-$TMP nti-dataserver:latest bash`
	# copy the schema that was generated by buildout out of the container
	docker cp $ID:/code/sources/nti.solr/conf ./var/solr/nti/conf
	# remove the temp container
	docker rm -f $ID

	# make sure UGO has full read/write/exec permissions (solr container needs to be able to create directories & files)
	chmod -R 777 ./var/solr

	# Precreate the data directory structure
	# mkdir -p ./var/solr/nti/data/{index,snapshot_metadata,tlog}

	# Solr's container makes solr run on their own normal user, it has an id of 8983.
	# Docker's bind settings apply to the "owner"... which is the default user, and
	# Solr changed it... and strangely docker echos the host's owner:group ids into
	# the container... so instead of fixing this in the docker-compose/docker-command...
	# we have to patch it here :(
	sudo chown -R 8983:8983 ./var/solr

fi
