# Xen-Orchestra-CE

[![](https://img.shields.io/badge/xen--orchestra-5.21-green.svg)]() [![](https://images.microbadger.com/badges/image/ezka77/xen-orchestra-ce.svg)](https://microbadger.com/images/ezka77/xen-orchestra-ce "Get your own image badge on microbadger.com") [![Docker Pulls](https://img.shields.io/docker/pulls/ezka77/xen-orchestra-ce.svg)](https://hub.docker.com/r/ezka77/xen-orchestra-ce) [![Docker Build Statu](https://img.shields.io/docker/build/ezka77/xen-orchestra-ce.svg)](https://hub.docker.com/r/ezka77/xen-orchestra-ce)

Docker &amp; docker-compose files to deploy Xen Orchestra Community Edition (ie:
from source). This image include all the officials orchestra plugins build
from sources and link to Xen-Orchestra.

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

or just use the docker compose file:
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
flag. It can be a security/integrity issue for the host running the
container. Knowing that, you can enable these features by un-commenting these
[two lines](https://github.com/Ezka77/xen-orchestra-ce/blob/db127333beb3d7ddfb73d443ccf4312adf142241/docker-compose.yml#L19-L20) in `docker-compose.yml` file.

## Support

* This Docker project is not supported by Xen-Orchestra or the parent company Vates.
* Xen-Orchestra also provides a fully-supported, turn-key appliance, see: https://xen-orchestra.com/pricing.html
