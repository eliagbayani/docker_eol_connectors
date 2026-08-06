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
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        wget \
        zip \
        unzip \
        file \
        iputils-ping \
        vim \
        libyaml-dev \
        $PHPIZE_DEPS \
    && pecl install yaml-2.2.4 \
    && docker-php-ext-enable yaml \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $PHPIZE_DEPS \
    && rm -rf /var/lib/apt/lists/*


# =============================================================================
# gnparser — arch follows image platform (amd64 → linux-x86, arm64 → linux-arm)
# Override: --build-arg GNPARSER_URL=... or set GNPARSER_URL in .env for Compose
ARG GNPARSER_VERSION=1.15.0
ARG TARGETARCH
ARG GNPARSER_URL=
RUN set -eux; \
    if [ -n "${GNPARSER_URL}" ]; then \
      URL="${GNPARSER_URL}"; \
    else \
      case "${TARGETARCH}" in \
        amd64) GNPARSER_ARCH=x86 ;; \
        arm64) GNPARSER_ARCH=arm ;; \
        *) echo "Unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
      esac; \
      URL="https://github.com/gnames/gnparser/releases/download/v${GNPARSER_VERSION}/gnparser-v${GNPARSER_VERSION}-linux-${GNPARSER_ARCH}.tar.gz"; \
    fi; \
    wget -qO /tmp/gnparser.tar.gz "${URL}"; \
    tar -xzf /tmp/gnparser.tar.gz -C /tmp; \
    mv /tmp/gnparser /usr/local/bin/gnparser; \
    chmod 755 /usr/local/bin/gnparser; \
    rm -f /tmp/gnparser.tar.gz
# =============================================================================
# Step 1: Set the working directory inside the container
WORKDIR /var/www/html
# Step 2: Copy your PHP source files into the container's working directory
COPY ./src /var/www/html
# Step 3: Secure your files by setting the correct web server permissions
RUN chown -R www-data:www-data /var/www/html
# =============================================================================
EXPOSE 81
