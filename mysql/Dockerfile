FROM mysql:8.4.3-oraclelinux9
# https://hub.docker.com/layers/library/mysql/8.4.3-oraclelinux9/images/sha256-71da9b9b29db60ff36bae7c55b517428c86f56f97832b6cab5eb207e7e3ab5f8?context=explore

# If you want to edit /etc/my.cnf
# - this case enable the [includedir] provision
# !includedir /etc/mysql/conf.d
# RUN sed -i 's/\;extension=mysqli/extension=mysqli/g' /usr/local/etc/php/php.ini-production

# Just overwrite the entire my.cnf, since updating above didn't work.
# this one worked OK
COPY my.cnf /etc/my.cnf

# Required. This is important:
# Without it, will have an error: Plugin 'mysql_native_password' is not loaded
COPY enable-mysql-native-password.cnf /etc/mysql/conf.d/

# Initial migration of eol_development tables and a test employees table. Creates the eol_development database.
COPY eol_development.sql /docker-entrypoint-initdb.d/eol_development.sql

# works OK. From: https://stackoverflow.com/questions/29261811/use-docker-compose-env-variable-in-dockerbuild-file
# Passing vars from compose file to container during build.
ARG MRP_FROM_COMPOSE
RUN echo "ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY '"${MRP_FROM_COMPOSE}"';" > /docker-entrypoint-initdb.d/eli.sql