#!/bin/bash
# Create host directories for EOL Connectors on RHEL 9.
# Safe to re-run: existing directories are skipped (no error).
# Run as root:  sudo bash scripts/rhel9-init-dirs.sh
#
# Default base: /opt/eol  (override with EOL_BASE=/srv/eol)

set -euo pipefail

EOL_BASE="${EOL_BASE:-/opt/eol}"

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

# Neo4j
ensure_dir "${EOL_BASE}/neo4j/data"
ensure_dir "${EOL_BASE}/neo4j/logs"
ensure_dir "${EOL_BASE}/neo4j/import"
ensure_dir "${EOL_BASE}/neo4j/import2"
ensure_dir "${EOL_BASE}/neo4j/plugins"

# EXTRA_PATH — subdirs expected by docker-entrypoint_production.sh
EXTRA="${EOL_BASE}/extra"
ensure_dir "${EXTRA}/cache_LiteratureEditor"
ensure_dir "${EXTRA}/ckan_resources"
ensure_dir "${EXTRA}/eoearth_img/eoearth_images"
ensure_dir "${EXTRA}/LiteratureEditor_img/LiteratureEditor_images"
ensure_dir "${EXTRA}/map_data_final"
ensure_dir "${EXTRA}/eol_connector_data_files"
ensure_dir "${EXTRA}/dumps"
ensure_dir "${EXTRA}/Pensoft_annotator"
ensure_dir "${EXTRA}/other_files"
ensure_dir "${EXTRA}/map_data_dwca"
ensure_dir "${EXTRA}/wikimedia_cache"
ensure_dir "${EXTRA}/gnfinder"

echo ""
echo "Done."
echo ""
echo "Next steps:"
echo "  1. Copy connector code into ${EOL_BASE}/webroot (include eol_php8_code/)"
echo "  2. Copy/rsync extra datasets into ${EOL_BASE}/extra/ subdirs"
echo "  3. cp .env.production.sample .env  &&  edit passwords"
echo "  4. chown -R 1000:1000 ${EOL_BASE}/jenkins_home ${EOL_BASE}/jenkins_tmp"
echo "  5. chcon -Rt svirt_sandbox_file_t ${EOL_BASE}   # if SELinux enforcing"
echo "  6. docker compose -f docker-compose.yml up -d --build"
