FROM php:8.2-apache
# FROM php:8.0-apache
# FROM php:7.4-apache
# FROM php:8.0.30-apache-bullseye
# FROM php:7.1-apache-stretch

# this will use Debian VERSION="12 (bookworm)"
# $ cat /etc/os-release

# very important line
RUN docker-php-ext-install mysqli

# works ok!
# COPY apache2.conf /etc/apache2/
# -> this one works but it overwrites the entire apache2.conf
# COPY apache2_added.conf /etc/apache2/sites-available/
# -> this is best practice. Only add per line for additional configs
# -> but since we declare /etc/apache2/sites-available/ as a volume, we cannot COPY to it anymore
# -> so we just put apache2_added.conf readily to the host volume apache2_config 


# COPY docker-php-ext-mysqli.ini /usr/local/etc/php/conf.d/docker-php-ext-mysqli.ini

# during dev only
# COPY ./src/info.php /var/www/html/info.php
# COPY ./src/test.php /var/www/html/test.php
# COPY ./src/test2.php /var/www/html/test2.php
# COPY /Volumes/OWC_Express/other_files/My_Docker/eli_php/src /var/www/html/


# Update Apache Configuration -- copied template
# RUN sed -E -i -e '/<Directory "\/var\/www\/html">/,/<\/Directory>/s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
# RUN sed -E -i -e 's/DirectoryIndex (.*)$/DirectoryIndex index.php \1/g' /etc/httpd/conf/httpd.conf

# enabled mysqli in php.ini file - WORKS!
# RUN sed -i 's/\;extension=mysqli/extension=mysqli/g' /usr/local/etc/php/php.ini-development
# RUN sed -i 's/\;extension=mysqli/extension=mysqli/g' /usr/local/etc/php/php.ini-production

# for PHP 7.1.33
# RUN sed -i 's/\;extension=php_mysqli.dll/extension=php_mysqli.dll/g' /usr/local/etc/php/php.ini-development

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini

# WORKDIR /var/www/html

# Update other OS stuff
RUN apt update
RUN apt upgrade -y
RUN apt install -y vim
# -y is always confirmation to proceed

# RUN apt install php8.0
# RUN php -v
# RUN apt install -y php8.0-mysql

# install other modules in PHP
RUN apt-get upgrade -y
# RUN apt-get install -y build-essential libtool autoconf unzip wget libcurl4-gnutls-dev 
# RUN apt-get install -y vi

EXPOSE 81

# restart apache
# Usage: apache2 {start|stop|graceful-stop|restart|reload|force-reload}
# RUN /etc/init.d/apache2 reload 
# CMD [ "/etc/init.d/apache2", "start" ]
# ENTRYPOINT [ "/etc/init.d/apache2", "start" ]