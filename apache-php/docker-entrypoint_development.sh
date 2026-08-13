#!/bin/sh

# current working dir is /var/www/html; declared as WORKDIR in Dockerfile for apache-php
echo "pwd: "
pwd #this is the Linux command: print working directory
echo "PWD: ${PWD}"
echo "TARGET_PATH: ${TARGET_PATH}"
ls -lt

# ========== Here copy test_{environment}.php, does not overwrite. Also copies info.php, it overwrites.
# Below works OK. But now commented since we don't have test_development.php or test_production.php anymore. We only have test.php.
# [ -f ${PWD}/test_${MY_ENV}.php ]    && echo "File already exists (test_"${MY_ENV}".php)"    || cp /tmp/test_${MY_ENV}.php ${PWD}
[ -f ${PWD}/test.php ]    && echo "File already exists (test.php)"    || cp /tmp/test.php ${PWD}
cp /tmp/info.php ${PWD}

# Create symlink in ${PWD} (/var/www/html). Check existence against ${PWD}
ensure_symlink() {
  name="$1"
  target="$2"
  dest="${PWD}/${name}"
  if [ -L "${dest}" ] || [ -e "${dest}" ]; then
    echo "Symlink already exists (${name})"
  else
    ln -sfn "${target}" "${dest}"
    echo "Created symlink (${name})"
  fi
}

# Remove accidental nested link created by the old ln behavior
NESTED_OPENDATA="${PWD}/eol_php8_code/applications/opendata/opendata"
if [ -L "${NESTED_OPENDATA}" ]; then
  rm -f "${NESTED_OPENDATA}"
  echo "Removed nested accidental symlink: ${NESTED_OPENDATA}"
fi

# ========== Here add all symlinks needed
echo "symlink start... ${MY_ENV}"
ensure_symlink opendata /var/www/html/eol_php8_code/applications/opendata
ensure_symlink eoearth_images /Volumes/AKiTiO4/web/eoearth_images
ensure_symlink eoearth /Volumes/AKiTiO4/webroot/eoearth
ensure_symlink maps_test /Volumes/AKiTiO4/webroot/maps_test
ensure_symlink eol_maps /Volumes/AKiTiO4/webroot/eol_maps
ensure_symlink opendata_uploads /Volumes/AKiTiO4/other_files/opendata_uploads
ensure_symlink other_files /Volumes/AKiTiO4/other_files
ensure_symlink d_w_h /Volumes/AKiTiO4/d_w_h/dynamic_working_hierarchy-master
ensure_symlink cp /Volumes/AKiTiO4/web/cp
ensure_symlink effechecka /Volumes/AKiTiO4/webroot/effechecka
ensure_symlink cp_new /Volumes/AKiTiO4/web/cp_new
ensure_symlink ckan_api_results /Volumes/AKiTiO4/CKAN_info/api_results
ensure_symlink wikimedia_cache /Volumes/AKiTiO4/wikimedia_cache
ensure_symlink Leaflet_Cluster_map /Volumes/AKiTiO4/webroot/Leaflet_Cluster_map
ensure_symlink other_files2 /Volumes/Crucial_2TB/other_files2
ensure_symlink cache_LiteratureEditor /Volumes/Crucial_2TB/cache_LiteratureEditor
ensure_symlink Pensoft_annotator /Volumes/Crucial_4TB/Pensoft_annotator
ensure_symlink gnfinder /Volumes/Crucial_4TB/gnfinder
echo "symlink end... ${MY_ENV}"

# ========== This will continue the container. Without it, the container will exit.
apache2-foreground
