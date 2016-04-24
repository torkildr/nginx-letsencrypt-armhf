#!/bin/sh

/configure-hosts.sh

echo "Starting nginx..."
nginx -g "daemon off;"
