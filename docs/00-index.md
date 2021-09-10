# nti.dataserver [Docker Edition] - Installing/Setup

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

## Additional

To add content you may put it in the newly created `./content` directory.

To view service logs, look under `./var/log` or `docker logs -f <container-name>`. The console output from `docker-compose up` will only have process output streams from each container. (stdout/err) You will still need to look in various service logs to see useful information.

Site data is stored under `./var/data`.

**_SSL:_** Firefox and non-macOS environments will need to manually trust the self-signed cert that is generated for 'app.localhost'. (that is, until we have automation for those environments.)
