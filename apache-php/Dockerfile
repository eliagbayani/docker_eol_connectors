FROM php:8.2-apache

# very important line
RUN docker-php-ext-install mysqli

# works ok!
# We need these 2 files bec. we moved the default DocumentRoot to /html instead of default /var/www/html
COPY apache2.conf /etc/apache2/
COPY 000-default.conf  /etc/apache2/sites-available/

COPY /src/test.php /var/www/html/
COPY /src/info.php /var/www/html/

# Is needed for other MySQL version.
# COPY docker-php-ext-mysqli.ini /usr/local/etc/php/conf.d/docker-php-ext-mysqli.ini

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# WORKDIR /var/www/html

# Update other OS stuff
RUN apt update
RUN apt upgrade -y
RUN apt install -y vim
# -y is always confirmation to proceed

# install zip packages:
RUN apt install zip unzip

# install other modules in PHP
RUN apt-get upgrade -y

EXPOSE 81

# restart apache
# Usage: apache2 {start|stop|graceful-stop|restart|reload|force-reload}
# RUN /etc/init.d/apache2 reload 
# CMD [ "/etc/init.d/apache2", "start" ]
# ENTRYPOINT [ "/etc/init.d/apache2", "start" ]