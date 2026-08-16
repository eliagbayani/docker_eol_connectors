# `docker_eol_connectors` — EOL legacy web-based tools (Docker Compose)

**Path (local):** `My_Docker/docker_eol_connectors/`  
**Updated:** 2026-08-16  
**Info:** This is to run on a Docker host environment.

---

A Docker Compose project that runs eol-archive server stack on a single host. This will be
installed on a server with RHEL 9. Main purpose is to host the legacy EOL web-based
tools.

| Service | Image / build | Role |
|---------|---------------|------|
| **web** | `apache-php/Dockerfile` | Apache 2.4 + PHP 8.2 — host web-based tools |
| **db** | `mysql/Dockerfile` | MySQL 8.4.3 (Oracle Linux 9 base) |
| **jenkins** | `jenkins/Dockerfile` | Jenkins 2.538 — maintains jobs for the web-based tools |

**Mac development only:** Neo4j (`neo4j/Dockerfile`) is defined in **`docker-compose.override.yml`**, not in production `docker-compose.yml`. See [Neo4j (Mac dev only)](#neo4j-mac-dev-only).

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
├── docker-compose.yml                    ← production stack (web, db, jenkins)
├── docker-compose.override.sample.yml  ← Mac dev template (copy → override.yml)
├── docker-compose.override.yml         ← Mac dev only (gitignored, not deployed)
├── .env.sample                         ← Mac / local dev template
├── .env.production.sample              ← RHEL 9 production template
├── .gitignore
├── docs/
│   └── rhel9_production_env_guide.md
├── scripts/
│   └── rhel9-init-dirs.sh              ← create /opt/eol host dirs on RHEL
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
│   └── Dockerfile                         ← Mac dev only (via override file)
└── jenkins/
    ├── Dockerfile
    └── executors.groovy
```

**WEBROOT_PATH** (host) is mounted at `/var/www/html` and should contain `eol_php8_code/` and related connector code — not baked into these Dockerfiles (unlike `dock_eol_conn_wf`).

---

## Service specification

| Item | web | db | jenkins |
|------|-----|-----|---------|
| Base | `php:8.2-apache` | `mysql:8.4.3-oraclelinux9` | `jenkins/jenkins:2.538-jdk21` |
| PHP | 8.2, mysqli, yaml | — | 8.2 (apt) |
| Python | — | embedded 3.9 | 3.11 |
| gnparser | v1.15.0 (TARGETARCH) | — | v1.15.0 |
| Default host port | 81→80 (dev) / 80→80 (prod) | 4001→3306 | 8081→8080 |
| Restart | unless-stopped | unless-stopped | unless-stopped |
| Platform (web) | `linux/amd64` in compose | — | — |

Database name on first init: **`eol_${MY_ENVIRONMENT}`** (e.g. `eol_development`, `eol_production`).

---

## Quick start — Mac development

```bash
cd My_Docker/docker_eol_connectors

cp .env.sample .env
cp docker-compose.override.sample.yml docker-compose.override.yml
# Edit paths in .env (WEBROOT_PATH, MYSQL_DATA_DIR, PATH_NEO4J_*, etc.)

# Ensure MYSQL_DATA_DIR is empty on first run

docker compose up -d
# Merges docker-compose.override.yml: /Volumes mount + neo4j service
```

**Test URLs** (match ports in your `.env`; example Mac dev values):

| Check | URL |
|-------|-----|
| PHP + MySQL | http://localhost:81/test.php |
| Jenkins | http://localhost:8081 |
| Neo4j Browser | http://localhost:7494/browser/ |
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

**Do not deploy:** `docker-compose.override.yml` — it is **gitignored** (Mac `/Volumes` mount + Neo4j). Production uses only `docker-compose.yml` (web, db, jenkins).

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
| `EXTRA_PATH` | Host path → `/extra` (prod symlinks; mounted on web + jenkins) |
| `MYSQL_DATA_DIR` | MySQL data volume (empty on first init) |
| `MYSQL_PASSWORD` | App DB user password (official MySQL env var) |
| `PATH_JENKINS_HOME` | Host Jenkins data → `/var/jenkins_home` (do **not** name `JENKINS_HOME` in `.env` — reserved in container) |
| `PATH_JENKINS_TMP` | Host temp dir → `/jenkins_tmp` |
| `GNPARSER_VERSION` | gnparser release (default 1.15.0) |
| `PYTHON_APP` | Host path → `/usr/src/app` (Jenkins Python jobs) |
| `NEO_*`, `PATH_NEO4J_*`, `PORT_7474`, `PORT_7687` | **Mac dev only** — Neo4j vars in `.env.sample`; not used on RHEL production |
| `REGISTRY_*` | GHCR image names when using pre-built images (optional) |

---

## Entrypoint behaviour

`MY_ENVIRONMENT` selects the web container startup script. Both scripts:

- Copy `test.php` / `info.php` into **`${PWD}`** (`/var/www/html`) — not `${TARGET_PATH}` (host path is not visible inside the container)
- Use shared **`ensure_symlink`** helper: `ln -sfn` into `${PWD}`; skip if link/path already exists

| Value | Script | Symlink targets |
|-------|--------|-----------------|
| `development` | `docker-entrypoint_development.sh` | `/Volumes/...` (requires override mount of `/Volumes`) |
| `production` | `docker-entrypoint_production.sh` | `/extra/...` (from `EXTRA_PATH`) |

### Development symlinks (`docker-entrypoint_development.sh`)

Requires `docker-compose.override.yml` mounting **`/Volumes:/Volumes`**.

| Link name in webroot | Target |
|----------------------|--------|
| `opendata` | `/var/www/html/eol_php8_code/applications/opendata` |
| `eoearth_images` | `/Volumes/AKiTiO4/web/eoearth_images` |
| `eoearth` | `/Volumes/AKiTiO4/webroot/eoearth` |
| `maps_test` | `/Volumes/AKiTiO4/webroot/maps_test` |
| `eol_maps` | `/Volumes/AKiTiO4/webroot/eol_maps` |
| `opendata_uploads` | `/Volumes/AKiTiO4/other_files/opendata_uploads` |
| `other_files` | `/Volumes/AKiTiO4/other_files` |
| `d_w_h` | `/Volumes/AKiTiO4/d_w_h/dynamic_working_hierarchy-master` |
| `cp` | `/Volumes/AKiTiO4/web/cp` |
| `cp_new` | `/Volumes/AKiTiO4/web/cp_new` |
| `effechecka` | `/Volumes/AKiTiO4/webroot/effechecka` |
| `Leaflet_Cluster_map` | `/Volumes/AKiTiO4/webroot/Leaflet_Cluster_map` |
| `ckan_api_results` | `/Volumes/AKiTiO4/CKAN_info/api_results` |
| `wikimedia_cache` | `/Volumes/AKiTiO4/wikimedia_cache` |
| `other_files2` | `/Volumes/Crucial_2TB/other_files2` |
| `cache_LiteratureEditor` | `/Volumes/Crucial_2TB/cache_LiteratureEditor` |
| `Pensoft_annotator` | `/Volumes/Crucial_4TB/Pensoft_annotator` |
| `gnfinder` | `/Volumes/Crucial_4TB/gnfinder` |

On startup, removes accidental nested symlink `eol_php8_code/applications/opendata/opendata` if present (legacy `ln` behaviour).

### Production symlinks (`docker-entrypoint_production.sh`)

| Link name in webroot | Target (`/extra/...`) |
|----------------------|-------------------------|
| `uploaded_resources` | `ckan_resources` |
| `eol_connector_data_files` | `eol_connector_data_files` |
| `dumps` | `dumps` |
| `other_files` | `other_files` |
| `gnfinder` | `gnfinder` |

Then runs `apache2-foreground`.

---

## Neo4j (Mac dev only)

Neo4j is **not** part of the RHEL production stack. It lives only in **`docker-compose.override.yml`**, which Docker Compose merges automatically on Mac but which must **not** exist on production servers.

| | Mac dev | RHEL prod |
|--|---------|-----------|
| Neo4j in compose | `docker-compose.override.yml` | **not defined** |
| Start command | `docker compose up -d` | `docker compose -f docker-compose.yml up -d` |
| Env vars | `NEO_*`, `PATH_NEO4J_*` in `.env` (from `.env.sample`) | omit Neo4j vars (use `.env.production.sample`) |
| Browser | `http://localhost:7494/browser/` (when `PORT_7474=7494:7474`) | — |

**First-time Mac setup:**

```bash
cp docker-compose.override.sample.yml docker-compose.override.yml
```

The override adds:

1. **`/Volumes:/Volumes`** mount on web + jenkins (dev symlinks)
2. **`neo4j`** service — builds from `neo4j/Dockerfile` (`neo4j:5.26.29-community-ubi10`)

Jenkins receives `NEO_URI=bolt://neo4j:7687` from `.env` so Python jobs can reach the graph DB on Mac. On production, Jenkins still starts but Neo4j-dependent jobs should not run (no `neo4j` container on the network).

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

---

## Mac dev vs RHEL prod

| | Mac dev | RHEL prod |
|--|---------|-----------|
| Env template | `.env.sample` | `.env.production.sample` |
| `MY_ENVIRONMENT` | `development` | `production` |
| Override file | `docker-compose.override.yml` (from `.sample`) | **must not exist** |
| Services | web, db, jenkins, **neo4j** | web, db, jenkins only |
| Base paths | `/Volumes/OWC_Express/...` | `/opt/eol/...` |
| Compose | `docker compose up -d` | `docker compose -f docker-compose.yml up -d` |
| Extra data | `/Volumes` mount + dev symlinks | `/opt/eol/extra` → `/extra` |

---

## Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| MySQL `Connection refused` from test.php | Using port 4001 inside container — use **3306** and host **`db`** |
| Empty `employees_tbl` | Init SQL ran once; wrong INSERT column order; re-init empty `MYSQL_DATA_DIR` |
| Port 80 in use | Often Docker (`com.docke`) — `docker ps --filter "publish=80"` |
| Permission denied on RHEL | SELinux — `chcon -Rt svirt_sandbox_file_t /opt/eol` |
| Override on production | Should not exist — gitignored; use `-f docker-compose.yml` only |
| Neo4j missing on Mac | Copy `docker-compose.override.sample.yml` → `docker-compose.override.yml` |
| Neo4j mount error on Mac | External drive not in Docker File Sharing (`/Volumes/Crucial_2TB`, etc.) |
| Nested `opendata/opendata` symlink | Dev entrypoint removes it; recreate web container if links look wrong |
| Jenkins empty after `.env` change | Use **`PATH_JENKINS_HOME`** / **`PATH_JENKINS_TMP`** for host paths — not `JENKINS_HOME` in `.env` |

---

## Notes

- **Web entrypoints** use `${PWD}` (`/var/www/html`) and **`ensure_symlink`** (`ln -sfn`) — see tables above.
- **Jenkins:** compose sets in-container `JENKINS_HOME=/var/jenkins_home`; host bind path is **`PATH_JENKINS_HOME`** in `.env`.
- **First MySQL init** runs SQL in `mysql/test_MySQL_db.sql` only when `MYSQL_DATA_DIR` is empty.
- **`docker-compose.override.yml`** is gitignored — on Mac, copy from **`docker-compose.override.sample.yml`** (adds `/Volumes` mount + Neo4j).
- **Neo4j** runs on Mac dev only; production `docker-compose.yml` has no Neo4j service.
- For Kubernetes production workloads, use **`dock_eol_conn_wf`** + **`eol-apps-connectors`** [GitHub](https://github.com/EOL/eol-apps-connectors/tree/main/connectors) instead of this full compose stack.
