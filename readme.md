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

### Additional

To add content you may put it in the newly created `./content` directory.

To view service logs, look under `./var/log` or `docker logs -f <container-name>`. The console output from `docker-compose up` will only have process output streams from each container. (stdout/err) You will still need to look in various service logs to see useful information.

Site data is stored under `./var/data`.

**_SSL:_** Firefox and non-macOS environments will need to manually trust the self-signed cert that is generated for 'app.localhost'. (that is, until we have automation for those environments.)

---

## Starting up

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

## Supplemental

### Why tcp8083

Reasons. 😜

Just kidding!

The original buildout listened on tcp8083 for web/mobile apps. To be compatible with the non-containerized environments, and to prevent project churn, we will leave the port that we expect to be the same. This also keeps traditional ports free for side projects to run side-by-side.

---

### Adding a custom domain (DDNS)

Request a cert for your domain by running the command below, replacing `example.org` with your domain name.

```sh
./configs/nginx/custom-domain/get-custom-domain-cert.sh -d example.org
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

### Handy Commands

#### Getting a shell into the server's container

```sh
docker exec -it nti.dataserver /bin/bash
```

#### Enable the admin user (by setting its password)

> **_NOTE:_** You can use this same command to set any user's password

```sh
docker exec -it nti.dataserver /bin/sh -c "./bin/nti_set_password admin@nextthought.com"
```

#### Creating a user

```sh
docker exec -it nti.dataserver /bin/sh -c "./bin/nti_create_user [username] [password]"
```

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

### SELinux :|

I've hit a few SELinux speed bumps along the way. This is what I've done to clear them. You can opt to just run in permissive mode, but thats less secure... so I wouldn't recommend that. However, I do leverage that mode to get a report of what we need to "allow" for work.

To enable permissive mode:

```sh
sudo setenforce Permissive
```

Once in permissive mode we can build the container the first time, uninhibited by SELinux... all actions it _would_ have blocked are logged to the audit.log... so lets make a local copy starting at the end (so we just get the info for our current run) Don't do anything concurrently with this so our audit log isn't mixed with potentially other violations.

This command will follow along with the system audit log and copy the output to a local audit.log file... we start this in the background (& at the end) so note the job number. (the value in [square brackets])

```sh
sudo tail -n 0 -f /var/log/audit/audit.log > audit.log &
```

Now, lets force a full build so every step is exercised. We want all possible violations logged so we can permit them.

```sh
./build.sh --no-cache
```

Now we can stop the audit. You can `fg` and <kbd>ctrl+c</kbd> or use `kill %1` where `1` is the job number you recorded above.

Now we should disable permissive mode and re-enforce SELinux policy...

```sh
sudo setenforce Enforcing
```

We can take the local audit.log we just created and generate a policy module to allow all the logged violations:

```sh
cat ./audit.log | audit2allow -m "nti_local_dev">nti_local_dev.te
```

`cat ./nti_local_dev.te` should produce something like:

```te
module nti_local_dev 1.0;

require {
 type container_var_lib_t;
 type container_runtime_t;
 type container_runtime_tmpfs_t;
 type unlabeled_t;
 type user_home_t;
 type container_t;
 class file { append create entrypoint execmod execute execute_no_trans ioctl link lock map open read relabelfrom relabelto rename setattr unlink write };
 class dir { add_name create map read relabelfrom relabelto remove_name rename reparent rmdir setattr write };
 class lnk_file { create read rename setattr unlink };
 class sock_file write;
 class unix_stream_socket connectto;
}

#============= container_t ==============
allow container_t container_runtime_t:unix_stream_socket connectto;
allow container_t container_runtime_tmpfs_t:file { ioctl open read };
allow container_t container_var_lib_t:file { open read };
allow container_t container_var_lib_t:sock_file write;
allow container_t unlabeled_t:dir { add_name create map read relabelfrom remove_name rename reparent rmdir setattr write };
allow container_t unlabeled_t:file { append create entrypoint execmod execute execute_no_trans ioctl link lock open read relabelfrom relabelto rename setattr unlink write };

#!!!! This avc can be allowed using the boolean 'domain_can_mmap_files'
allow container_t unlabeled_t:file map;
allow container_t unlabeled_t:lnk_file { create read rename setattr unlink };
allow container_t user_home_t:dir { add_name relabelto remove_name write };
allow container_t user_home_t:file { create execute execute_no_trans ioctl open read relabelto rename setattr unlink write };

```

Now we can generate the actual compiled policy module:

```sh
cat ./audit.log | audit2allow -M "nti_local_dev"
```

And then import / enable it:

```sh
semodule -i nti_local_dev.pp
```

If anything complains about miss-matched contexts you can run this on directory to reset the contexts:

```sh
sudo chcon -t container_file_t -u system_u -R -v .
```

### macOS \*.localhost

macOS does not come configured to resolve \*.localhost addresses locally and relies on your router or DNS provider to handle them... thats not fast nor private, so you can install dnsmasq and configure it to do so for you. (These instructions assume homebrew is installed. Also, this is pretty much [this post](https://firxworx.com/blog/it-devops/sysadmin/using-dnsmasq-on-macos-to-setup-a-local-domain-for-development/) with `.test` swapped with `.localhost`.)

> Alternatively, you may skip dnsmasq and simply add `app.localhost` and `nti.ssl.dev.config.share.localhost` to the `/etc/hosts` file, pointing to `::1`(ipv6) and `127.0.0.1`(ipv4).
>
> ```ss
> 127.0.0.1   app.localhost nti.ssl.dev.config.share.localhost
> ::1         app.localhost nti.ssl.dev.config.share.localhost
> ```

To install and configure dnsmasq:

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
