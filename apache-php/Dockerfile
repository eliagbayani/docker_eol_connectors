FROM php:8.2-apache

# very important line
RUN docker-php-ext-install mysqli

# works ok!
# We need these 2 files bec. we moved the default DocumentRoot to /html instead of default /var/www/html
COPY apache2.conf /etc/apache2/
COPY 000-default.conf  /etc/apache2/sites-available/

# these 2 php files will be used in docker-entrypoint.sh
COPY /src/test.php /tmp/test.php    
COPY /src/info.php /tmp/info.php    

# Is needed for other MySQL version.
# COPY docker-php-ext-mysqli.ini /usr/local/etc/php/conf.d/docker-php-ext-mysqli.ini

# This one works OK but we need to enter values to php.ini so we used the one below this.
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

# =============================================================================
ARG ZIP_URL="https://github.com/gnames/gnparser/releases/download/v1.11.6/gnparser-v1.11.6-linux-arm.tar.gz"
RUN wget -O /tmp/downloaded.tar.gz ${ZIP_URL}
RUN chmod 775 /tmp/downloaded.tar.gz
RUN tar -xvzf /tmp/downloaded.tar.gz -C /tmp
RUN rm /tmp/downloaded.tar.gz
RUN cp /tmp/gnparser /bin/gnparser
RUN rm /tmp/gnparser
# =============================================================================

EXPOSE 81

# restart apache
# Usage: apache2 {start|stop|graceful-stop|restart|reload|force-reload}
# RUN /etc/init.d/apache2 reload 
# CMD [ "/etc/init.d/apache2", "start" ]
# ENTRYPOINT [ "/etc/init.d/apache2", "start" ]