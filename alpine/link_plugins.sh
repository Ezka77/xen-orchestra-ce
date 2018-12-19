#!/bin/ash

# link all plugins
PACKAGES_DIR=/home/node/xen-orchestra/packages


cd ${PACKAGES_DIR}/xo-server/node_modules

for elem in $(find $PACKAGES_DIR -maxdepth 1 -type d -name "xo-server-*"); do
    ln -s $elem $(basename $elem)
done;

