FROM php:8.2-apache

# very important line
RUN docker-php-ext-install mysqli

# works ok!
# We need these 2 files bec. we moved the default DocumentRoot to /html instead of default /var/www/html
COPY apache2.conf /etc/apache2/
COPY 000-default.conf  /etc/apache2/sites-available/

# these 2 php files will be used in docker-entrypoint.sh
ARG ENVIRONMENT_FROM_COMPOSE
# Below works OK. But we don't have test_development.php nor test_production.php anymore. Only test.php.
# COPY /src/test_${ENVIRONMENT_FROM_COMPOSE}.php /tmp/test_${ENVIRONMENT_FROM_COMPOSE}.php
COPY /src/test.php /tmp/test.php
COPY /src/info.php /tmp/info.php
COPY /src/list.php /tmp/list.php


### ----- this is original
COPY docker-entrypoint_${ENVIRONMENT_FROM_COMPOSE}.sh /usr/local/bin/docker-entrypoint_${ENVIRONMENT_FROM_COMPOSE}.sh
### ----- this is for K8s
# COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
# RUN chmod +x /usr/local/bin/docker-entrypoint.sh #to fix permissions


# Is needed for other MySQL version.
# COPY docker-php-ext-mysqli.ini /usr/local/etc/php/conf.d/docker-php-ext-mysqli.ini

# This one works OK but we need to enter our own values to php.ini so we used the one below this.
### RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# We need to do this bec. we needed to update php.ini with our own values e.g. upload_max_filesize
COPY php.ini.txt /usr/local/etc/php/php.ini

# WORKDIR /var/www/html

# Update other OS stuff
RUN apt update
RUN apt upgrade -y
RUN apt install -y vim
# -y is always confirmation to proceed

# install zip packages, curl, etc:
RUN apt install zip unzip
RUN apt-get install curl
RUN apt-get install iputils-ping -y
RUN apt install wget -y

# install other modules in PHP
RUN apt-get upgrade -y

# Install required system dependencies for the YAML extension
RUN apt-get update -y 
RUN apt-get install libyaml-dev -y
# Install the yaml PECL extension and enable it
#RUN pecl install yaml && docker-php-ext-enable yaml
# -> above line had an error

# =============================================================================
ARG ZIP_URL="https://github.com/gnames/gnparser/releases/download/v1.11.6/gnparser-v1.11.6-linux-arm.tar.gz"
RUN wget -O /tmp/downloaded.tar.gz ${ZIP_URL}
RUN chmod 775 /tmp/downloaded.tar.gz
RUN tar -xvzf /tmp/downloaded.tar.gz -C /tmp
RUN rm /tmp/downloaded.tar.gz
RUN cp /tmp/gnparser /bin/gnparser
RUN rm /tmp/gnparser
# =============================================================================
# Step 1: Set the working directory inside the container
WORKDIR /var/www/html
# Step 2: Copy your PHP source files into the container's working directory
COPY ./src /var/www/html
# Step 3: Secure your files by setting the correct web server permissions
RUN chown -R www-data:www-data /var/www/html
# =============================================================================
EXPOSE 81
