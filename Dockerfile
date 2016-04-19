FROM php:7.0.4-apache

MAINTAINER Jeremy PETIT "jeremy.petit@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
##  Default tt-rss installation
ENV TTRSS_REPO "https://tt-rss.org/git/tt-rss.git"
ENV TTRSS_TAG 16.3

##  Default tt-rss configuration
# External URl for tt-rss
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
# TTRSS_OPTS can provide additional properties to tt-rss (config.php)
# It must be in the form : "<prop_name>=<prop_value>[; <prop2_name>=<prop2_value>]..."
#    no space around '=' and one '; ' between each property definition (';'+' ')
ENV TTRSS_OPTS ""

##  VOLUMES
VOLUME ["/backups", "/var/www/html", "/external/nginx_conf", "/external/initdb"]
# and maybe "/var/log/ttrss"

##  Install php non-default modules : mbstring (in libapache2-mod-php5), php5-gd and php5-pgsql
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

##  Configure new modules in php
RUN docker-php-ext-install -j$(nproc) mbstring \
																			pgsql \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd

##  INSTALL default version of tt-rss in temp folder TODO: should compress it!
RUN git clone -b "${TTRSS_TAG}" "${TTRSS_REPO}" "/ttrss_${TTRSS_TAG}"

##  Deploy scripts
COPY bin/* /usr/local/bin/
RUN chmod +x /usr/local/bin/*

# WORKDIR /var/www/html
ENTRYPOINT ["docker-entrypoint"]
CMD ["tt-rss"]

