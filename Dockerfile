# Build container
#FROM node:6-alpine as build_container
FROM christianu/docker-node:6-alpine as build_container

WORKDIR /home/node

RUN apk add --no-cache git python g++ make bash libc6-compat

USER node

RUN git clone -b master https://github.com/vatesfr/xen-orchestra/

RUN cd /home/node/xen-orchestra &&\
    yarn && yarn build

RUN rm -rf xen-orchestra/.git


# Runner container
#FROM node:6-alpine
FROM christianu/docker-node:6-alpine

ENV USER=node \
    USER_HOME=/home/node \
    XOA_PLAN=5 \
    DEBUG=xo:main

WORKDIR /home/node

RUN apk add --no-cache tini su-exec bash util-linux nfs-utils lvm2

RUN mkdir -p /storage &&\
    chown node:node /storage

# Copy our App from the build container
COPY --from=build_container /home/node/xen-orchestra /home/node/xen-orchestra

# link plugins
RUN cd /home/node/xen-orchestra/packages/xo-server-auth-github         && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-auth-github"
RUN cd /home/node/xen-orchestra/packages/xo-server-auth-google         && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-auth-google"
RUN cd /home/node/xen-orchestra/packages/xo-server-auth-ldap           && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-auth-ldap"
RUN cd /home/node/xen-orchestra/packages/xo-server-auth-saml           && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-auth-saml"
RUN cd /home/node/xen-orchestra/packages/xo-server-backup-reports      && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-backup-reports"
RUN cd /home/node/xen-orchestra/packages/xo-server-cloud               && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-cloud"
RUN cd /home/node/xen-orchestra/packages/xo-server-load-balancer       && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-load-balancer"
RUN cd /home/node/xen-orchestra/packages/xo-server-perf-alert          && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-perf-alert"
RUN cd /home/node/xen-orchestra/packages/xo-server-test-plugin         && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-test-plugin"
RUN cd /home/node/xen-orchestra/packages/xo-server-transport-email     && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-transport-email"
RUN cd /home/node/xen-orchestra/packages/xo-server-transport-nagios    && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-transport-nagios"
RUN cd /home/node/xen-orchestra/packages/xo-server-transport-slack     && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-transport-slack"
RUN cd /home/node/xen-orchestra/packages/xo-server-transport-xmpp      && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-transport-xmpp"
RUN cd /home/node/xen-orchestra/packages/xo-server-usage-report        && yarn link && cd /home/node/xen-orchestra/packages/xo-server/node_modules && yarn link "xo-server-usage-report"

# configurations
COPY xo-server.config.yaml /home/node/xen-orchestra/packages/xo-server/.xo-server.yaml
COPY xo-entry.sh /entrypoint.sh

EXPOSE 8000

WORKDIR /home/node/xen-orchestra/packages/xo-server/
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh" ]
CMD ["yarn", "start"]
