#!/bin/sh

# current working dir is /var/www/html; declared as WORKDIR in Dockerfile for apache-php
echo "pwd: " 
pwd #this is the Linux command: print working directory
echo "PWD: " + ${PWD}
echo "TARGET_PATH: " + ${TARGET_PATH}
ls -lt

# ========== Here copy test_{environment}.php, does not overwrite. Also copies info.php, it overwrites.
# Below works OK. But now commented since we don't have test_development.php or test_production.php anymore. We only have test.php.
# [ -f ${TARGET_PATH}/test_${MY_ENV}.php ]    && echo "File already exists (test_"${MY_ENV}".php)"    || cp /tmp/test_${MY_ENV}.php ${TARGET_PATH}
[ -f ${TARGET_PATH}/test.php ]    && echo "File already exists (test.php)"    || cp /tmp/test.php ${TARGET_PATH}
cp /tmp/info.php ${TARGET_PATH}

# ========== Here add all symlinks needed
# cd ${TARGET_PATH} #not needed
echo "symlimk start... ${MY_ENV}"
[ -d ${TARGET_PATH}/uploaded_resources ]        && echo "Symlink already exists (uploaded_resources)"       || ln -s /extra/ckan_resources/ uploaded_resources
[ -d ${TARGET_PATH}/map_data ]                  && echo "Symlink already exists (map_data)"                 || ln -s /extra/map_data_final/ map_data
[ -d ${TARGET_PATH}/eol_connector_data_files ]  && echo "Symlink already exists (eol_connector_data_files)" || ln -s /extra/eol_connector_data_files/ eol_connector_data_files
[ -d ${TARGET_PATH}/dumps ]                     && echo "Symlink already exists (dumps)"                || ln -s /extra/dumps/ dumps
[ -d ${TARGET_PATH}/other_files ]               && echo "Symlink already exists (other_files)"          || ln -s /extra/other_files/ other_files
[ -d ${TARGET_PATH}/gnfinder ]                  && echo "Symlink already exists (gnfinder)"             || ln -s /extra/gnfinder/ gnfinder
echo "symlimk end... ${MY_ENV}"

# ========== This will continue the container. Without it, the container will exit.
apache2-foreground