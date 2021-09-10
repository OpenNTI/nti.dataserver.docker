# nti.dataserver [Docker Edition] - Adding a custom domain (DDNS)

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
