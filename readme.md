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

That's it. Enjoy! Open a web browser and go to https://app.localhost.

To attach a web app (login/app/mobile), simply make sure the dev server is listening on tcp8083. (http)

### Why tcp8083?

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

If you have errors with ssh keys, or with docker/compose, make sure you are using Docker Desktop 19.03.8 (that is what I've tested this on)

```sh
$ docker version

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
