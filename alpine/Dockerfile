# Build container
FROM mhart/alpine-node:8 as build

WORKDIR /home/node

RUN apk add --no-cache git python g++ make bash

# Clone git and remove .git
RUN git clone -b master https://github.com/vatesfr/xen-orchestra/ && \
    rm -rf /home/node/xen-orchestra/.git

# configurations
COPY xo-server.config.yaml xen-orchestra/packages/xo-server/.xo-server.yaml

RUN cd /home/node/xen-orchestra &&\
    yarn &&\
    yarn build

COPY link_plugins.sh /home/node/xen-orchestra/packages/xo-server/link_plugins.sh
RUN /home/node/xen-orchestra/packages/xo-server/link_plugins.sh


# Runner container
FROM alpine:3.8

ENV USER=node \
    XOA_PLAN=5 \
    DEBUG=xo:main

## Add a user
RUN adduser -D -u 1000 node

WORKDIR /home/node

RUN apk add --no-cache tini su-exec bash util-linux nfs-utils lvm2

RUN mkdir -p /storage && \
    chown node:node /storage

# Copy our App from the build container
COPY --from=build /home/node/xen-orchestra /home/node/xen-orchestra

# Only copy over the node pieces we need from the above image
COPY --from=build /usr/bin/node /usr/bin/
COPY --from=build /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/

# Run the App
COPY xo-entry.sh /entrypoint.sh
EXPOSE 8000
WORKDIR /home/node/xen-orchestra/packages/xo-server/
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh" ]
CMD ["./bin/xo-server"]
