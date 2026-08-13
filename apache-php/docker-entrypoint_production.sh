#!/bin/sh

# current working dir is /var/www/html; declared as WORKDIR in Dockerfile for apache-php
echo "pwd: "
pwd #this is the Linux command: print working directory
echo "PWD: ${PWD}"
echo "TARGET_PATH: ${TARGET_PATH}"
ls -lt

# ========== Here copy test_{environment}.php, does not overwrite. Also copies info.php, it overwrites.
# Below works OK. But now commented since we don't have test_development.php or test_production.php anymore. We only have test.php.
# Use ${PWD} (/var/www/html mount), not host TARGET_PATH — that path is not visible in-container.
[ -f ${PWD}/test.php ]    && echo "File already exists (test.php)"    || cp /tmp/test.php ${PWD}
cp /tmp/info.php ${PWD}

# Create symlink in ${PWD}. Check against ${PWD}; use ln -sfn so existing dir symlinks are not followed into nested links.
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

# ========== Here add all symlinks needed
echo "symlink start... ${MY_ENV}"
ensure_symlink uploaded_resources /extra/ckan_resources
ensure_symlink eol_connector_data_files /extra/eol_connector_data_files
ensure_symlink dumps /extra/dumps
ensure_symlink other_files /extra/other_files
ensure_symlink gnfinder /extra/gnfinder
echo "symlink end... ${MY_ENV}"

# ========== This will continue the container. Without it, the container will exit.
apache2-foreground
