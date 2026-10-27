#!/bin/sh

# current working dir is /var/www/html; declared as WORKDIR in Dockerfile for apache-php
echo "pwd: "
pwd #this is the Linux command: print working directory
echo "PWD: ${PWD}"
echo "TARGET_PATH: ${TARGET_PATH}"
ls -lt

# ========== Production: test.php and info.php are NOT copied (the development entrypoint does that).
# info.php (phpinfo) shows the server's full PHP setup, so it must not be public.
[ -f ${PWD}/info.php ] && echo "WARNING: ${PWD}/info.php exists in the webroot. Delete it on production."

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
