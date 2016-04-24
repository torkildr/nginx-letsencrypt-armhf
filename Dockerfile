FROM nginx:alpine
MAINTAINER gary.monson@gmail.com

# Install prerequisites
RUN apk update
RUN apk add python
RUN apk add openssl
RUN apk add ca-certificates

# Install acme-tiny for let's-encrypt
RUN mkdir /opt
RUN wget -O /tmp/acme-tiny.zip https://github.com/diafygi/acme-tiny/archive/7a5a2558c8d6e5ab2a59b9fec9633d9e63127971.zip
RUN unzip -d /opt /tmp/acme-tiny.zip
RUN ln -s /opt/acme-tiny-7a5a2558c8d6e5ab2a59b9fec9633d9e63127971 /opt/acme-tiny
RUN rm /tmp/acme-tiny.zip

# Install certificate updating script
COPY update-certs /update-certs

# Configure updating to run daily
RUN ln -s /update-certs /etc/periodic/daily/update-certs

# Configure nginx
RUN mkdir /etc/nginx/conf.d
RUN mkdir -p /usr/share/nginx/html
RUN cp /etc/nginx/html/* /usr/share/nginx/html
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Make directories for nginx configs
RUN mkdir -p /configs/http
RUN mkdir -p /configs/https

VOLUME /acme-challenge

COPY configure-hosts.sh /
COPY docker-entrypoint.sh /

CMD /docker-entrypoint.sh
