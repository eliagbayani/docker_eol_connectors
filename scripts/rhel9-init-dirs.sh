#!/bin/bash
# Create host directories for EOL Connectors on RHEL 9.
# Run as root:  sudo bash scripts/rhel9-init-dirs.sh
#
# Default base: /opt/eol  (override with EOL_BASE=/srv/eol)

set -euo pipefail

EOL_BASE="${EOL_BASE:-/opt/eol}"

echo "Creating EOL Connectors directories under ${EOL_BASE}..."

# Core service data
mkdir -p "${EOL_BASE}/mysql_data"
mkdir -p "${EOL_BASE}/webroot"
mkdir -p "${EOL_BASE}/apache2_logs"
mkdir -p "${EOL_BASE}/jenkins_home"
mkdir -p "${EOL_BASE}/jenkins_tmp"
mkdir -p "${EOL_BASE}/python_projects"

# Neo4j
mkdir -p "${EOL_BASE}/neo4j/data"
mkdir -p "${EOL_BASE}/neo4j/logs"
mkdir -p "${EOL_BASE}/neo4j/import"
mkdir -p "${EOL_BASE}/neo4j/import2"
mkdir -p "${EOL_BASE}/neo4j/plugins"

# EXTRA_PATH — subdirs expected by docker-entrypoint_production.sh
# (create empty dirs; populate with real data before or after first deploy)
EXTRA="${EOL_BASE}/extra"
mkdir -p "${EXTRA}/cache_LiteratureEditor"
mkdir -p "${EXTRA}/ckan_resources"
mkdir -p "${EXTRA}/eoearth_img/eoearth_images"
mkdir -p "${EXTRA}/LiteratureEditor_img/LiteratureEditor_images"
mkdir -p "${EXTRA}/map_data_final"
mkdir -p "${EXTRA}/eol_connector_data_files"
mkdir -p "${EXTRA}/dumps"
mkdir -p "${EXTRA}/Pensoft_annotator"
mkdir -p "${EXTRA}/other_files"
mkdir -p "${EXTRA}/map_data_dwca"
mkdir -p "${EXTRA}/wikimedia_cache"
mkdir -p "${EXTRA}/gnfinder"

echo "Done."
echo ""
echo "Next steps:"
echo "  1. Copy connector code into ${EOL_BASE}/webroot (include eol_php8_code/)"
echo "  2. Copy/rsync extra datasets into ${EOL_BASE}/extra/ subdirs"
echo "  3. cp .env.production.sample .env  &&  edit passwords"
echo "  4. chown -R 1000:1000 ${EOL_BASE}/jenkins_home ${EOL_BASE}/jenkins_tmp"
echo "  5. chcon -Rt svirt_sandbox_file_t ${EOL_BASE}   # if SELinux enforcing"
echo "  6. docker compose -f docker-compose.yml up -d --build"
