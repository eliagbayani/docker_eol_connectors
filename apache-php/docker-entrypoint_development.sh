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
[ -d ${TARGET_PATH}/eoearth_images ]    && echo "Symlink already exists (eoearth_images)"   || ln -s /Volumes/AKiTiO4/web/eoearth_images/ eoearth_images
[ -d ${TARGET_PATH}/eoearth ]           && echo "Symlink already exists (eoearth)"          || ln -s /Volumes/AKiTiO4/webroot/eoearth/ eoearth
[ -d ${TARGET_PATH}/maps_test ]         && echo "Symlink already exists (maps_test)"        || ln -s /Volumes/AKiTiO4/webroot/maps_test/ maps_test
[ -d ${TARGET_PATH}/eol_maps ]          && echo "Symlink already exists (eol_maps)"         || ln -s /Volumes/AKiTiO4/webroot/eol_maps/ eol_maps
[ -d ${TARGET_PATH}/opendata ]          && echo "Symlink already exists (opendata)"         || ln -s /opt/homebrew/var/www/eol_php_code/applications/opendata/ opendata 
[ -d ${TARGET_PATH}/opendata_uploads ]  && echo "Symlink already exists (opendata_uploads)" || ln -s /Volumes/AKiTiO4/other_files/opendata_uploads/ opendata_uploads
[ -d ${TARGET_PATH}/other_files ]       && echo "Symlink already exists (other_files)"      || ln -s /Volumes/AKiTiO4/other_files/ other_files
[ -d ${TARGET_PATH}/d_w_h ]             && echo "Symlink already exists (d_w_h)"            || ln -s /Volumes/AKiTiO4/d_w_h/dynamic_working_hierarchy-master/ d_w_h 
[ -d ${TARGET_PATH}/cp ]                && echo "Symlink already exists (cp)"               || ln -s /Volumes/AKiTiO4/web/cp/ cp
[ -d ${TARGET_PATH}/effechecka ]        && echo "Symlink already exists (effechecka)"       || ln -s /Volumes/AKiTiO4/webroot/effechecka/ effechecka
[ -d ${TARGET_PATH}/cp_new ]            && echo "Symlink already exists (cp_new)"           || ln -s /Volumes/AKiTiO4/web/cp_new/ cp_new
[ -d ${TARGET_PATH}/ckan_api_results ]  && echo "Symlink already exists (ckan_api_results)" || ln -s /Volumes/OWC_Express/CKAN_info/api_results/ ckan_api_results
[ -d ${TARGET_PATH}/wikimedia_cache ]   && echo "Symlink already exists (wikimedia_cache)"  || ln -s /Volumes/Thunderbolt4/wikimedia_cache/ wikimedia_cache
[ -d ${TARGET_PATH}/Pensoft_annotator ]         && echo "Symlink already exists (Pensoft_annotator)"      || ln -s /Volumes/Crucial_4TB/Pensoft_annotator/ Pensoft_annotator
[ -d ${TARGET_PATH}/Leaflet_Cluster_map ]       && echo "Symlink already exists (Leaflet_Cluster_map)"    || ln -s /Volumes/AKiTiO4/webroot/Leaflet_Cluster_map/ Leaflet_Cluster_map
[ -d ${TARGET_PATH}/other_files2 ]              && echo "Symlink already exists (other_files2)"           || ln -s /Volumes/Crucial_2TB/other_files2/ other_files2
[ -d ${TARGET_PATH}/cache_LiteratureEditor ]    && echo "Symlink already exists (cache_LiteratureEditor)" || ln -s /Volumes/Crucial_2TB/cache_LiteratureEditor/ cache_LiteratureEditor

# These 2 are real folders for PHP 8, not symlinks.
# [ -d ${TARGET_PATH}/LiteratureEditor ]  && echo "Symlink already exists (LiteratureEditor)" || ln -s /Volumes/AKiTiO4/webroot/LiteratureEditor/ LiteratureEditor
# [ -d ${TARGET_PATH}/FreshData ]         && echo "Symlink already exists (FreshData)"        || ln -s /Volumes/AKiTiO4/webroot/FreshData/ FreshData

echo "symlimk end... ${MY_ENV}"

# We may need it when we go back to Neo4j tasks:
# chmod -R 777 ${TARGET_PATH}/php_neo4j/
# chmod -R 777 ${TARGET_PATH}/php_neo4j/.

# ========== Here copy gnparser, does not overwrite. gnparser from: gnparser-v1.11.6-linux-arm.tar.gz
[ -f /bin/gnparser ]    && echo "File already exists (gnparser)"    || cp /tmp/gnparser /bin/


# ========== This will continue the container. Without it, the container will exit.
apache2-foreground