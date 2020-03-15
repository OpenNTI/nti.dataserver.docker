# nti.dataserver-buildout [Docker Edition]

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

Once the container is built, you may start the server with `docker-compose up`. This will start the server and listen on 8081. Pressing `CTRL+C` will stop services.

The web apps, in dev mode, will proxy requests from their instances to this port. SSL is handled by the dev-server. When you start a webapp it will tell you where it is listening.

---

## Additional

To add content put content/site packages into the newly created `./Library` directory.
