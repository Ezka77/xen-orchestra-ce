# Build container
FROM node:6-alpine as build_container

WORKDIR /root

RUN apk add --no-cache git python g++ make bash libc6-compat

USER root

RUN git clone -b master https://github.com/vatesfr/xen-orchestra/

RUN cd /root/xen-orchestra &&\
    yarn && yarn build

RUN rm -rf xen-orchestra/.git



# Runner container
FROM node:6-alpine

LABEL xo-server=5.18.3 \
         xo-web=5.18.2

ENV USER=root \
    USER_HOME=/root \
    XOA_PLAN=5 \
    DEBUG=xo:main

WORKDIR /root

RUN apk add --no-cache tini su-exec bash util-linux nfs-utils openrc

RUN mkdir -p /storage &&\
    chown root:root /storage

# Copy our App from the build container
COPY --from=build_container /root/xen-orchestra /root/xen-orchestra

## Install plugins from npm
RUN npm install --global \
    xo-server-auth-saml \
    xo-server-auth-ldap \
    xo-server-auth-github \
    xo-server-auth-google \
    xo-server-transport-email \
    xo-server-transport-xmpp \
    xo-server-transport-slack \
    xo-server-transport-nagios \
    xo-server-usage-report \
    xo-server-backup-reports \
    xo-server-load-balancer \
    xo-import-servers-csv

RUN rc-update add nfsmount

# configurations
COPY xo-server.config.yaml /root/xen-orchestra/packages/xo-server/.xo-server.yaml
COPY xo-entry.sh /entrypoint.sh

EXPOSE 8000

WORKDIR /root/xen-orchestra/packages/xo-server/
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh" ]
CMD ["yarn", "start"]
