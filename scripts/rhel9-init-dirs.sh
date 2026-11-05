#!/bin/bash
# Create host directories for EOL Connectors on RHEL 9.
# Safe to re-run: existing directories are skipped (no error).
# Run as root:  sudo bash scripts/rhel9-init-dirs.sh
#
# Default base: /extra/eol_docker (override with EOL_BASE=...). The data folders go in EXTRA_PATH,
# default /extra: on eol-archive that is the existing data volume, so only missing folders are created.

set -euo pipefail

EOL_BASE="${EOL_BASE:-/extra/eol_docker}"
EXTRA_PATH="${EXTRA_PATH:-/extra}"

# Create dir if missing; skip quietly if it already exists as a directory.
ensure_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    echo "  exists:  $dir"
  elif [[ -e "$dir" ]]; then
    echo "  ERROR:   $dir exists but is not a directory" >&2
    return 1
  else
    mkdir -p "$dir"
    echo "  created: $dir"
  fi
}

echo "Creating EOL Connectors directories under ${EOL_BASE}..."
echo ""

# Core service data
ensure_dir "${EOL_BASE}/mysql_data"
ensure_dir "${EOL_BASE}/webroot"
ensure_dir "${EOL_BASE}/apache2_logs"
ensure_dir "${EOL_BASE}/jenkins_home"
ensure_dir "${EOL_BASE}/jenkins_tmp"
ensure_dir "${EOL_BASE}/python_projects"

# EXTRA_PATH — subdirs expected by docker-entrypoint_production.sh
EXTRA="${EXTRA_PATH}"
ensure_dir "${EXTRA}/ckan_resources"
ensure_dir "${EXTRA}/eol_connector_data_files"
ensure_dir "${EXTRA}/dumps"
ensure_dir "${EXTRA}/other_files"
ensure_dir "${EXTRA}/gnfinder"

echo ""
echo "Done."
echo ""
echo "Next steps:"
echo "  1. git clone eol_php8_code, FreshData_min, LiteratureEditor_min into ${EOL_BASE}/webroot + work folders (guide step 5)"
echo "  2. Data stays in ${EXTRA}; give web (33) and Jenkins (1000) write access with setfacl (guide step 3)"
echo "  3. cp .env.production.sample .env  &&  edit passwords"
echo "  4. chown -R 1000:1000 ${EOL_BASE}/jenkins_home ${EOL_BASE}/jenkins_tmp"
echo "  5. If SELinux is enforcing (persistent labels; see docs/rhel9_production_env_guide.md):"
echo "       semanage fcontext -a -t container_file_t \"${EXTRA}(/.*)?\"      # covers ${EOL_BASE} when it is inside ${EXTRA}"
echo "       semanage fcontext -a -t container_file_t \"${EOL_BASE}(/.*)?\"   # only if ${EOL_BASE} is elsewhere"
echo "       restorecon -R ${EXTRA} ${EOL_BASE}     (after Docker's data-root rule: guide step 1)"
echo "  6. docker compose -f docker-compose.yml build --no-cache --pull"
echo "     docker compose -f docker-compose.yml up -d"
