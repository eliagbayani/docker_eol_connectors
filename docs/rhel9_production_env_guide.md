# EOL Connectors — RHEL 9 production `.env` layout

**Project:** `docker_eol_connectors`  
**Updated:** 2026-08-07  
**Repo path:** `My_Docker/docker_eol_connectors/`  
**Template file:** `.env.production.sample`  
**Init script:** `scripts/rhel9-init-dirs.sh`

---

## Summary

The stack **will run on RHEL 9** if you:

1. Use **Linux paths** (not `/Volumes/...`)
2. Set **`MY_ENVIRONMENT=production`**
3. Use **`.env.production.sample`** as the basis for server `.env`
4. Populate **`/opt/eol/extra`** subdirs expected by `docker-entrypoint_production.sh`
5. Handle **SELinux** labels on bind mounts

`docker-compose.override.yml` is **gitignored** — it stays on your Mac for dev (`/Volumes` mount) and is **not included in git clone/deploy** to RHEL.

---

## Repo files for production (committed)

| File | Purpose |
|------|---------|
| `.env.production.sample` | RHEL 9 production `.env` template (`/opt/eol/...` paths) |
| `scripts/rhel9-init-dirs.sh` | Creates host directory tree under `/opt/eol` |
| `docker-compose.yml` | Main compose file (all four services) |
| `.gitignore` | Excludes `docker-compose.override.yml`, `.env`, Mac-only files |

**Not in repo (Mac dev only):** `docker-compose.override.yml`

---

## Recommended directory layout on RHEL 9

```text
/opt/eol/
├── mysql_data/              ← MYSQL_DATA_DIR (empty on first init)
├── webroot/                 ← WEBROOT_PATH → /var/www/html
│   └── eol_php8_code/       ← required for opendata symlink
├── apache2_logs/            ← APACHE_LOGS
├── jenkins_home/            ← JENKINS_HOME
├── jenkins_tmp/             ← JENKINS_TMP
├── python_projects/         ← PYTHON_APP → /usr/src/app
├── neo4j/
│   ├── data/
│   ├── logs/
│   ├── import/
│   ├── import2/
│   └── plugins/
└── extra/                   ← EXTRA_PATH → /extra
    ├── ckan_resources/              → symlink uploaded_resources
    ├── eol_connector_data_files/
    ├── dumps/
    ├── other_files/
    └── gnfinder/
```

Create all dirs:

```bash
sudo bash scripts/rhel9-init-dirs.sh
```

Custom base path: `sudo EOL_BASE=/srv/eol bash scripts/rhel9-init-dirs.sh`

---

## Production `.env` (key values)

| Variable | Production value | Notes |
|----------|------------------|-------|
| `MY_ENVIRONMENT` | `production` | Uses `docker-entrypoint_production.sh` |
| `EXTRA_PATH` | `/opt/eol/extra` | Mounted as `/extra`; symlinks at startup |
| `WEBROOT_PATH` | `/opt/eol/webroot` | PHP connector codebase |
| `MYSQL_DATA_DIR` | `/opt/eol/mysql_data` | **Empty** on first DB init |
| `MYSQL_USER` | `eol_app` | Created by MySQL image on first init |
| `MYSQL_PASSWORD` | *(set in .env)* | Official MySQL env var (fixed in compose) |
| `MYSQL_PORTS` | `127.0.0.1:4001:3306` | Bind MySQL to localhost only |
| `WEB_PORTS` | `80:80` | Or `8080:80` if 80 is taken |
| `JENKINS_PORTS` | `8080:8080` | Adjust if needed |
| DB name (auto) | `eol_production` | From `eol_${MY_ENVIRONMENT}` in compose |

Full template: **`.env.production.sample`**

```bash
cp .env.production.sample .env
# edit all CHANGE_ME_* passwords
```

---

## Compose changes (production-ready)

Recent updates in `docker-compose.yml`:

| Setting | Value | Notes |
|---------|-------|-------|
| `db` → `MYSQL_PASSWORD` | `${MYSQL_PASSWORD}` | Correct MySQL official env var |
| `web` → `platform` | `linux/amd64` | Explicit amd64 for RHEL x86_64 servers |
| `web` → `restart` | `unless-stopped` | Same as db, neo4j, jenkins |
| `db` / `jenkins` → `restart` | `unless-stopped` | Survives host reboot |

