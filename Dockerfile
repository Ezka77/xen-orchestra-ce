FROM node:6.10-alpine

LABEL xo-server=5.10.1 xo-web=5.10.5

ENV USER=node USER_HOME=/home/node XOA_PLAN=5 DEBUG=xo:main

WORKDIR /home/node

RUN apk update && apk upgrade && \
    apk add --no-cache git python g++ make &&\
    git clone -b stable http://github.com/vatesfr/xo-server && \
    git clone -b stable http://github.com/vatesfr/xo-web && \
    rm -rf xo-server/.git xo-web/.git xo-server/sample.config.yaml &&\
    yarn global add node-gyp && \
    cd /home/node/xo-server && yarn && yarn run build && yarn clean &&\
    cd /home/node/xo-web && yarn && yarn run build && yarn clean &&\
    yarn global remove node-gyp &&\
    apk del git python g++ make &&\
    rm -rf /root/.cache /root/.node-gyp /root/.npm

# configurations
COPY xo-server.config.yaml /home/node/xo-server/.xo-server.yaml
COPY xo-entry.sh /

EXPOSE 80

ENTRYPOINT ["/xo-entry.sh"]
CMD ["yarn", "start"]
