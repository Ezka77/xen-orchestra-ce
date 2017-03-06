FROM debian:jessie

LABEL xo-server=5.6.4 xo-web=5.6.3

ENV DEBIAN_FRONTEND noninteractive

RUN useradd -d /app -r app && \
    mkdir -p /static /storage /app/conf && \
    chown -R app /static /storage /app

WORKDIR /app

# Install requirements doc from: https://xen-orchestra.com/docs/from_the_sources.html
# Requirements to run Orchestra
RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends \
        ca-certificates apt-transport-https curl libpng-dev git python-minimal && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" \
        | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get -qq update && \
    apt-get autoremove -qq && \
    apt-get -qq install --no-install-recommends yarn && \
    apt-get clean && \
    rm -rf /usr/share/doc /usr/share/man /var/log/* /tmp/* &&\
    curl -o /usr/local/bin/n \
        https://raw.githubusercontent.com/visionmedia/n/master/bin/n && \
    chmod +x /usr/local/bin/n


# Clone repos
RUN git clone -b stable http://github.com/vatesfr/xo-server && \
    git clone -b stable http://github.com/vatesfr/xo-web && \
    rm -rf xo-server/.git xo-web/.git xo-server/sample.config.yaml

# build requirements & build & cleanup
RUN apt-get -qq install --no-install-recommends gcc g++ make python && \
    n lts && \
    cd /app/xo-server && yarn && yarn run build &&\
    cd /app/xo-web && yarn && yarn run build &&\
    apt-get purge -qq gcc g++ make python &&\
    apt-get clean -qq && \
    apt-get autoremove -qq &&\
    rm -rf /app/.npm /tmp/* /var/log/* /var/lib/apt/lists/* \
            /usr/share/doc /usr/share/man

# configurations
COPY xo-server.config.yaml /app/xo-server/.xo-server.yaml
COPY xo-entry.sh /

EXPOSE 80

ENTRYPOINT ["/xo-entry.sh"]
CMD ["yarn", "start"]
