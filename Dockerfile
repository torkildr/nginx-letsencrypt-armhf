FROM lsiobase/alpine.armhf:3.6
MAINTAINER torkild@retvedt.no

RUN ls

# Packages
RUN \
  apk add --no-cache \
	nginx \
	nginx-mod-http-echo \
	nginx-mod-http-fancyindex \
	nginx-mod-http-geoip \
	nginx-mod-http-headers-more \
	nginx-mod-http-set-misc \
	nginx-mod-rtmp \
	nginx-mod-stream \
	nginx-mod-stream-geoip \
	openssl \
	logrotate \
	apache2-utils \
	libressl2.5-libssl \
	python \
	ca-certificates \
	wget \
	unzip

# Install acme-tiny for let's-encrypt
RUN mkdir -p /opt
RUN wget -O /tmp/acme-tiny.zip https://github.com/diafygi/acme-tiny/archive/5a7b4e79bc9bd5b51739c0d8aaf644f62cc440e6.zip
RUN unzip -d /opt /tmp/acme-tiny.zip
RUN ln -s /opt/acme-tiny-5a7b4e79bc9bd5b51739c0d8aaf644f62cc440e6 /opt/acme-tiny
RUN rm /tmp/acme-tiny.zip

# Install certificate updating script
COPY update-certs /update-certs

# Configure updating to run daily
RUN ln -s /update-certs /etc/periodic/daily/update-certs

# Configure nginx
RUN \
  rm -Rf /etc/services.d/nginx \
  && mkdir -p /etc/nginx/conf.d \
  && mkdir -p /usr/share/nginx/html \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log
COPY etc/nginx/nginx.conf /etc/nginx/nginx.conf
COPY etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Make directories for nginx configs
RUN mkdir -p /configs/http
RUN mkdir -p /configs/https

VOLUME /acme-challenge

COPY configure-hosts.sh /
COPY docker-entrypoint.sh /

EXPOSE 80 443

CMD /docker-entrypoint.sh

