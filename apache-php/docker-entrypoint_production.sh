#!/bin/sh

# current working dir is /var/www/html; declared as WORKDIR in Dockerfile for apache-php
echo "pwd: " 
pwd #this is the Linux command: print working directory
echo "PWD: " + ${PWD}
echo "TARGET_PATH: " + ${TARGET_PATH}
ls -lt

# ========== Here copy test.php, does not overwrite. Also copies info.php, it overwrites.
[ -f ${TARGET_PATH}/test.php ]    && echo "File already exists (test.php)"    || cp /tmp/test.php ${TARGET_PATH}
cp /tmp/info.php ${TARGET_PATH}

# ========== Here add all symlinks needed
# cd ${TARGET_PATH} #not needed
echo "symlimk start... ${MY_ENV}"
ln -s /extra/cache_LiteratureEditor/ cache_LiteratureEditor
ln -s /extra/ckan_resources/ uploaded_resources
ln -s /extra/eoearth_img/eoearth_images/ eoearth_images
ln -s /extra/LiteratureEditor_img/LiteratureEditor_images/ LiteratureEditor_images
ln -s /extra/map_data_final/ map_data
ln -s /extra/eol_connector_data_files/ eol_connector_data_files
ln -s /extra/dumps/ dumps
ln -s /extra/Pensoft_annotator/ Pensoft_annotator
ln -s /extra/other_files/ other_files
ln -s /extra/map_data_dwca/ map_data2
ln -s /extra/wikimedia_cache/ wikimedia_cache
ln -s /var/www/html/eol_php_code/applications/opendata/ opendata
ln -s /extra/gnfinder/ gnfinder
echo "symlimk end... ${MY_ENV}"

# ========== This will continue the container. Without it, the container will exit.
apache2-foreground