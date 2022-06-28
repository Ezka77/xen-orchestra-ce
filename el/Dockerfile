FROM almalinux:8.6 as alma

FROM alma as build
ENV HOME=/home/node \
    USER=node

RUN groupadd -g 1001 node && \
    useradd -r -u 1001 -m -s /sbin/nologin -g node node && \
    chown node:0 ${HOME} && \
    chmod g=u ${HOME} && \
    dnf update -y && \
    dnf module enable -y nodejs:14 && \
    curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
    dnf install -y nodejs git python2 gcc make yarn && \
    dnf clean all && \
    rm -rf /var/cache/dnf

WORKDIR /home/node

#fix error - url loader
RUN npm install url-loader --save-dev
 
# Clone git and remove .git
RUN git clone --depth 1 https://github.com/vatesfr/xen-orchestra/ && \
    cd /home/node/xen-orchestra && \
    git fetch --depth 1 origin $GIT_REF && \
    git checkout $GIT_REF && \
    rm -rf /home/node/xen-orchestra/.git && \
    cat /home/node/xen-orchestra/packages/xo-server/package.json | python2 -c "import sys, json; print('XOSERVER=' + json.load(sys.stdin)['version'])" | tee -a versions.conf && \
    cat /home/node/xen-orchestra/packages/xo-web/package.json | python2 -c "import sys, json; print('XOWEB=' + json.load(sys.stdin)['version'])" | tee -a versions.conf
# build
RUN cd /home/node/xen-orchestra && \
    yarn config set network-timeout 300000 && \
    yarn && \
    yarn build

# plugins
COPY link_plugins.sh /home/node/xen-orchestra/packages/xo-server/link_plugins.sh
RUN /home/node/xen-orchestra/packages/xo-server/link_plugins.sh

# VHDIMOUNT support
FROM alma as build-libvhdi

WORKDIR /home/node
RUN dnf install -y git gcc make bash automake autoconf libtool gettext gettext-devel pkgconf fuse

RUN git clone https://github.com/libyal/libvhdi.git

RUN cd libvhdi && ./synclibs.sh && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

# REMCO
FROM alma as build-remco

RUN curl https://dl.google.com/go/go1.17.11.linux-amd64.tar.gz -o golang.tar.gz
RUN tar -xzf golang.tar.gz -C /usr/local && \
    useradd -u 1001 -s /bin/bash golanguser && \
    dnf install -y --nodocs git

ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" \
    && chmod -R 744 "$GOPATH" \
    && chown -R 1001:1001 "$GOPATH"

WORKDIR $GOPATH

RUN go get github.com/HeavyHorst/remco/cmd/remco

# Runner container
FROM alma

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

RUN dnf install -y \
  bash \
  util-linux \
  nfs-utils \
  lvm2 \
  fuse \
  gettext \
  cifs-utils \
  openssl

RUN mkdir -p /storage /etc/xo-server

# Copy our App from the build container
COPY --from=build /home/node/xen-orchestra /home/node/xen-orchestra

# Only copy over the node pieces we need from the above image
COPY --from=build /usr/bin/node /usr/bin/
COPY --from=build /usr/lib64/libbrot* /usr/lib64/

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
