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

# script directory one-liner from https://stackoverflow.com/a/246128/636077
base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
#base_path="./configs/nginx/ddns"

data_path="$base_path/data/certbot"
path="/etc/letsencrypt/live/$cert_name"
mkdir -p "$data_path/conf/live/$cert_name"

docker run \
  -v $data_path/conf:/etc/letsencrypt:consistent,z \
  -p 80:80 \
  --name certbot \
  --rm certbot/certbot \
  certonly \
    --standalone \
    --staging \
    --cert-name $cert_name \
    --register-unsafely-without-email \
    -d $domain \
    --rsa-key-size 4096 \
    --agree-tos \
    --no-eff-email \
    --force-renewal
