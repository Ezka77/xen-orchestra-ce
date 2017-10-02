#!/bin/sh
set -e

# storage directory and fix perms
mkdir -p /storage
chown -R ${USER}:${USER} /storage

# start App
cd ${USER_HOME}/xo-server
exec "$@"

