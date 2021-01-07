base_path="./configs/nginx/ddns"
data_path="$base_path/data/certbot"
domains="ray.zapto.org"
path="/etc/letsencrypt/live/$domains"
docker_compose="$base_path/docker-compose.yml"
mkdir -p "$data_path/conf/live/$domains"

echo $docker_compose

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

docker-compose -f $docker_compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:4096 -days 1\
    -keyout '$path/privkey.pem' \
    -out '$path/fullchain.pem' \
    -subj '/CN=localhost'" certbot

echo "### Starting nginx ..."
docker-compose -f $docker_compose up --force-recreate -d nginx
echo

echo "### Deleting dummy certificate for $domains ..."
docker-compose -f $docker_compose run --rm --entrypoint "\
  rm -Rf /etc/letsencrypt/live/$domains && \
  rm -Rf /etc/letsencrypt/archive/$domains && \
  rm -Rf /etc/letsencrypt/renewal/$domains.conf" certbot
echo

docker-compose -f $docker_compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    --staging
    --email docker-dev@nextthought.com \
    -d $domains \
    --rsa-key-size 4096 \
    --agree-tos \
    --force-renewal" certbot

docker-compose -f $docker_compose down
