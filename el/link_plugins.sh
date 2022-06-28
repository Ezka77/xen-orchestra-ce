#!/bin/bash

# link listed plugins
PACKAGES_DIR=/home/node/xen-orchestra/packages

# official plugins directories
PLUGINS="xo-server-auth-ldap \
xo-server-auth-saml \
xo-server-backup-reports \
xo-server-load-balancer \
xo-server-netbox \
xo-server-perf-alert \
xo-server-sdn-controller \
xo-server-transport-email \
xo-server-transport-icinga2 \
xo-server-transport-nagios \
xo-server-transport-xmpp \
xo-server-usage-report \
xo-server-web-hooks"

# NB: this list is manually updated, feel free to make a pull request if new
# plugins are added/removed.

cd ${PACKAGES_DIR}/xo-server/node_modules

for elem in ${PLUGINS}; do
    ln -s ${PACKAGES_DIR}/$elem $elem
done;

