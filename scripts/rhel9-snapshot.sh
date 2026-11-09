#!/usr/bin/env bash
# Snapshot of everything on eol-archive that is NOT in git and is needed to rebuild the stack on another machine:
# settings with secrets (.env, database.yml, production.php, HTTPS certificate), Jenkins' configuration (jobs, users,
# credentials, secrets, plugin list), host settings (Docker, containerd, systemd, SELinux rules, ACLs, crontab),
# the newest MySQL dump, and a report of versions and commits. Read-only for the stack; it writes one archive.
#
# Run from the repo folder, with sudo (it reads files owned by root and by Jenkins' uid 1000):
#   sudo bash scripts/rhel9-snapshot.sh
# Output: /extra/eol_docker/snapshots/eol-archive_snapshot_YYYYMMDD_HHMM.tar.gz (mode 600, owned by the caller)
# The archive holds passwords, tokens and keys: keep it as private as .env. Copy it off the server with scp/rsync.
#
# Settings (environment):
#   EOL_BASE=/extra/eol_docker     the stack's folder
#   OUT_DIR=$EOL_BASE/snapshots    where the archive goes (mode 700)

set -uo pipefail
[ "$(id -u)" = 0 ] || { echo "Run with sudo: sudo bash scripts/rhel9-snapshot.sh"; exit 1; }
EOL_BASE=${EOL_BASE:-/extra/eol_docker}
REPO=$EOL_BASE/docker_eol_connectors
WEB=$EOL_BASE/webroot
JH=$EOL_BASE/jenkins_home
OUT_DIR=${OUT_DIR:-$EOL_BASE/snapshots}
OWNER=${SUDO_USER:-root}
STAMP=$(date +%Y%m%d_%H%M)
NAME=eol-archive_snapshot_$STAMP

umask 077
mkdir -p "$OUT_DIR"; chmod 700 "$OUT_DIR"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
S=$TMP/$NAME; mkdir -p "$S"/{stack,code_config,jenkins,host,db}

cp_if() { if [ -e "$1" ]; then cp -a "$1" "$2"; else echo "missing: $1" >> "$S/MISSING.txt"; fi; }
run() { echo "\$ $*"; "$@" 2>&1; echo; }

# ---------- Report: versions, commits, state
{
  echo "eol-archive snapshot $STAMP (made by $OWNER on $(hostname -f 2>/dev/null || hostname))"
  echo
  run cat /etc/redhat-release
  run uname -r
  run docker version --format 'Docker {{.Server.Version}}'
  run docker compose version
  run getenforce
  echo "== Git commits (docker package and code repos)"
  for r in "$REPO" "$WEB/eol_php8_code" "$WEB/FreshData_min" "$WEB/LiteratureEditor_min"; do
    [ -d "$r/.git" ] || { echo "$r: not a git checkout"; continue; }
    echo "$r: $(sudo -u "$OWNER" git -C "$r" log --oneline -1 2>/dev/null) | changed files: $(sudo -u "$OWNER" git -C "$r" status --short 2>/dev/null | wc -l)"
  done
  echo
  echo "== Containers and images"
  (cd "$REPO" && run docker compose -f docker-compose.yml ps)
  run docker images --format '{{.Repository}}:{{.Tag}}  {{.ID}}  {{.Size}}'
  run docker network inspect -f '{{.Name}} {{range .IPAM.Config}}{{.Subnet}}{{end}}' docker_eol_connectors_default
  echo "== Versions inside the containers"
  run docker exec docker_eol_connectors-web-1 php -r 'echo PHP_VERSION,"\n";'
  run docker exec docker_eol_connectors-db-1 mysqld --version
  run docker exec docker_eol_connectors-jenkins-1 sh -c 'cat /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state 2>/dev/null; java -jar /usr/share/jenkins/jenkins.war --version 2>/dev/null'
  run docker exec docker_eol_connectors-jenkins-1 gnparser -V
  echo "== Ports listening on 443 / 8080"
  run ss -ltn
  echo "== Memory, disks"
  run free -h
  run df -h / /extra
} > "$S/REPORT.txt" 2>&1

# ---------- The stack: settings (secrets) and any local changes to the package
cp_if "$REPO/.env" "$S/stack/.env"
(cd "$REPO" && sudo -u "$OWNER" git diff) > "$S/stack/git_diff_docker_eol_connectors.patch" 2>/dev/null
cp_if "$EOL_BASE/certs" "$S/stack/certs"

