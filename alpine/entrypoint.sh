#!/bin/ash
set -e

# Start rpcbind (used for NFS mount)
rpcbind

# start app
exec "$@"
