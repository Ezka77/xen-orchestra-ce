FROM node:8.9.4-stretch

LABEL xo-server=5.16.0 \
      xo-web=5.16.1

ENV USER=node \
    USER_HOME=/home/node \
    XOA_PLAN=5 \
    DEBUG=xo:main

WORKDIR /home/node

RUN apt-get update && apt-get upgrade -y && \
    wget https://github.com/krallin/tini/releases/download/v0.16.1/tini_0.16.1-amd64.deb && \
    dpkg -i tini_0.16.1-amd64.deb && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y nodejs build-essential libpng-dev git python-minimal git python g++ make yarn && \
    git clone -b master http://github.com/vatesfr/xen-orchestra && \
    rm -rf xen-orchestra/.git xen-orchestra/packages/xo-server/sample.config.yaml && \
    yarn global add node-gyp && \
    cd /home/node/xen-orchestra && yarn && yarn build && \
    yarn global remove node-gyp &&\
    apt-get remove -y git python g++ make &&\
    rm -rf /root/.cache /root/.node-gyp /root/.npm

# configurations
COPY xo-server.config.yaml /home/node/xen-orchestra/packages/xo-server/.xo-server.yaml
COPY xo-entry.sh /docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/usr/bin/tini", "--", "/docker-entrypoint.sh"]
CMD ["yarn", "start"]

