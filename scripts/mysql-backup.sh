#!/usr/bin/env bash
# Nightly MySQL backup: a consistent dump of all databases from the running db container,
# gzip'd into BACKUP_DIR, keeping the newest KEEP files. Copying mysql_data while MySQL runs
# can give a broken copy; this dump is the file to back up or copy elsewhere.
# Run from the repo folder, as the deploying login (docker group), e.g. from its crontab:
#   30 2 * * * cd /extra/eol_docker/docker_eol_connectors && bash scripts/mysql-backup.sh >> /extra/eol_docker/backups/mysql-backup.log 2>&1
# The root password stays inside the container (MYSQL_ROOT_PASSWORD); it is never on the command line here.
# Settings (environment):
#   COMPOSE="docker compose -f docker-compose.yml"   how to reach the stack
#   BACKUP_DIR=/extra/eol_docker/backups              where the dumps go (created with mode 700)
#   KEEP=10                                           how many dumps to keep (the 11th run deletes the oldest)
# Restore (replaces the databases in the dump):
#   gunzip -c <file>.sql.gz | docker compose -f docker-compose.yml exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot'

set -euo pipefail
COMPOSE=${COMPOSE:-docker compose -f docker-compose.yml}
BACKUP_DIR=${BACKUP_DIR:-/extra/eol_docker/backups}
KEEP=${KEEP:-10}

umask 077
mkdir -p "$BACKUP_DIR"
out="$BACKUP_DIR/mysql_$(date +%Y%m%d_%H%M).sql.gz"
tmp="$out.part"
trap 'rm -f "$tmp"' EXIT

$COMPOSE exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" exec mysqldump -uroot --all-databases --single-transaction --routines --events --triggers' | gzip > "$tmp"
gzip -t "$tmp"
mv "$tmp" "$out"
echo "$(date '+%Y-%m-%d %H:%M') OK $out ($(du -h "$out" | cut -f1))"

# Keep the newest KEEP dumps: after a new one is written, any beyond KEEP (the oldest) are deleted
ls -1t "$BACKUP_DIR"/mysql_*.sql.gz | tail -n +$((KEEP + 1)) | while IFS= read -r old; do rm -f "$old"; done
