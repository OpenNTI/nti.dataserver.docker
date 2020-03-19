# nti.dataserver [Docker Edition]

## Prerequisites

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop).
- Setup SSH/Git credentials:
  - Generate private/public keys if you don't have any
  - put your public key in your github account

---

## Setup/Updating

Open a terminal in the buildout working directory (on this branch) and execute:

```sh
./build.sh [-force]
```

## Startup

Once the container is built, use `docker-compose up` to start services.

```sh
# this will consume a terminal tab outputs of
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

That's it. Enjoy! Open a web browser and go to https://app.localhost.

To attach a web app (login/app/mobile), simply make sure the dev server is listening on tcp8000. (http) The defaults for various projects will be in flux as we all migrate to this tool chain.

---

## Additional

To add content you may put it in the newly created `./content` directory.

To view logs, look under `./var/log` or `./var/nginx-logs/`. The console output from `docker-compose up` will only have process output streams from each container. (stdout/err) You will still need to look in various service logs to see useful information.

Site data is stored under `./var/data`.

**_SSL:_** Firefox and non-macos environments will need to manually trust the self-signed cert that is generated for 'app.localhost'. (that is, until we have automation for those environments.)
