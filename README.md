# Xen-Orchestra-CE

[![](https://img.shields.io/badge/xen--orchestra-master-green.svg)](https://xen-orchestra.com) [![](https://images.microbadger.com/badges/image/ezka77/xen-orchestra-ce.svg)](https://microbadger.com/images/ezka77/xen-orchestra-ce "Get your own image badge on microbadger.com") [![Docker Pulls](https://img.shields.io/docker/pulls/ezka77/xen-orchestra-ce.svg)](https://hub.docker.com/repository/docker/ezka77/xen-orchestra-ce) [![Docker Build Statu](https://img.shields.io/docker/build/ezka77/xen-orchestra-ce.svg)](https://hub.docker.com/r/ezka77/xen-orchestra-ce)

Docker &amp; docker-compose files to deploy Xen Orchestra Community Edition (ie:
from source). This image include all the officials Orchestra plugins builded
for the current version.

See https://xen-orchestra.com for information on Xen Orchestra

## Running the container

### With Docker-Compose

The most simple way is to use docker-compose. Redis is not in this docker, so we
need to connect XOA-CE to a Redis database, the docker-compose file in the github
repos will take care of this and assure persistance.

```
git clone https://github.com/Ezka77/xen-orchestra-ce.git
docker-compose up
```

or just use the docker compose file ([direct link](https://raw.githubusercontent.com/Ezka77/xen-orchestra-ce/master/docker-compose.yml)):
```
curl -o docker-compose.yml https://raw.githubusercontent.com/Ezka77/xen-orchestra-ce/master/docker-compose.yml
docker-compose up
```

Xen Orchestra should be available on: http://localhost:8000

## Versions

It's a best effort to follow xen-orchestra master version. 

## Enable Superuser features

Some of the Xen-Orchestra features (ex: NFS backups) requires to run the xo
service as root/superuser and run the docker container with the `privileged`
flag. The docker-compose file add the SYS_ADMIN capability to the running
container, this will allow to use NFS mount.

## Environment Variables

Some behaviour of the container can be managed via the following environment variables:

* XO_HTTP_REDIRECTTOHTTPS : Redirect HTTP to HTTPS (default = false)
* XO_HTTP_LISTEN_PORT : HTTP listen port (default = 8000)
* XO_HTTPS_LISTEN_PORT : HTTPS listen port (default = unset)
* XO_HTTPS_LISTEN_CERT : Certificate (in PEM format) for HTTPS (default = './certificate.pem')
* XO_HTTPS_LISTEN_KEY : Private key (in PEM format) for HTTPS (default = './key.pem')
* XO_HTTPS_LISTEN_AUTOCERT : Automatically create self-signed certificate if "key" and "cert" are missing (default = true)
* XO_HTTPS_LISTEN_DHPARAM : DH parameter file for HTTPS (default = unset)

These environment variables can be added to your compose file to enable HTTPS support.

This following example has Xen Orchestra listening on port 80 (HTTP) and port 443 (HTTPS) with automatic self-signed certificates:

```yaml
services:
  orchestra:
    restart: unless-stopped
    image: ezka77/xen-orchestra-ce:latest
    container_name: XO_server
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - redis
    environment:
      - DEBUG=xo:main
      - NODE_ENV=production
      - XOA_PLAN=5
      - XO_HTTP_REDIRECTTOHTTPS=true
      - XO_HTTP_LISTEN_PORT=80
      - XO_HTTPS_LISTEN_PORT=443
      - XO_HTTPS_LISTEN_AUTOCERT=true
    #privileged: true
    # SYS_ADMIN should be enough capability to use NFS mount
    cap_add:
      - SYS_ADMIN
    volumes:
      - xo-data:/storage
    logging: &default_logging
      driver: "json-file"
      options:
        max-size: "1M"
        max-file: "2"
```

## Support

* This Docker project is not supported by Xen-Orchestra or the parent company Vates.
* Xen-Orchestra also provides a fully-supported, turn-key appliance, see: https://xen-orchestra.com/pricing.html
