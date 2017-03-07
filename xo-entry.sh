#!/bin/sh
set -e

# storge directory and fix perms
mkdir -p /storage 
chown -R ${USER}:${USER} /storage

# start App
cd ${USER_HOME}/xo-server
exec "$@"

