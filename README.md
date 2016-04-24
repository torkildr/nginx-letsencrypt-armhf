# lets-encrypt-nginx

An nginx Docker image with lets-encrypt included.  Certificates are checked on
container start, and on a daiy schedule.

## Quick start

### Setup

TODO

### Build

Building the image:

```
./build.sh
```

### Run

Running the container:

```

docker run -it --rm -v $PWD/certs:/etc/nginx/certs -v $PWD/secrets:/etc/secrets -p 80:80 -p 443:443 -e DOMAINS="www1.example.com www2.example.com" -e CA=https://acme-v01.api.letsencrypt.org lets-encrypt-nginx
```

Replace the DOMAINS value with a comma-separated list of your domains.

If testing and you expect to be restarting a lot, replace the CA with
https://acme-staging.api.letsencrypt.org if you don't want to be rate-limited
by Lets-Encrypt.  This will generate certificates that work, but will be
reported as an invalid CA in the browser.
