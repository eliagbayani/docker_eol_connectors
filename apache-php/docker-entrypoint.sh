#!/bin/sh

# current working dir is /var/www/html; declared as WORKDIR in Dockerfile for apache-php
echo "pwd: " 
pwd #this is the Linux command: print working directory
echo "PWD: " + ${PWD}
echo "TARGET_PATH: " + ${TARGET_PATH}
ls -lt

# ========== Here copy test.php if it has not yet:
[ -f ${TARGET_PATH}/test.php ]    && echo "File already exists (test.php)"    || cp /tmp/test.php ${TARGET_PATH}
cp /tmp/info.php ${TARGET_PATH}

# ========== Here add all symlinks needed
cd {WEBROOT_PATH}
ln -s /Volumes/AKiTiO4/web/eoearth_images/ eoearth_images
ln -s /Volumes/AKiTiO4/webroot/eoearth/ eoearth 
ln -s /Volumes/AKiTiO4/webroot/maps_test/ maps_test 
ln -s /Volumes/AKiTiO4/webroot/LiteratureEditor/ LiteratureEditor 
ln -s /Volumes/AKiTiO4/webroot/eol_maps/ eol_maps 
ln -s /opt/homebrew/var/www/eol_php_code/applications/opendata/ opendata 
ln -s /Volumes/AKiTiO4/other_files/opendata_uploads/ opendata_uploads 
ln -s /Volumes/AKiTiO4/other_files/ other_files 
ln -s /Volumes/AKiTiO4/d_w_h/dynamic_working_hierarchy-master/ d_w_h 
ln -s /Volumes/AKiTiO4/webroot/Leaflet_Cluster_map/ Leaflet_Cluster_map 
ln -s /Volumes/Crucial_2TB/other_files2/ other_files2 
ln -s /Volumes/AKiTiO4/web/cp/ cp 
ln -s /Volumes/AKiTiO4/z_web_docs_backup/data/ data 
ln -s /Volumes/AKiTiO4/webroot/effechecka/ effechecka 
ln -s /Volumes/AKiTiO4/web/cp_new/ cp_new 
ln -s /Volumes/OWC_Express/CKAN_info/api_results/ ckan_api_results 
ln -s /Volumes/AKiTiO4/webroot/FreshData/ FreshData 
ln -s /Volumes/Thunderbolt4/wikimedia_cache/ wikimedia_cache 

# ========== This will continue the container. Without it, the container will exit.
apache2-foreground