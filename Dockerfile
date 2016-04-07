FROM php:7.0.4-apache

MAINTAINER Jeremy PETIT "jeremy.petit@gmail.com"

# docker run --rm -e SELF_URL_PATH=http://localhost/rss -e DB_TYPE=pgsql -e DB_NAME=toto -e DB_HOST=dbhost -e DB_PORT=5432 -e DB_USER=tt-rss -e DB_PASS=tt-rss 
ENV DEBIAN_FRONTEND noninteractive

ENV TTRSS_TAG master
ENV SELF_URL_PATH 'http://example.org/tt-rss/'

# supports pgsql or mysql
ENV DB_TYPE pgsql
# database name
ENV DB_NAME changeme
# database host
ENV DB_HOST changeme
# database port
ENV DB_PORT changeme
# database tt-rss username
ENV DB_USER tt-rss
# database tt-rss password
ENV DB_PASS changeme

VOLUME ["/var/log", "/backups", "/var/www/html", "/external/nginx_conf", "/external/initdb"]
#WORKDIR /var/www/html

# install php non-default modules : mbstring (in libapache2-mod-php5), php5-gd and php5-pgsql
RUN apt-get update && apt-get install -y --no-install-recommends 	git \
																																	libapache2-mod-php5 \
																																	libfreetype6-dev \
																																	libjpeg-dev \
																																	libpng-dev \
																																	libpq-dev \
																																	php5-gd \
																																	php5-pgsql \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

# Configure new modules in php
RUN docker-php-ext-install -j$(nproc) mbstring \
																			pgsql \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd

#Deploy scripts
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

CMD ["docker-entrypoint"]
# COPY config/php.ini /usr/local/etc/php/
