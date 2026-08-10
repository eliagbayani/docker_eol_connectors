# `docker_eol_connectors` — EOL Connectors stack (Docker Compose)

**Path:** `My_Docker/docker_eol_connectors/`  
**Updated:** 2026-08-08  
**Info:** This is to run on a Docker host environment.

---

## What this is

Docker Compose project that runs an **EOL Connectors local/archive stack** on a single host:

| Service | Image / build | Role |
|---------|---------------|------|
| **web** | `apache-php/Dockerfile` | Apache 2.4 + PHP 8.2 — connector web apps |
| **db** | `mysql/Dockerfile` | MySQL 8.4.3 (Oracle Linux 9 base) |
| **jenkins** | `jenkins/Dockerfile` | Jenkins 2.538 |
| **neo4j** | `neo4j/Dockerfile` | Neo4j 5.26.12 Enterprise (UBI9) + APOC <br> Optional. For TraitBank 1.0 testing|

<!-- | **jenkins** | `jenkins/Dockerfile` | Jenkins 2.538 + PHP 8.2 + Python 3 + gnparser | -->

| Runtime | Purpose |
|---------|---------|
| **Mac (development)** | Local dev with `/Volumes` symlinks and override file |
| **RHEL 9 (production)** | Archive/server deployment under `/opt/eol/...` |