All services use **`restart: unless-stopped`**.

---

## Deploy steps on RHEL 9

```bash
# 1. Install Docker
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # re-login after

# 2. Clone repo (override file not included — gitignored)
git clone <repo-url> /opt/eol/docker_eol_connectors
cd /opt/eol/docker_eol_connectors

# 3. Host directories + SELinux
sudo bash scripts/rhel9-init-dirs.sh
sudo chown -R 1000:1000 /opt/eol/jenkins_home /opt/eol/jenkins_tmp
sudo chcon -Rt svirt_sandbox_file_t /opt/eol

# 4. Configure env
cp .env.production.sample .env
# edit passwords, ports, paths

# 5. Copy application code + datasets
# rsync webroot and extra/ content from archive or staging server

# 6. Build and start
docker compose -f docker-compose.yml build
docker compose -f docker-compose.yml up -d

# On non-amd64 build host, web already pins linux/amd64 in compose.
# For all services: docker compose build --platform linux/amd64

# 7. Firewall (adjust ports to match .env)
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=50000/tcp
sudo firewall-cmd --permanent --add-port=7474/tcp
sudo firewall-cmd --permanent --add-port=7687/tcp
sudo firewall-cmd --reload
```

### Verify

```bash
docker compose ps
curl -I http://localhost/test.php
docker compose exec db mysql -u root -p"${MYSQL_ROOT_PASSWORD}" eol_production \
  -e "SHOW TABLES;"
```

---

## test.php on production

Inside containers, MySQL host is **`db`**, port **`3306`** (not host-mapped 4001):

```php
$host = 'db';
$port = 3306;
$user = 'root';
$pass = '<MYSQL_ROOT_PASSWORD from .env>';
$db   = 'eol_production';
```

Browser: `http://<server>/test.php` (when `WEB_PORTS=80:80`)

---

## Optional: pull pre-built images from GHCR

Uncomment `image:` lines in `docker-compose.yml` and comment out `build:` blocks.
Set registry vars in `.env`:

```env
REGISTRY=ghcr.io
REGISTRY_WEB_IMAGE=eliagbayani/web-service
REGISTRY_WEB_TAG=latest
# ... db, jenkins similarly
```

Login first: `echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin`

---

## Known issues to watch

| Issue | Detail |
|-------|--------|
| Neo4j Enterprise | Valid license required; `NEO4J_ACCEPT_LICENSE_AGREEMENT=yes` in compose |
| First MySQL init | `MYSQL_DATA_DIR` must be empty; init SQL runs once only |
| SELinux | Use `chcon` or `:Z` on bind mounts if permission denied |
| Port 80 conflicts | Check with `sudo lsof -i :80`; may be another Docker stack |
| `JAVA_OPTS` spacing | Leading space in compose value — verify Jenkins starts cleanly |

**Resolved:** `MYSQL_USER_PW` → **`MYSQL_PASSWORD`** in compose and env samples.

---

## Mac dev vs RHEL prod

| | Mac dev | RHEL prod |
|--|---------|-----------|
| Override file | local only (`docker-compose.override.yml`, gitignored) | not in repo |
| `MY_ENVIRONMENT` | `development` | `production` |
| Symlinks | `/Volumes/AKiTiO4/...` (dev entrypoint) | `/extra/...` (prod entrypoint) |
| Base path | `/Volumes/OWC_Express/...` | `/opt/eol/...` |
| Env template | `.env.sample` | `.env.production.sample` |
| Compose (Mac) | `docker compose up -d` (merges override if present) | n/a |
| Compose (RHEL) | n/a | `docker compose -f docker-compose.yml up -d` |
| Web platform | may build arm64 on Apple Silicon | `platform: linux/amd64` in compose |

---

## Quick reference commands

```bash
# Rebuild web only, no cache
docker compose -f docker-compose.yml build --no-cache web
docker compose -f docker-compose.yml up -d --force-recreate web

# Re-init MySQL (destroys data — backup first)
docker compose -f docker-compose.yml down
sudo rm -rf /opt/eol/mysql_data/*
docker compose -f docker-compose.yml build --no-cache db
docker compose -f docker-compose.yml up -d db
```

See also: `desktop/devops/docker_compose_up_info.md`
