#!/bin/bash
set -e

rpcbind -f &

exec su-exec root "$@"