This repo is **separate from** `dock_eol_conn_wf` [GitHub](https://github.com/eliagbayani/dock_eol_conn_wf), which builds only the slim **web** image for Kubernetes (`ghcr.io/eliagbayani/web_k8s-service`).

---

## Directory layout

```text
docker_eol_connectors/
├── docker-compose.yml              ← main stack (all environments)
├── docker-compose.override.yml     ← Mac dev only (gitignored, not deployed)
├── .env.sample                     ← Mac / local dev template
├── .env.production.sample          ← RHEL 9 production template
├── .gitignore
├── docs/
│   └── rhel9_production_env_guide.md
├── scripts/
│   └── rhel9-init-dirs.sh          ← create /opt/eol host dirs on RHEL
├── apache-php/
│   ├── Dockerfile
│   ├── apache2.conf
│   ├── 000-default.conf
│   ├── php.ini.txt
│   ├── docker-entrypoint_development.sh   ← Mac /Volumes symlinks
│   ├── docker-entrypoint_production.sh    ← /extra symlinks
│   └── src/                               ← test.php, info.php, list.php
├── mysql/
│   ├── Dockerfile
│   ├── my.cnf
│   ├── enable-mysql-native-password.cnf
│   └── test_MySQL_db.sql                  ← init seed (employees_tbl)
├── neo4j/
│   └── Dockerfile                         ← FROM neo4j:5.26.12-enterprise-ubi9
└── jenkins/
    ├── Dockerfile
    └── executors.groovy
```

**WEBROOT_PATH** (host) is mounted at `/var/www/html` and should contain `eol_php8_code/` and related connector code — not baked into these Dockerfiles (unlike `dock_eol_conn_wf`).

---

## Service specification

| Item | web | db | neo4j | jenkins |
|------|-----|----|----|---------|
| Base | `php:8.2-apache` | `mysql:8.4.3-oraclelinux9` | `neo4j:5.26.12-enterprise-ubi9` | `jenkins/jenkins:2.538-jdk21` |
| PHP | 8.2, mysqli, yaml | — | — | 8.2 (apt) |
| Python | — | embedded 3.9 | embedded 3.9 | 3.11 + neo4j driver |
| gnparser | v1.15.0 (TARGETARCH) | — | — | v1.15.0 |
| Default host port | 81→80 (dev) / 80→80 (prod) | 4001→3306 | 7474, 7687 | 8081→8080 |
| Restart | unless-stopped | unless-stopped | — | unless-stopped |
| Platform (web) | `linux/amd64` in compose | — | — | — |

Database name on first init: **`eol_${MY_ENVIRONMENT}`** (e.g. `eol_development`, `eol_production`).

---

## Quick start — Mac development

```bash
cd My_Docker/docker_eol_connectors

cp .env.sample .env
# Edit paths (WEBROOT_PATH, MYSQL_DATA_DIR, etc.) — use /Volumes/... paths

# Ensure MYSQL_DATA_DIR is empty on first run

docker compose up -d
# Merges docker-compose.override.yml automatically (mounts /Volumes)
```

**Test URLs (default .env.sample ports):**

| Check | URL |
|-------|-----|
| PHP + MySQL | http://localhost:81/test.php |
| Jenkins | http://localhost:8081 |
| Neo4j Browser | http://localhost:7474/browser/ |
| MySQL from host | `localhost:4001` (user: root) |

**test.php MySQL settings (inside container):**

```php
$host = 'db';
$port = 3306;              // not 4001 — that's the host-mapped port
$db   = 'eol_development'; // matches MY_ENVIRONMENT
```

---

## Quick start — RHEL 9 production

```bash
git clone <repo> /opt/eol/docker_eol_connectors
cd /opt/eol/docker_eol_connectors

sudo bash scripts/rhel9-init-dirs.sh
cp .env.production.sample .env
# Edit CHANGE_ME_* passwords and paths

sudo chown -R 1000:1000 /opt/eol/jenkins_home /opt/eol/jenkins_tmp
sudo chcon -Rt svirt_sandbox_file_t /opt/eol   # if SELinux enforcing

# Populate /opt/eol/webroot and /opt/eol/extra before or after first up

docker compose -f docker-compose.yml build
docker compose -f docker-compose.yml up -d
```

**Do not deploy:** `docker-compose.override.yml` — it is **gitignored** (Mac `/Volumes` mount only).

Full guide: **`docs/rhel9_production_env_guide.md`**.

---

## Environment files

| File | Use |
|------|-----|
| `.env.sample` | Mac / local dev — copy to `.env` |
| `.env.production.sample` | RHEL 9 — copy to `.env` on server |
| `.env` | Active config (gitignored) |

Key variables:

| Variable | Purpose |
|----------|---------|
| `MY_ENVIRONMENT` | `development` or `production` — selects entrypoint script |
| `WEBROOT_PATH` | Host path → `/var/www/html` |
| `EXTRA_PATH` | Host path → `/extra` (prod symlinks) |
| `MYSQL_DATA_DIR` | MySQL data volume (empty on first init) |
| `MYSQL_PASSWORD` | App DB user password (official MySQL env var) |
| `GNPARSER_VERSION` | gnparser release (default 1.15.0) |
| `REGISTRY_*` | GHCR image names when using pre-built images |

---

## Entrypoint behaviour

`MY_ENVIRONMENT` selects the web container startup script:

| Value | Script | Symlink source |
|-------|--------|----------------|
| `development` | `docker-entrypoint_development.sh` | `/Volumes/AKiTiO4/...`, external drives |
| `production` | `docker-entrypoint_production.sh` | `/extra/...` (from `EXTRA_PATH`) |

Both copy `test.php` / `info.php` into the webroot if missing, then run `apache2-foreground`.

---

## Common commands

```bash
# Single service, no cache rebuild
docker compose build --no-cache web && docker compose up -d --force-recreate web

# Production (explicit — no override)
docker compose -f docker-compose.yml up -d

# Stop / remove
docker compose down

# Logs
docker compose logs -f web

# Shell into container
docker compose exec web bash

# Prune dangling <none> images
docker image prune -f
```

See also: **`desktop/devops/docker_compose_up_info.md`**

---

## Push images to GHCR (optional)

Uncomment `image:` lines in `docker-compose.yml` and comment out `build:` blocks.

```bash
export GHCR_TOKEN=...
export GITHUB_ACTOR=eliagbayani
echo "$GHCR_TOKEN" | docker login ghcr.io -u "$GITHUB_ACTOR" --password-stdin

docker compose build --platform linux/amd64
docker compose push
```

Registry vars in `.env`:

```env
REGISTRY=ghcr.io
REGISTRY_WEB_IMAGE=eliagbayani/web-service
REGISTRY_DB_IMAGE=eliagbayani/db-service
REGISTRY_JENKINS_IMAGE=eliagbayani/jenkins-service
REGISTRY_*_TAG=latest
```

---

## Mac dev vs RHEL prod

| | Mac dev | RHEL prod |
|--|---------|-----------|
| Env template | `.env.sample` | `.env.production.sample` |
| `MY_ENVIRONMENT` | `development` | `production` |
| Override file | local `docker-compose.override.yml` | not in repo |
| Base paths | `/Volumes/OWC_Express/...` | `/opt/eol/...` |
| Compose | `docker compose up -d` | `docker compose -f docker-compose.yml up -d` |
| Extra data | `/Volumes` mount + dev symlinks | `/opt/eol/extra` → `/extra` |

---

## Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| MySQL `Connection refused` from test.php | Using port 4001 inside container — use **3306** and host **`db`** |
| Empty `employees_tbl` | Init SQL ran once; wrong INSERT column order; re-init empty `MYSQL_DATA_DIR` |
| Neo4j mount error on Mac | External drive not in Docker File Sharing (`/Volumes/Crucial_2TB`, etc.) |
| Port 80 in use | Often Docker (`com.docke`) — `docker ps --filter "publish=80"` |
| Permission denied on RHEL | SELinux — `chcon -Rt svirt_sandbox_file_t /opt/eol` |
| Override on production | Should not exist — file is gitignored; use `-f docker-compose.yml` |

---

## Notes

- **Neo4j Enterprise** requires a valid license; compose sets `NEO4J_ACCEPT_LICENSE_AGREEMENT=yes`.
- **First MySQL init** runs SQL in `mysql/test_MySQL_db.sql` only when `MYSQL_DATA_DIR` is empty.
- **`docker-compose.override.yml`** is gitignored — create locally on Mac for `/Volumes` dev mount.
- For Kubernetes production workloads, use **`dock_eol_conn_wf`** + **`eol-apps-connectors`** instead of this full compose stack.
