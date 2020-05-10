#!/bin/ash
set -e

# Start rpcbind (used for NFS mount)
rpcbind

# fix permissions for storage directory
chown $(id -u):$(id -g) /storage -R

# start app
exec "$@"
