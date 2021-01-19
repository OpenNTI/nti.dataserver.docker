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


cert_name="custom-domain"
#cert_name="$domain"

# script directory one-liner from https://stackoverflow.com/a/246128/636077
base_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

data_path="$base_path/data/certbot"
path="/etc/letsencrypt/live/$cert_name"
mkdir -p "$data_path/conf/live/$cert_name"

cat <<EOF >"$base_path/../conf.d/custom-domain-$domain.conf"
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name $domain;

    ssl_certificate /etc/letsencrypt/live/custom-domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/custom-domain/privkey.pem;

    include conf.d/server/root.conf;
}
EOF

docker run \
  -v $data_path/conf:/etc/letsencrypt:consistent,z \
  -p 80:80 \
  --name certbot \
  --rm certbot/certbot \
  certonly \
    --standalone \
    --cert-name $cert_name \
    --register-unsafely-without-email \
    -d $domain \
    --rsa-key-size 4096 \
    --agree-tos \
    --no-eff-email \
    --force-renewal
