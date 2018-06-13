#!/bin/bash
set -e

# Start rpcbind (used for NFS mount)
rpcbind

# fix perm
chown ${USER}:${USER} /storage -R

# start app
exec su-exec ${USER} "$@"
