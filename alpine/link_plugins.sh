#!/bin/ash

# link all plugins
PACKAGES_DIR=/home/node/xen-orchestra/packages

PLUGINS="xo-server-transport-xmpp \
xo-server-transport-email \
xo-server-backup-reports \
xo-server-auth-github \
xo-server-transport-slack \
xo-server-auth-ldap \
xo-server-auth-saml \
xo-server-usage-report \
xo-server-auth-google \
xo-server-load-balancer \
xo-server-test-plugin \
xo-server-transport-icinga2 \
xo-server-transport-nagios \
xo-server-perf-alert"

# Disabled
# xo-server-cloud \

cd ${PACKAGES_DIR}/xo-server/node_modules

for elem in ${PLUGINS}; do
    ln -s ${PACKAGES_DIR}/$elem $elem
done;

