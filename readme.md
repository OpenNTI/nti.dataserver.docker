# nti.dataserver [Docker Edition]

## Prerequisites

- Install [Docker Desktop](https://www.docker.com/products/docker-desktop).
- Setup SSH/Git credentials:
  - Generate private/public keys if you don't have any
  - put your public key in your github account

---

## Setup

Open a terminal in the buildout working directory (on this branch) and execute:

```sh
./build.sh
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

Thats it. Enjoy!

**_Note:_** The web apps, in dev mode, _will_ proxy requests from their instances to these services (tcp port 8082 - http). HTTPS/SSL will be handled by the dev-server since it will be the front-most listener. When you start a webapp it will tell you where it is listening.

---

## Additional

To add content you may put it in the newly created `./content` directory.

To view logs, look under `./var/log` or `./var/nginx-logs/`. The console output from `docker-compose up` will only have process output streams from each container. (stdout/err) You will still need to look in various service logs to see useful information.

Site data is stored under `./var/data`.
