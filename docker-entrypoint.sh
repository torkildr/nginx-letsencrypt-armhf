#!/bin/sh

echo "Starting crond in the background..."
cron

/configure-hosts.sh

echo "Starting nginx in the background..."
nginx &
sleep 2

echo "Checking certs..."
/update-certs

echo "Stopping nginx..."
nginx -s quit
sleep 5

echo "Starting nginx..."
nginx -g "daemon off;"
