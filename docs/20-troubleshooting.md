# nti.dataserver [Docker Edition] - Troubleshooting

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

## SELinux :|

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
 type container_ro_file_t;
 type container_runtime_t;
 type container_var_lib_t;
 type container_t;
 type container_runtime_tmpfs_t;
 class dir { add_name create map relabelfrom remove_name rename reparent rmdir setattr write };
 class file { append create link open read relabelfrom relabelto rename setattr unlink write };
 class lnk_file { create rename setattr unlink };
 class sock_file write;
 class unix_stream_socket connectto;
}

#============= container_t ==============
allow container_t container_ro_file_t:dir { add_name create map relabelfrom remove_name rename reparent rmdir setattr write };
allow container_t container_ro_file_t:file { append create link relabelfrom relabelto rename setattr unlink write };
allow container_t container_ro_file_t:lnk_file { create rename setattr unlink };
allow container_t container_runtime_t:unix_stream_socket connectto;
allow container_t container_runtime_tmpfs_t:file { open read };
allow container_t container_var_lib_t:file { open read };
allow container_t container_var_lib_t:sock_file write;

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

## macOS \*.localhost

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
