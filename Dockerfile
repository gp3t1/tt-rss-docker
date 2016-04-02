FROM php:7.0.4-fpm

# install non-default modules : mbstring (in libapache2-mod-php5), php5-gd and php5-pgsql
RUN apt-get update && apt-get install -y --no-install-recommends 	libapache2-mod-php5 \
																																	libfreetype6-dev \
																																	libjpeg-dev \
																																	libpng-dev \
																																	libpq-dev \
																																	libwebp5 \
																																	php5-gd \
																																	php5-pgsql \
	&& rm -rf /var/lib/apt/lists/*

# Configure new modules in php
RUN docker-php-ext-install -j$(nproc) mbstring \
																			pgsql \
																			webp \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd


