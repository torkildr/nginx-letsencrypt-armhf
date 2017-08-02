# nginx-letsencrypt-armhf

This project is *heavily* based on https://bitbucket.org/garymonson/lets-encrypt-nginx,
but repurposed to work on armhf-devices, like raspberry pi.

An nginx Docker image with lets-encrypt included.  Certificates are checked on
container start, and on a daily schedule.  Certificates are generated using
[acme-tiny](https://github.com/diafygi/acme-tiny), with a wrapper around it.

## Quick start

### Setup

Create a private key for Let's Encrypt:

```
openssl genrsa 4096 > secrets/account.key
```

Create a private domain key for each of your domains:

```
openssl genrsa 4096 > secrets/www.example.com.key
```

These will be used by the container to generate certificate signing requests.

DO NOT COMMIT YOUR PRIVATE KEYS TO GIT (ETC)!  These are your credentials for
generating certificates!  Also do not copy them to the image when building it.
Make the keys available to the container by mounting the directory.  See below
for an example when running Docker directly.  If using Kubernetes, you can
place them in a secrets object, and mount them from there.

Create a [strong DH group](https://weakdh.org/sysadmin.html):

```
openssl dhparam -out secrets/dhparams.pem 2048
```

### Your website configurations

The running container expects to find nginx configuration files at
/configs/http and /configs/https for http and https sites, respectively.  On
determining that a domain has a key and certificate file (which you need to
reference from the expected location within you nginx config), the config files
are copied to their final location.  It does this step so that https
configuration files can be included in the image without causing nginx to fail
startup before the certificate is generated - it just won't serve that
virtualhost, instead.

Your Docker image that builds on this image as a base should provide your nginx
configuration files in the above-mentioned directories.

Example Dockerfile for your image:

```
FROM garymonson/lets-encrypt-nginx:2
MAINTAINER gary.monson@gmail.com

# Copy configs
COPY configs /configs

# Config content (assuming config points to /website/html)
COPY html /website/html
```

Example http config:

```
server {
    listen       80;
    server_name  www.example.com;

    location /.well-known/acme-challenge/ {
        alias /acme-challenge/;
    }
    location / {
        return 404;
    }
}
```

Note that the only files served are the ACME challenge files.

Example https config:

```
server {
    listen 443 ssl;
    server_name www.example.com;

    ssl_certificate /etc/nginx/certs/www.example.com-chained.pem;
    ssl_certificate_key /etc/secrets/www.example.com.key;
    ssl_dhparam /etc/secrets/dhparams.pem;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling on;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security max-age=15768000;

    location / {
        root   /website/html;
        index  index.html index.htm;
    }
}
```

Change the root variable to point to the actual location your website files are
located.  The SSL certificate and key files must be configured at the above
locations (with filenames changed appropriately, of course), as that is where
the certificate update script expects them to be.

### Build

Building the image:

```
./build.sh
```

### Run

Running the container:

```

docker run -it --rm -v $PWD/certs:/etc/nginx/certs -v $PWD/secrets:/etc/secrets -p 80:80 -p 443:443 -e DOMAINS="www1.example.com www2.example.com" -e CA=https://acme-v01.api.letsencrypt.org garymonson/lets-encrypt-nginx
```

Replace the DOMAINS value with a comma-separated list of your domains.

If testing and you expect to be restarting a lot, replace the CA with
https://acme-staging.api.letsencrypt.org if you don't want to be rate-limited
by Lets-Encrypt.  This will generate certificates that work, but will be
reported as an invalid CA in the browser.

Note that the keys are mounted to /etc/secrets, and the certificates directory
is mounted to /etc/nginx/certs.  Using this command, you can access the
certificates from the host at $PWD/certs, as they are generated, in order to
make backups, etc.

If you wish to skip certificate checks (e.g. when running locally in a dev
environment), then set the environment variable $NO_CERT_UPDATES to any
non-empty value (e.g. with the -e option on 'docker run');

## Maintenance

As per standard nginx Docker image, the nginx logs go to stdout (except briefly
on startup as it is running in the background for a few seconds), but logs for
the daily certificate check go to /var/log/update-certs.log.