# ---------- Code: the config files git doesn't keep, and the links git doesn't make
cp_if "$WEB/eol_php8_code/config/database.yml" "$S/code_config/database.yml"
cp_if "$WEB/eol_php8_code/config/environments/production.php" "$S/code_config/production.php"
for r in eol_php8_code FreshData_min LiteratureEditor_min; do
  (cd "$WEB/$r" 2>/dev/null && sudo -u "$OWNER" git status --short) > "$S/code_config/git_status_$r.txt" 2>&1
done
find "$WEB" -maxdepth 4 -type l -printf '%p -> %l\n' > "$S/code_config/symlinks.txt" 2>/dev/null

# ---------- Jenkins: jobs, settings, users, credentials, secrets (no build history, workspaces, plugins or caches)
tar -C "$JH" -cf "$S/jenkins/jenkins_home_config.tar" \
  --exclude='./jobs/*/builds' --exclude='./jobs/*/jobs/*/builds' --exclude='./jobs/*/jobs/*/jobs/*/builds' \
  --exclude='lastStable' --exclude='lastSuccessful' --exclude='./plugins' --exclude='./war' --exclude='./logs' \
  --exclude='./updates' --exclude='./workspace' --exclude='./.cache' --exclude='./.java' --exclude='./.local' \
  --exclude='./caches' --exclude='./fingerprints' . 2>> "$S/MISSING.txt"
# The installed plugins now (versions after the updates in Jenkins), in plugins.txt format
for m in "$JH"/plugins/*/META-INF/MANIFEST.MF; do
  awk -F': ' '/^Short-Name:/ { n = $2 } /^Plugin-Version:/ { v = $2 } END { gsub(/\r/, "", n); gsub(/\r/, "", v); print n ":" v }' "$m"
done | sort > "$S/jenkins/plugins_current.txt"

# ---------- Host settings
cp_if /etc/docker/daemon.json "$S/host/daemon.json"
head -5 /etc/containerd/config.toml > "$S/host/containerd_config_head.toml" 2>&1
mkdir -p "$S/host/systemd"
cp -a /etc/systemd/system/docker.service.d "$S/host/systemd/" 2>/dev/null
cp -a /etc/systemd/system/containerd.service.d "$S/host/systemd/" 2>/dev/null
semanage fcontext -l -C > "$S/host/selinux_fcontext_local.txt" 2>&1
cp_if /etc/cron.allow "$S/host/cron.allow"
crontab -l -u "$OWNER" > "$S/host/crontab_$OWNER.txt" 2>&1
{
  for d in /extra /extra/eol_docker /extra/eol_docker/* /extra/dumps /extra/eol_connector_data_files /extra/ckan_resources \
           /extra/other_files /extra/gnfinder /extra/eol_php_resources /extra/eol_php_resources/cache /extra/FreshData_TSV_files \
           /extra/eol_php_cache /extra/eol_php_cache2 "$WEB" "$WEB/eol_php8_code/temp"; do
    [ -e "$d" ] || continue
    ls -ldZ "$d"; getfacl -p "$d" 2>/dev/null | grep -E '^(user|group|mask|other|default):'; echo
  done
} > "$S/host/permissions_acl_selinux.txt" 2>&1
{ firewall-cmd --get-active-zones; firewall-cmd --list-all; } > "$S/host/firewalld.txt" 2>&1
ip -4 addr show > "$S/host/ip_addr.txt" 2>&1

# ---------- Database: the newest nightly dump
newest=$(ls -1t "$EOL_BASE"/backups/mysql_*.sql.gz 2>/dev/null | head -1)
if [ -n "$newest" ]; then cp -a "$newest" "$S/db/"; else echo "missing: MySQL dump in $EOL_BASE/backups" >> "$S/MISSING.txt"; fi

# ---------- Pack
tar -C "$TMP" -czf "$OUT_DIR/$NAME.tar.gz" "$NAME"
chown "$OWNER": "$OUT_DIR" "$OUT_DIR/$NAME.tar.gz"; chmod 600 "$OUT_DIR/$NAME.tar.gz"
echo "OK $OUT_DIR/$NAME.tar.gz ($(du -h "$OUT_DIR/$NAME.tar.gz" | cut -f1)) sha256 $(sha256sum "$OUT_DIR/$NAME.tar.gz" | cut -c1-16)"
[ -s "$S/MISSING.txt" ] && { echo "Not found (see MISSING.txt in the archive):"; sed 's/^/  /' "$S/MISSING.txt"; }
echo "Contains passwords, tokens and keys: keep it private. Copy it off the server, e.g. from the Mac:"
echo "  scp archive:$OUT_DIR/$NAME.tar.gz <a private folder>/"
