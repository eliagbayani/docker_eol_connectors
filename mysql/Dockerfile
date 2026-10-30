# M5: newest 8.4 LTS patch (8.4.13, released 2026-10-20; was 8.4.3). Same LTS series: an existing data dir is
# upgraded in place on first start. Keep to 8.4.x; a jump to 9.x needs its own upgrade check.
FROM mysql:8.4.13-oraclelinux9

# If you want to edit /etc/my.cnf
# - this case enable the [includedir] provision
# !includedir /etc/mysql/conf.d
# RUN sed -i 's/\;extension=mysqli/extension=mysqli/g' /usr/local/etc/php/php.ini-production

# Just overwrite the entire my.cnf, since updating above didn't work.
# this one worked OK
COPY --chmod=644 my.cnf /etc/my.cnf

# Required. This is important:
# Without it, will have an error: Plugin 'mysql_native_password' is not loaded
COPY --chmod=644 enable-mysql-native-password.cnf /etc/mysql/conf.d/

# Initial migration of eol_development tables and a test employees table. Creates the eol_development database.
# COPY eol_development.sql /docker-entrypoint-initdb.d/eol_development.sql
ARG ENVIRONMENT_FROM_COMPOSE
RUN echo "My environment is: "${ENVIRONMENT_FROM_COMPOSE}
# COPY eol_${ENVIRONMENT_FROM_COMPOSE}.sql /docker-entrypoint-initdb.d/eol_${ENVIRONMENT_FROM_COMPOSE}.sql
# -> working but was changed to below:
COPY test_MySQL_db.sql /docker-entrypoint-initdb.d/test_MySQL_db.sql

# Root auth plugin is set at first container init (password read from env, not baked into the image).
COPY --chmod=755 root-native-password.sh /docker-entrypoint-initdb.d/zz-root-native-password.sh
