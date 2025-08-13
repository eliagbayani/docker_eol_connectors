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
[ -d ${TARGET_PATH}/cache_LiteratureEditor ] && echo "Symlink already exists (cache_LiteratureEditor)" || ln -s /extra/cache_LiteratureEditor/ cache_LiteratureEditor
[ -d ${TARGET_PATH}/uploaded_resources ] && echo "Symlink already exists (uploaded_resources)" || ln -s /extra/ckan_resources/ uploaded_resources
[ -d ${TARGET_PATH}/eoearth_images ] && echo "Symlink already exists (eoearth_images)" || ln -s /extra/eoearth_img/eoearth_images/ eoearth_images
[ -d ${TARGET_PATH}/LiteratureEditor_images ] && echo "Symlink already exists (LiteratureEditor_images)" || ln -s /extra/LiteratureEditor_img/LiteratureEditor_images/ LiteratureEditor_images
[ -d ${TARGET_PATH}/map_data ] && echo "Symlink already exists (map_data)" || ln -s /extra/map_data_final/ map_data
[ -d ${TARGET_PATH}/eol_connector_data_files ] && echo "Symlink already exists (eol_connector_data_files)" || ln -s /extra/eol_connector_data_files/ eol_connector_data_files
[ -d ${TARGET_PATH}/dumps ] && echo "Symlink already exists (dumps)" || ln -s /extra/dumps/ dumps
[ -d ${TARGET_PATH}/Pensoft_annotator ] && echo "Symlink already exists (Pensoft_annotator)" || ln -s /extra/Pensoft_annotator/ Pensoft_annotator
[ -d ${TARGET_PATH}/other_files ] && echo "Symlink already exists (other_files)" || ln -s /extra/other_files/ other_files
[ -d ${TARGET_PATH}/map_data2 ] && echo "Symlink already exists (map_data2)" || ln -s /extra/map_data_dwca/ map_data2
[ -d ${TARGET_PATH}/wikimedia_cache ] && echo "Symlink already exists (wikimedia_cache)" || ln -s /extra/wikimedia_cache/ wikimedia_cache
[ -d ${TARGET_PATH}/opendata ] && echo "Symlink already exists (opendata)" || ln -s /var/www/html/eol_php_code/applications/opendata/ opendata
[ -d ${TARGET_PATH}/gnfinder ] && echo "Symlink already exists (gnfinder)" || ln -s /extra/gnfinder/ gnfinder
echo "symlimk end... ${MY_ENV}"

# ========== This will continue the container. Without it, the container will exit.
apache2-foreground