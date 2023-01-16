FROM node:18-alpine3.17 as build-xoa

WORKDIR /home/node

RUN apk add --no-cache git python3 g++ make bash fuse fuse-dev fuse3 fuse3-dev curl libc6-compat

#fix error - url loader
RUN npm install url-loader --save-dev
 
# Clone git and remove .git
RUN git clone -b master --depth 1 https://github.com/vatesfr/xen-orchestra/

# patches
COPY patches /home/node/xen-orchestra/patches
RUN cd /home/node/xen-orchestra \
    && git apply patches/gh_issue_redirect.diff \
    && rm -rf /home/node/xen-orchestra/.git /home/node/xen-orchestra/patches

# build
WORKDIR /home/node/xen-orchestra
RUN yarn config set network-timeout 300000
RUN yarn
RUN yarn build

##  ~ Experimental ~
# clean node_modules steps
WORKDIR /home/node/xen-orchestra
# from npm doc remove extraneous modules for production (as before we build with
# the dev dependencies it remove a lot! after this step the size is around 200Mo)
RUN npm prune --omit=dev

# remove some more things (remove something like 35Mo)
RUN npm install -g modclean
RUN modclean -r

# remove unused files like docs, empty files... (scrap something like 25Mo)
RUN curl -sf https://gobinaries.com/tj/node-prune | sh
RUN node-prune

# plugins
WORKDIR /home/node
COPY link_plugins.sh /home/node/xen-orchestra/packages/xo-server/link_plugins.sh
RUN /home/node/xen-orchestra/packages/xo-server/link_plugins.sh


# results:
# xen-orchestra directory is about 500Mo after the build process, using theses
# tools shrink it to something about 130Mo ==> there is no magics but it helps.
# Overall the compressed image was around 220Mo before, and now it is below 130Mo.
## 

# VHDIMOUNT support
FROM alpine:3.17 as build-libvhdi

WORKDIR /home/node
RUN apk add --no-cache git g++ make bash automake autoconf libtool gettext-dev pkgconf fuse-dev fuse

RUN git clone https://github.com/libyal/libvhdi.git

WORKDIR /home/node/libvhdi
RUN ./synclibs.sh
RUN ./autogen.sh
RUN ./configure
RUN make && make install

# REMCO
FROM golang:alpine3.17 as build-remco

RUN apk add --no-cache git
RUN go install github.com/HeavyHorst/remco/cmd/remco@latest

# Runner container
FROM alpine:3.17

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
  su-exec \
  bash \
  util-linux \
  nfs-utils \
  lvm2 \
  fuse \
  fuse3 \
  gettext \
  cifs-utils \
  openssl \
  ntfs-3g

RUN mkdir -p /storage /etc/xo-server

# Copy our App from the build container
COPY --from=build-xoa /home/node/xen-orchestra /home/node/xen-orchestra

# Only copy over the node pieces we need from the above image
COPY --from=build-xoa /usr/local/bin/node /usr/bin/
COPY --from=build-xoa /usr/lib/libgcc* /usr/lib/libstdc* /usr/lib/

# Get libvhdi
COPY --from=build-libvhdi /usr/local/bin/vhdimount /usr/local/bin/vhdiinfo  /usr/local/bin/
COPY --from=build-libvhdi /usr/local/lib/libvhdi* /usr/local/lib/

# Healthcheck
COPY healthcheck.js /usr/local/share/healthcheck.js
HEALTHCHECK --interval=1m --timeout=12s --start-period=30s \  
 CMD /usr/bin/node /usr/local/share/healthcheck.js

# Get remco
COPY --from=build-remco /go/bin/remco /bin/remco
ADD remco /etc/remco

# Environment vars to control config
ENV XO_HTTP_LISTEN_PORT="8000"
# List of configurable env vars:
#    XO_HTTP_LISTEN_PORT="8000" \
#    XO_HTTP_REDIRECTTOHTTPS="false" \
#    XO_HTTPS_LISTEN_PORT="443" \
#    XO_HTTPS_LISTEN_CERT="./certificate.pem" \
#    XO_HTTPS_LISTEN_KEY="./key.pem" \
#    XO_HTTPS_LISTEN_AUTOCERT="true" \
#    XO_HTTPS_LISTEN_DHPARAM="./dhparam.pem

# Run the App
WORKDIR /home/node/xen-orchestra/packages/xo-server/
CMD ["/bin/remco"]
