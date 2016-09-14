# xen-orchestra-ce
Docker &amp; docker-compose files to deploy Xen Orchestra Community Edition (ie: from source)

See https://xen-orchestra.com for information on Xen Orchestra

## Running the app

### From sources, build your own docker images

```
git clone https://github.com/Ezka77/xen-orchestra-ce.git
docker-compose up
```

### From docker repo

Use the automated build from docker hub:

Create a directory:
```
mkdir -p xen-orchestra-ce
cd xen-orchestra-ce
```

Add a docker-compose.yml file like:

```
version: '2'
services:
    orchestra:
        image: ezka77/xen-orchestra-ce
        ports:
            - "8000:80"
        depends_on:
            - redis
        environment:
            - DEBUG=xo:main
        volumes:
            - xo-storage:/storage
    redis:
        image: redis
        volumes:
            - xo-storage:/var/lib/redis
volumes:
    xo-storage: 
```

Adapt the port (8000 by default) and volumes sections if needed.

And call docker-compose:
```
docker-compose up -d
```

Xen Orchestra should be available on: http://localhost:8000


## Support

* This Docker project is not supported by Xen-Orchestra or the parent company Vates.
* Xen-Orchestra also provides a fully-supported, turn-key appliance, see: https://xen-orchestra.com/pricing.html
