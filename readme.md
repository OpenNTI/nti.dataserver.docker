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

Once the container is built, you may start the server with `docker-compose up`(optionally `-d` to daemonize instead). This will start all the services and bind to the host's port `8082` (http). To stop the services press `CTRL+C`, or if its been daemonized, `docker-compose stop`.

The web apps, in dev mode, will proxy requests from their instances to this port. HTTPS/SSL is handled by the dev-server since it will be the front-most listener. When you start a webapp it will tell you where it is listening.

---

## Additional

To add content you may put it in the newly created `./content` directory.

To view logs, look under `./var/log` or `./var/nginx-logs/`.

Site data is stored under `./var/data`.
