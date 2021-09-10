# nti.dataserver [Docker Edition] - Handy Commands

## Getting a shell into the server's container

```sh
docker exec -it nti.dataserver /bin/bash
```

## Enable the admin user (by setting its password)

> **_NOTE:_** You can use this same command to set any user's password

```sh
docker exec -it nti.dataserver /bin/sh -c "./bin/nti_set_password admin@nextthought.com"
```

## Creating a user

```sh
docker exec -it nti.dataserver /bin/sh -c "./bin/nti_create_user [username] [password]"
```
