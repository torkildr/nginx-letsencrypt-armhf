FROM nginx:1.9.14
MAINTAINER gary.monson@gmail.com

RUN apt-get update
RUN apt-get install -y python openssl ca-certificates wget unzip cron

# Install acme-tiny for let's-encrypt
RUN mkdir -p /opt
RUN wget -O /tmp/acme-tiny.zip https://github.com/diafygi/acme-tiny/archive/5a7b4e79bc9bd5b51739c0d8aaf644f62cc440e6.zip
RUN unzip -d /opt /tmp/acme-tiny.zip
RUN ln -s /opt/acme-tiny-5a7b4e79bc9bd5b51739c0d8aaf644f62cc440e6 /opt/acme-tiny
RUN rm /tmp/acme-tiny.zip

# Install certificate updating script
COPY update-certs /update-certs

# Configure updating to run daily
RUN ln -s /update-certs /etc/cron.daily/update-certs

# Configure nginx
RUN mkdir -p /etc/nginx/conf.d
RUN mkdir -p /usr/share/nginx/html
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Make directories for nginx configs
RUN mkdir -p /configs/http
RUN mkdir -p /configs/https

VOLUME /acme-challenge

COPY configure-hosts.sh /
COPY docker-entrypoint.sh /

CMD /docker-entrypoint.sh
