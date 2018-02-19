FROM node:8-alpine

LABEL xo-server=5.16.0 \
         xo-web=5.16.0

ENV USER=node \
    USER_HOME=/home/node \
    XOA_PLAN=5 \
    DEBUG=xo:main

WORKDIR /home/node

RUN apk update && apk upgrade && \
    apk add --no-cache git python g++ make tini su-exec bash

RUN git clone -b master https://github.com/vatesfr/xen-orchestra/ &&\
    cd /home/node/xen-orchestra &&\
    yarn &&\
    yarn build &&\
    rm -rf xen-orchestra/.git
    #apk del git python g++ make &&\
    #rm -rf xen-orchestra/.git xen-orchestra/sample.config.yaml
    #rm -rf /root/.cache /root/.node-gyp /root/.npm

# configurations
COPY xo-server.config.yaml xen-orchestra/packages/xo-server/.xo-server.yaml
COPY xo-entry.sh /docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]
CMD ["yarn", "start"]
