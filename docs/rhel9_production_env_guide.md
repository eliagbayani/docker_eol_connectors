# EOL Connectors — RHEL 9 production `.env` layout

**Project:** `docker_eol_connectors`  
**Updated:** 2026-08-11  
**Repo path:** `My_Docker/docker_eol_connectors/`  
**Template file:** `.env.production.sample`  
**Init script:** `scripts/rhel9-init-dirs.sh`

---

## Summary

The stack **will run on RHEL 9** if you:

1. Use **Linux paths** (e.g. `/opt/eol/...` or `/srv/eol/...`)
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
| `neo4j/Dockerfile` | `FROM neo4j:5.26.29-community-ubi10` |
| `.gitignore` | Excludes `docker-compose.override.yml`, `.env`, Mac-only files |

**Not in repo (Mac dev only):** `docker-compose.override.yml`

---

## Neo4j — Community Edition (was Enterprise)

| | Previous | Current |
|--|----------|---------|
| Image | `neo4j:5.26.12-enterprise-ubi9` | **`neo4j:5.26.29-community-ubi10`** |
| Edition | Enterprise (license required) | **Community** (no license) |
| Base OS | UBI9 | **UBI10** (runs on RHEL 9 hosts in Docker) |
| User database | Named DBs (e.g. `db.eol`) | **Single DB: `neo4j`** |
| `NEO4J_ACCEPT_LICENSE_AGREEMENT` | Required | **Not used** (commented out in compose) |

### Community limitations (important)

| Enterprise command / feature | Community on RHEL |
|------------------------------|-------------------|
| `STOP DATABASE` / `START DATABASE` | **Not supported** — stop container instead |
| `CREATE DATABASE` | **Not supported** |
| Multiple user databases (`db.eol`, etc.) | **Not supported** — use **`neo4j`** only |
| `neo4j-admin database import full` | **Supported** — stop Neo4j container first |

### Production `.env` Neo4j settings

```env
NEO_URI=bolt://neo4j:7687
NEO_USERNAME=neo4j
NEO_PASSWORD=CHANGE_ME_neo4j_password
NEO_DATABASE=neo4j          # was db.eol on Enterprise — must be neo4j on Community

PATH_NEO4J_DATA=/opt/eol/neo4j/data
PATH_NEO4J_LOGS=/opt/eol/neo4j/logs
PATH_NEO4J_IMPORT=/opt/eol/neo4j/import
PATH_NEO4J_IMPORT2=/opt/eol/neo4j/import2   # TraitBank CSV imports
PATH_NEO4J_PLUGINS=/opt/eol/neo4j/plugins

PORT_7474=7474:7474
PORT_7687=7687:7687
```

APOC remains enabled in compose: `NEO4J_PLUGINS=["apoc"]`.

### Migrating from Enterprise data on RHEL

1. **Back up** `/opt/eol/neo4j/data` before any change.
2. Set **`NEO_DATABASE=neo4j`** in `.env` (Jenkins/Python connectors too).
3. Enterprise **block-format dumps** may not load into Community — prefer **CSV re-import** via `neo4j-admin database import full`.
4. Do **not** use `STOP DATABASE` in Browser — use `docker compose stop neo4j`.

### TraitBank CSV import on RHEL (Community)

```bash
cd /opt/eol/docker_eol_connectors

# Stop Neo4j completely (replaces Enterprise STOP DATABASE)
docker compose -f docker-compose.yml stop neo4j

docker compose -f docker-compose.yml run --rm --entrypoint neo4j-admin neo4j \
  database import full neo4j \
  --overwrite-destination=true \
  --nodes=import2/AnimalDiversityWeb_TraitBank_1_0_csv/nodes/Resource.csv \
  ... # remaining --nodes, --relationships, --schema flags

docker compose -f docker-compose.yml up -d neo4j
```

CSV path: host `/opt/eol/neo4j/import2` → container `/var/lib/neo4j/import2`.

### Verify Neo4j after deploy

```bash
docker compose -f docker-compose.yml logs neo4j
curl -I http://localhost:7474
```

Browser: `http://<server>:7474/browser/` — connect to database **`neo4j`**.

```cypher
SHOW DATABASES;
MATCH (n) RETURN count(n) AS nodes;
```

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
│   ├── data/                ← PATH_NEO4J_DATA (persisted graph store)
│   ├── logs/
│   ├── import/
│   ├── import2/             ← TraitBank CSV trees for neo4j-admin import
│   └── plugins/
└── extra/                   ← EXTRA_PATH → /extra
    ├── ckan_resources/
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
| `MYSQL_PASSWORD` | *(set in .env)* | Official MySQL env var |
| `MYSQL_PORTS` | `127.0.0.1:4001:3306` | Bind MySQL to localhost only |
| `WEB_PORTS` | `80:80` | Or `8080:80` if 80 is taken |
| `JENKINS_PORTS` | `8080:8080` | Adjust if needed |
| `NEO_DATABASE` | **`neo4j`** | Community single database (not `db.eol`) |
| MySQL DB name (auto) | `eol_production` | From `eol_${MY_ENVIRONMENT}` in compose |

Full template: **`.env.production.sample`**

```bash
cp .env.production.sample .env
# edit all CHANGE_ME_* passwords; set NEO_DATABASE=neo4j
```

---

## Compose notes (production-ready)

| Setting | Value | Notes |
|---------|-------|-------|
| `db` → `MYSQL_PASSWORD` | `${MYSQL_PASSWORD}` | Official MySQL env var |
| `web` → `platform` | `linux/amd64` | Explicit amd64 for RHEL x86_64 |
| `neo4j` image | `5.26.29-community-ubi10` | Via `neo4j/Dockerfile` |
| `NEO4J_ACCEPT_LICENSE_AGREEMENT` | commented out | Enterprise only — not needed |
| All services → `restart` | `unless-stopped` | Survives host reboot |

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
# edit passwords, ports; set NEO_DATABASE=neo4j

# 5. Copy application code + datasets
# rsync webroot, extra/, and neo4j/import2 CSV trees

# 6. Build and start
docker compose -f docker-compose.yml build
docker compose -f docker-compose.yml up -d

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
docker compose -f docker-compose.yml ps
curl -I http://localhost/test.php
docker compose exec db mysql -u root -p"${MYSQL_ROOT_PASSWORD}" eol_production \
  -e "SHOW TABLES;"
# Neo4j — open http://<server>:7474/browser/ ; database neo4j
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
| `UnsupportedAdministrationCommand: STOP DATABASE` | Enterprise-only — use `docker compose stop neo4j` |
| `db.eol` not found | Community uses **`neo4j`** — update `NEO_DATABASE` and app configs |
| Neo4j import "database in use" | Stop container before `neo4j-admin database import full` |
| Enterprise dump → Community | Block dumps may fail — re-import CSV instead |
| First MySQL init | `MYSQL_DATA_DIR` must be empty; init SQL runs once only |
| SELinux | Use `chcon` or `:Z` on bind mounts if permission denied |
| Port 80 conflicts | Check with `sudo lsof -i :80` |
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
| Neo4j edition | Community 5.26.29 UBI10 | same |
| `NEO_DATABASE` | **`neo4j`** | **`neo4j`** |
| Compose (Mac) | `docker compose up -d` | n/a |
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

# Reset Neo4j graph store (destroys data — backup first)
docker compose -f docker-compose.yml stop neo4j
sudo rm -rf /opt/eol/neo4j/data/*
docker compose -f docker-compose.yml up -d neo4j
```

See also: repo **`README.md`** (Neo4j Community section) · **`desktop/devops/docker_compose_up_info.md`**
