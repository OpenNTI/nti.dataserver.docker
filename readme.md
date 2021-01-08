# nti.dataserver [Docker Edition]

## Prerequisites

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop), or your distribution's docker packages.
  - macOS and Windows hosts should increase docker's default 2GB RAM allocation to a minimum of 4GB.
- Setup SSH/Git credentials:
  - Generate private/public keys if you don't have any
  - put your public key in your github account

---

## Setup/Updating

Open a terminal in the buildout working directory (on this branch) and execute:

```sh
npm install
```

Reinstalling `node_modules` will refresh the image, but will likely have cached layers.

To force update the docker image run:

```sh
npm run update-image
```

To cleanup and delete all of this...

```sh
npm run uninstall
```

Docker's build cache will survive the tear down. Uninstall and then installing after a successful build of the image will be fast.

## Startup

Once the container is built, use `npm start` to start, and `npm stop` to stop.

If you want more control: `docker-compose up` to start services.

```sh
# this will consume a terminal tab. Outputs of
# each container print to your console.
# ctrl+c to stop gracefully
docker-compose up
```

alternate:

```sh
# start & daemonize, no console output.
docker-compose up -d

#to stop:
docker-compose stop
```

That's it. Enjoy! Open a web browser and go to <https://app.localhost>.

To attach a web app (login/app/mobile), simply make sure the dev server is listening on tcp8083. (http)

### Why tcp8083

Reasons. 😜

Just kidding!

The original buildout listened on tcp8083 for web/mobile apps. To be compatible with the non-containerized environments, and to prevent project churn, we will leave the port that we expect to be the same. This also keeps traditional ports free for side projects to run side-by-side.

---

## Additional

To add content you may put it in the newly created `./content` directory.

To view service logs, look under `./var/log` or `docker logs -f <container-name>`. The console output from `docker-compose up` will only have process output streams from each container. (stdout/err) You will still need to look in various service logs to see useful information.

Site data is stored under `./var/data`.

**_SSL:_** Firefox and non-macOS environments will need to manually trust the self-signed cert that is generated for 'app.localhost'. (that is, until we have automation for those environments.)

## Troubleshooting

If you have errors with ssh keys, or with docker/compose, make sure you are using docker engine v19.03.8 or newer.

```sh
(macos) $ docker version

Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b
 Built:             Wed Mar 11 01:21:11 2020
 OS/Arch:           darwin/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       afacb8b
  Built:            Wed Mar 11 01:29:16 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

On linux, you will want to use the the moby-engine (think Chromium vs Chrome). Moby is Docker -- the main development project, which later gets branded as Docker.

```sh
sudo dnf install moby-engine docker-compose
sudo systemctl enable docker

# allow your user to exec docker commands w/o sudo
sudo groupadd docker
sudo usermod -aG docker ${USER}
```

If network connections do not work:

```sh
sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0
sudo firewall-cmd --permanent --zone=FedoraWorkstation --add-masquerade
```

## macOS *.localhost

This assumes homebrew is installed. This is pretty much [this post](https://firxworx.com/blog/it-devops/sysadmin/using-dnsmasq-on-macos-to-setup-a-local-domain-for-development/) with `.test` swapped with `.localhost`.

```sh
brew install dnsmasq
echo 'address=/.localhost/127.0.0.1' >> $(brew --prefix)/etc/dnsmasq.conf
echo 'port=53' >> $(brew --prefix)/etc/dnsmasq.conf
sudo mkdir -p /usr/local/var/run/dnsmasq
sudo mkdir -p /usr/local/etc/dnsmasq.d
sudo brew services start dnsmasq

sudo mkdir -p /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/localhost'

# Flush your DNS cache:
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
# check config
scutil --dns
# test resolve
ping app.localhost
```

## Getting a shell into the server's container

```sh
docker exec -it nti.dataserver /bin/bash
```

## Enable the admin user

```sh
docker exec -it nti.dataserver /bin/sh -c "./bin/nti_set_password admin@nextthought.com"
```

## Creating a user

```sh
docker exec -it nti.dataserver /bin/sh -c "./bin/nti_create_user [username] [password]"
```

## Adding a custom domain (DDNS)

Add your domain name to the cert config `configs/nginx/certs/localhost.cnf` under `[alt names]`:

```ini
[alt_names]
DNS.1 = app.localhost
DNS.2 = *.app.localhost
DNS.3 = app.dev
DNS.4 = *.app.dev
DNS.5 = app
DNS.6 = *.app
# add your domain name
DNS.7 = mydomain.example.net
```

Revoke the existing cert (if applicable) and regenerate it:

```sh
./configs/nginx/gen-cert.sh revoke
./configs/nginx/gen-cert.sh
```

Add a corresponding site entry to `configs/dataserver/package-includes/777-nti.app.analytics.zcml`:

```xml
<sites:registerSiteMapping
  source_site_name="mydomain.example.net"
  target_site_name="s00000000000000000000000000000000"
/>
```

Rebuild the docker image to pick up the above change:

```sh
npm run update-image
```

Start the container

```sh
npm start
```

---
