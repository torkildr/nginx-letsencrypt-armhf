#!/bin/sh

echo "Setting up configs..."

# Unencrypted
cd /configs/http
for domain in `ls -1`
do
  echo "Copying $domain for http"
  cp $domain /etc/nginx/conf.d/http-${domain}.conf
done

# TLS
cd /configs/https
for domain in `ls -1`
do
  if [ -f /etc/nginx/certs/${domain}-chained.pem -a -f /etc/secrets/${domain}.key ]; then
    echo "Copying $domain for https"
    cp $domain /etc/nginx/conf.d/https-${domain}.conf
  else
    echo "Skipping $domain for https due to missing cert and key"
  fi
done
ls -al /etc/nginx/conf.d
