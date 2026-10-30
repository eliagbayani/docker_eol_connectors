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
# The webroot is copied from eol-archive, so a name may already exist: it is left alone, with a WARNING when it is
# not the expected link or does not work inside the container (only /var/www/html and /extra exist here).
ensure_symlink() {
  name="$1"
  target="$2"
  dest="${PWD}/${name}"
  if [ -L "${dest}" ]; then
    current=$(readlink "${dest}")
    if [ ! -e "${dest}" ]; then
      echo "WARNING: ${name} -> ${current} is broken in the container (expected -> ${target})"
    elif [ "${current%/}" != "${target%/}" ]; then
      echo "WARNING: ${name} -> ${current}, expected -> ${target} (left as is)"
    else
      echo "Symlink already exists (${name})"
    fi
  elif [ -e "${dest}" ]; then
    echo "WARNING: ${name} is a real folder/file, not a link to ${target} (left as is)"
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

# ========== Folders the code writes to; on eol-archive some were links (e.g. into /extra)
for d in eol_php8_code/temp eol_php8_code/applications/content_server/resources FreshData_min/sh_files FreshData_min/TSV_files; do
  [ -d "${PWD}/${d}" ] || echo "WARNING: ${d} is missing or a broken link: $(readlink "${PWD}/${d}" 2>/dev/null)"
done
# Broken links in the first 2 levels of the webroot (e.g. targets that existed only on eol-archive)
broken=$(find -L "${PWD}" -maxdepth 2 -type l 2>/dev/null)
if [ -n "${broken}" ]; then
  echo "WARNING: $(echo "${broken}" | wc -l) broken link(s) in the webroot (first 20):"
  echo "${broken}" | head -20 | while read -r l; do echo "  ${l#${PWD}/} -> $(readlink "${l}")"; done
fi

# ========== This will continue the container. Without it, the container will exit.
# exec (M1): Apache replaces this shell as PID 1, so `docker stop` reaches it and it shuts down cleanly.
exec apache2-foreground
