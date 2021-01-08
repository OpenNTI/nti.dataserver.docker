#!/bin/bash
set -e;

scriptname=$0

function usage {
    echo "usage: $scriptname -d domain"
    exit 1
}

while getopts ":d:h" opt; do
  case ${opt} in
    h) usage;;
    d)
      domain=$OPTARG
    ;;
    \?)
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
    ;;
  esac
done

if [ -z $domain ]; then
  usage
fi

cert_name="dev-cert"
#cert_name="$domain"
base_path="./configs/nginx/ddns"
data_path="$base_path/data/certbot"
path="/etc/letsencrypt/live/$cert_name"
docker_compose="$base_path/docker-compose.yml"
mkdir -p "$data_path/conf/live/$cert_name"

#docker-compose -f $docker_compose run --rm --entrypoint "\
#  openssl req -x509 -nodes -newkey rsa:4096 -days 1\
#    -keyout '$path/privkey.pem' \
#    -out '$path/fullchain.pem' \
#    -subj '/CN=localhost'" certbot

#echo "### Starting nginx ..."
#docker-compose -f $docker_compose up --force-recreate -d certbot
#echo
#
#echo "### Deleting dummy certificate for $domain ..."
#docker-compose -f $docker_compose run --rm --entrypoint "\
#  rm -Rf /etc/letsencrypt/live/$domain && \
#  rm -Rf /etc/letsencrypt/archive/$domain && \
#  rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
#echo

#    --webroot -w /var/www/certbot \
docker-compose -f $docker_compose run --service-ports --rm --entrypoint "\
  certbot certonly \
    --standalone \
    --staging \
    --cert-name $cert_name \
    --register-unsafely-without-email \
    -d $domain \
    --rsa-key-size 4096 \
    --agree-tos \
    --no-eff-email \
    --force-renewal" certbot

#docker-compose -f $docker_compose down
