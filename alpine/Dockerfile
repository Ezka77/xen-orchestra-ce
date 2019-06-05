# XOA Build container
FROM mhart/alpine-node:8 as build

WORKDIR /home/node

RUN apk add --no-cache git python g++ make bash

# Clone git and remove .git
RUN git clone -b master https://github.com/vatesfr/xen-orchestra/ && \
    rm -rf /home/node/xen-orchestra/.git

# configurations
COPY xo-server.config.yaml xen-orchestra/packages/xo-server/.xo-server.yaml

# patches
COPY patches /home/node/xen-orchestra/patches

# no quilt in alpine
RUN git clone https://git.savannah.nongnu.org/git/quilt.git

RUN apk add --no-cache diffutils gawk gettext patch perl sed

RUN cd quilt &&\
    ./configure &&\
    make &&\
    make install

RUN cd /home/node/xen-orchestra &&\
    quilt push gh_issue_redirect &&\
    yarn &&\
    yarn build

COPY link_plugins.sh /home/node/xen-orchestra/packages/xo-server/link_plugins.sh
RUN /home/node/xen-orchestra/packages/xo-server/link_plugins.sh

# VHDIMOUNT support
FROM alpine:3.8 as build-libvhdi

WORKDIR /home/node
RUN apk add --no-cache git g++ make bash automake autoconf libtool gettext-dev pkgconf fuse-dev

RUN git clone https://github.com/libyal/libvhdi.git

RUN cd libvhdi && ./synclibs.sh && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

# Runner container
FROM alpine:3.8

ENV USER=node \
    XOA_PLAN=5 \
    DEBUG=xo:main

## Add a user
RUN adduser -D -u 1000 node

WORKDIR /home/node

RUN apk add --no-cache tini su-exec bash util-linux nfs-utils lvm2 fuse gettext

RUN mkdir -p /storage && \
    chown node:node /storage

# Copy our App from the build container
COPY --from=build /home/node/xen-orchestra /home/node/xen-orchestra

# Only copy over the node pieces we need from the above image
COPY --from=build /usr/bin/node /usr/bin/
COPY --from=build /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/

# Get libvhdi
COPY --from=build-libvhdi /usr/local/bin/vhdimount /usr/local/bin/
COPY --from=build-libvhdi /usr/local/bin/vhdiinfo /usr/local/bin/
COPY --from=build-libvhdi /usr/local/lib/libvhdi* /usr/local/lib/

# Run the App
COPY xo-entry.sh /entrypoint.sh
EXPOSE 8000
WORKDIR /home/node/xen-orchestra/packages/xo-server/
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh" ]
CMD ["./bin/xo-server"]
