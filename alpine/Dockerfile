# XOA Build container
FROM mhart/alpine-node:12 as build

WORKDIR /home/node

RUN apk add --no-cache git python g++ make bash

# Clone git and remove .git
RUN git clone -b master --depth 1 https://github.com/vatesfr/xen-orchestra/ && \
    rm -rf /home/node/xen-orchestra/.git

# patches
COPY patches /home/node/xen-orchestra/patches

# no quilt in alpine
RUN git clone --depth 1 https://git.savannah.nongnu.org/git/quilt.git

RUN apk add --no-cache diffutils gawk gettext patch perl sed

RUN cd quilt &&\
    ./configure &&\
    make &&\
    make install

RUN cd /home/node/xen-orchestra &&\
    quilt push gh_issue_redirect &&\
    yarn config set network-timeout 300000 &&\
    yarn &&\
    yarn build

COPY link_plugins.sh /home/node/xen-orchestra/packages/xo-server/link_plugins.sh
RUN /home/node/xen-orchestra/packages/xo-server/link_plugins.sh

# VHDIMOUNT support
FROM alpine:3.11 as build-libvhdi

WORKDIR /home/node
RUN apk add --no-cache git g++ make bash automake autoconf libtool gettext-dev pkgconf fuse-dev fuse

RUN git clone https://github.com/libyal/libvhdi.git

RUN cd libvhdi && ./synclibs.sh && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

# Runner container
FROM alpine:3.11

ARG VERSION=latest
ARG XOSERVER=latest
ARG XOWEB=latest

LABEL version=$VERSION xo-server=$XOSERVER xo-web=$XOWEB

ENV USER=node \
    XOA_PLAN=5 \
    DEBUG=xo:main

## Add a user
RUN mkdir -p /home/node

WORKDIR /home/node

RUN apk add --no-cache \
  tini \
  su-exec \
  bash \
  util-linux \
  nfs-utils \
  lvm2 \
  fuse \
  gettext \
  cifs-utils \
  openssl

RUN mkdir -p /storage

# configurations
COPY config.toml /etc/xo-server/config.toml

# Copy our App from the build container
COPY --from=build /home/node/xen-orchestra /home/node/xen-orchestra

# Only copy over the node pieces we need from the above image
COPY --from=build /usr/bin/node /usr/bin/
COPY --from=build /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/

# Get libvhdi
COPY --from=build-libvhdi /usr/local/bin/vhdimount /usr/local/bin/vhdiinfo  /usr/local/bin/
COPY --from=build-libvhdi /usr/local/lib/libvhdi* /usr/local/lib/

# Healthcheck
COPY healthcheck.js /usr/local/share/healthcheck.js
HEALTHCHECK --interval=1m --timeout=12s --start-period=30s \  
 CMD /usr/bin/node /usr/local/share/healthcheck.js

# Run the App
COPY xo-entry.sh /entrypoint.sh
EXPOSE 8000
WORKDIR /home/node/xen-orchestra/packages/xo-server/
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh" ]
CMD ["./bin/xo-server"]
