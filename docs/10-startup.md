# nti.dataserver [Docker Edition] - Starting up

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
