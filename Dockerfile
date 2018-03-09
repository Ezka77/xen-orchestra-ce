FROM node:6-alpine as build_container

WORKDIR /home/node

RUN apk add --no-cache git python g++ make bash libc6-compat

USER node

RUN git clone -b master https://github.com/vatesfr/xen-orchestra/

RUN cd /home/node/xen-orchestra &&\
    yarn && yarn build

RUN rm -rf xen-orchestra/.git




FROM node:6-alpine

LABEL xo-server=5.17.1 \
         xo-web=5.17.1

ENV USER=node \
    USER_HOME=/home/node \
    XOA_PLAN=5 \
    DEBUG=xo:main

WORKDIR /home/node

RUN apk add --no-cache tini su-exec bash util-linux lvm2

RUN mkdir -p /storage &&\
    chown node:node /storage

# Copy our App from the build container
COPY --from=build_container /home/node/xen-orchestra /home/node/xen-orchestra

# configurations
COPY xo-server.config.yaml /home/node/xen-orchestra/packages/xo-server/.xo-server.yaml
COPY xo-entry.sh /entrypoint.sh

EXPOSE 8000

WORKDIR /home/node/xen-orchestra/packages/xo-server/
ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh" ]
CMD ["yarn", "start"]
