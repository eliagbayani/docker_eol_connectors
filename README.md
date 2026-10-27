# EOL legacy web-based tools (Docker Compose)

**Path (local):** `My_Docker/docker_eol_connectors/`  
**Updated:** 2026-10-26  
**Info:** This is to run on a Docker host environment.

---

A Docker Compose project that runs eol-archive server stack on a single host. This will be
installed on a server with RHEL 9. Main purpose is to host the legacy EOL web-based
tools.

| Service | Image / build | Role |
|---------|---------------|------|
| **web** | `apache-php/Dockerfile` | Apache 2.4 + PHP 8.4.27 — host web-based tools |
| **db** | `mysql/Dockerfile` | MySQL 8.4.3 (Oracle Linux 9 base) |
| **jenkins** | `jenkins/Dockerfile` | Jenkins 2.580.1 LTS + PHP 8.4.27 — maintains jobs for the web-based tools |

**Mac development only:** Neo4j (`neo4j/Dockerfile`) is defined in **`docker-compose.override.yml`**, not in production `docker-compose.yml`. See [Neo4j (Mac dev only)](#neo4j-mac-dev-only).

<!-- | **jenkins** | `jenkins/Dockerfile` | Jenkins 2.580.1 + PHP 8.4 + Python 3 + gnparser | -->

| Runtime | Purpose |
|---------|---------|
| **Mac (development)** | Local dev with `/Volumes` symlinks and override file |
| **RHEL 9 (production)** | Archive/server deployment under `/opt/eol/...` |

This repo is **separate from** `dock_eol_conn_wf` [GitHub](https://github.com/eliagbayani/dock_eol_conn_wf), which builds only the slim **web** image for Kubernetes (`ghcr.io/eliagbayani/web_k8s-service`).

---

## Recent updates (Oct 2026)

| Area | Change |
|------|--------|
| **PHP** | 8.2 → **8.4.27** in both **web** (`php:8.4.27-apache`) and **jenkins** (`php8.4-*` from packages.sury.org). 8.4.27 fixes **PHP2Shell** (CVE-2026-109618 / CVE-2026-109619, Oct 2026). PHP 8.2 security support ends 2026-12-31. |
| **PHP version guard** | `jenkins/Dockerfile` fails the build if apt installs PHP older than `PHP_MIN_VERSION` (8.4.27). See [PHP version pins](#php-version-pins). |
| **Jenkins** | 2.538 (weekly) → **2.580.1 LTS** — picks up 2026 security advisories (incl. CVE-2026-70426). See [Upgrading Jenkins](#upgrading-jenkins). |
| **php.ini** | `session.sid_length` / `session.sid_bits_per_character` commented out (deprecated in 8.4; PHP defaults 32 / 4 apply). |
| **`.env.production.sample`** | Jenkins (8080) and Neo4j (7474, 7687) ports bound to **127.0.0.1**; `chmod 600 .env`; password generation hint; persistent SELinux labels via `semanage`. See [Security notes](#security-notes). |
| **`eol_php8_code`** (webroot, separate repo) | PHP 8.4 deprecations fixed. See [PHP 8.4 migration notes](#php-84-migration-notes). |
| **MySQL image** | Root password no longer baked into the image: `root-native-password.sh` sets it at first init from the runtime env. `!includedir` fix so the first init on an empty data dir completes. |
| **Apache hardening** | No directory listings; dotfiles/`.git` → 404; `eol_php8_code` config, vendor, lib, logs and loose files (`*.yml`, `*.sql`, …) → 403; PHP never runs from job-written / data dirs (`temp`, `tmp`, `content_server/resources`, `/extra` links). `ServerTokens Prod`. See [Security notes](#security-notes). |
| **Production PHP settings** | `zz-production.ini` (production builds only): errors logged, not displayed; `expose_php=Off`; strict, `HttpOnly`, `SameSite=Lax` session cookies. `ini_set('display_errors', true)` still works per page. |
| **Ports** | Every non-public port on `127.0.0.1`, Mac included (web `127.0.0.1:81`). Jenkins agent port 50000 not published. Prod web bound to the internal IP — see [Public access](#public-access-editorseolorg). |
| **Container-to-container** | Code reaches MySQL at `db:3306` (`database.yml`) and Jenkins at `jenkins:8080` (`JENKINS_DOMAIN`), with a build-only Jenkins user (`web-trigger`). |
| **Matching the old editors.eol.org server** | From eol-archive's saved config: `/eol_php_code/...` URLs served from `eol_php8_code` (`Alias` in `apache2.conf`); `max_execution_time`/`max_input_time` 900 and `max_input_vars` 100000 in `php.ini.txt`; PHP `zip`, `gd`, `xsl` added to web and `gd` to jenkins. Prod web port is **8080** on the internal IP (what .42 forwards to). Through Cloudflare a web request still stops at 100 s, so long work belongs in Jenkins jobs. Left out on purpose: mod_security rule exceptions (no mod_security in the container), the stock 443 certificate, the dead `opendata`/ckan vhosts, the 500 MB `LimitRequestBody` (Cloudflare caps uploads at 200 MB) and the `/eoearth_images` alias. |
| **Env templates** | `.env.sample` renamed to **`.env.development.sample`** (pairs with `.env.production.sample`). An existing `.env` is unaffected. |
| **Existing installs** | A db image built before the MySQL image change still contains an old root password (`/docker-entrypoint-initdb.d/eli.sql`). Rebuild it and remove the old image — see [Changing the MySQL root password](#changing-the-mysql-root-password). `apache2.conf`, `php.ini.txt` and the PHP modules are built into the images, so pull the repo and rebuild **web** and **jenkins** too: `docker compose build --no-cache --pull web jenkins && docker compose up -d` (add `-f docker-compose.yml` on RHEL). |

---

## Directory layout

```text
docker_eol_connectors/
├── docker-compose.yml                    ← production stack (web, db, jenkins)
├── docker-compose.override.sample.yml  ← Mac dev template (copy → override.yml)
├── docker-compose.override.yml         ← Mac dev only (gitignored, not deployed)
├── .env.development.sample             ← Mac / local dev template
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
│   ├── zz-production.ini                  ← production-only PHP settings
│   ├── zz-security.conf                   ← ServerTokens Prod, ServerSignature Off
│   ├── docker-entrypoint_development.sh   ← Mac /Volumes symlinks
│   ├── docker-entrypoint_production.sh    ← /extra symlinks
│   └── src/                               ← test.php, info.php, list.php
├── mysql/
│   ├── Dockerfile
│   ├── my.cnf
│   ├── enable-mysql-native-password.cnf
│   ├── root-native-password.sh            ← first-init: root auth plugin, password from env
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
| Base | `php:8.4.27-apache` | `mysql:8.4.3-oraclelinux9` | `jenkins/jenkins:2.580.1-jdk21` |
| PHP | 8.4.27, mysqli, yaml (pecl yaml-2.2.4) | — | 8.4.27 (apt, packages.sury.org), yaml 2.3.0, guarded by `PHP_MIN_VERSION` |
| Python | — | embedded 3.9 | 3.11 |
| gnparser | v1.15.0 (TARGETARCH) | — | v1.15.0 |
| Default host port | `127.0.0.1:81`→80 (dev) / `10.252.248.39:8080`→80 (prod, internal IP) | `127.0.0.1:4001`→3306 | `127.0.0.1:8081`→8080 (dev) / `127.0.0.1:8080`→8080 (prod) |
| Restart | unless-stopped | unless-stopped | unless-stopped |
| Platform (web) | `linux/amd64` in compose | — | — |

Database name on first init: **`eol_${MY_ENVIRONMENT}`** (e.g. `eol_development`, `eol_production`).

---

## Quick start — Mac development

```bash
cd My_Docker/docker_eol_connectors

cp .env.development.sample .env
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
chmod 600 .env
# Replace every CHANGE_ME_* value — generate each password with:  openssl rand -hex 24
# Do not reuse old dev passwords from git history.

sudo chown -R 1000:1000 /opt/eol/jenkins_home /opt/eol/jenkins_tmp

# SELinux (if enforcing) — persistent labels, survive a relabel:
sudo semanage fcontext -a -t container_file_t "/opt/eol(/.*)?"
sudo restorecon -Rv /opt/eol

# Populate /opt/eol/webroot and /opt/eol/extra before or after first up
# In eol_php8_code: config/database.yml → host: db, port: 3306 (quoted new password);
#                   config/environments/production.php → JENKINS_DOMAIN 'jenkins:8080' + web-trigger token

# The web container takes 10.252.248.39:8080 — the host's own Apache must not run
sudo systemctl disable --now httpd 2>/dev/null

docker compose -f docker-compose.yml build --no-cache --pull
docker compose -f docker-compose.yml up -d
```

Check the build log for `PHP 8.4.27` (Jenkins PHP version guard).

### Public access (editors.eol.org)

```
browser ──HTTPS──▶ Cloudflare ──HTTPS──▶ 160.111.248.42 ──HTTP:8080──▶ server 10.252.248.39
```

HTTPS ends at 160.111.248.42, which forwards plain HTTP to port 8080 over the internal network (as the old eol-archive Apache listened) — **no certificate on the server**. Set `WEB_PORTS=10.252.248.39:8080:80` so the site is not reachable on the public IP. Cloudflare limits: uploads ≤ 200 MB, requests ≤ 100 s. Details: `docs/rhel9_production_env_guide.md` → *Public access*.

**Jenkins on the server** is bound to `127.0.0.1:8080`. Open it from your machine through an SSH tunnel:

```bash
ssh -L 8080:127.0.0.1:8080 <user>@<server>   # then browse http://localhost:8080
```

**Do not deploy:** `docker-compose.override.yml` — it is **gitignored** (Mac `/Volumes` mount + Neo4j). Production uses only `docker-compose.yml` (web, db, jenkins).

Full guide: **`docs/rhel9_production_env_guide.md`**.

---

## Environment files

| File | Use |
|------|-----|
| `.env.development.sample` | Mac / local dev — copy to `.env` |
| `.env.production.sample` | RHEL 9 — copy to `.env` on server, then `chmod 600 .env` |
| `.env` | Active config (gitignored) |

Key variables:

| Variable | Purpose |
|----------|---------|
| `MY_ENVIRONMENT` | `development` or `production` — selects entrypoint script |
| `WEBROOT_PATH` | Host path → `/var/www/html` |
| `EXTRA_PATH` | Host path → `/extra` (prod symlinks; mounted on web + jenkins) |
| `MYSQL_DATA_DIR` | MySQL data volume (empty on first init) |
| `MYSQL_PASSWORD` | App DB user password (official MySQL env var) |
| `WEB_PORTS` | Mac: `127.0.0.1:81:80`. Prod: `10.252.248.39:8080:80` (internal IP; reached via 160.111.248.42; no clash with Jenkins on `127.0.0.1:8080`) |
| `MYSQL_PORTS` | `127.0.0.1:4001:3306` on both Mac and prod (localhost only; containers use `db:3306`) |
| `JENKINS_PORTS` | Prod: `127.0.0.1:8080:8080` (SSH tunnel); Option B in the sample exposes it on all interfaces |
| `JENKINS_PORTS_COMMUNICATION` | Inbound-agent port. Not published (no agents); commented out in both samples |
| `PATH_JENKINS_HOME` | Host Jenkins data, mounted at `/var/jenkins_home`. The in-container `JENKINS_HOME=/var/jenkins_home` is set in `docker-compose.yml` (`environment:`), not in `.env` |
| `PATH_JENKINS_TMP` | Host temp dir → `/jenkins_tmp` |
| `GNPARSER_VERSION` | gnparser release (default 1.15.0) |
| `PYTHON_APP` | Host path → `/usr/src/app` (Jenkins Python jobs) |
| `NEO_*`, `PATH_NEO4J_*`, `PORT_7474`, `PORT_7687` | Neo4j vars. Used by the Mac override; present in `.env.production.sample` with ports bound to `127.0.0.1` (testing only, not public) |
| `REGISTRY_*` | GHCR image names when using pre-built images (optional) |

---

## Security notes

- **Docker-published ports bypass firewalld.** A port published on all interfaces (e.g. `8080:8080`) is reachable even if firewalld does not open it. Bind anything that is not public to `127.0.0.1` in `.env` — both samples do this for MySQL, Jenkins and Neo4j; the agent port 50000 is not published. Prod web is bound to the **internal IP** only (public traffic arrives via 160.111.248.42).
- **`.env` holds passwords** — `chmod 600 .env` on the server; never commit it.
- **SELinux** — use `semanage fcontext` + `restorecon` (above). `chcon` labels are lost on a relabel. `webroot` and `extra` are mounted by both web and jenkins, so if you use mount suffixes use `:z` (shared), not `:Z`.
- **Jenkins over plain HTTP** — keep it on localhost + SSH tunnel, or put a TLS reverse proxy in front before exposing it.
- **Jenkins access** — Project-based Matrix Authorization; anonymous has no access. The web tools trigger jobs as a **build-only** user (`web-trigger`, API token in `production.php`), never an admin token.
- **Apache (`apache2.conf`)** — `eol_php8_code` lives inside the webroot, so its `config/` (DB passwords), `vendor/`, `lib/`, logs and loose files are denied (403), dotfiles/`.git` return 404, and PHP is switched off in directories Jenkins jobs write to. A new web entry point outside `applications/`, `public/`, `html/` must be checked against these rules.
- **PHP errors in production** — not displayed; read them with `docker compose logs web`. For one page, `ini_set('display_errors', true)` still shows them.
- **MySQL** — the root password comes from `.env` at first init only; changing it later means `ALTER USER` in MySQL, not editing `.env`.

### Changing the MySQL root password

The password lives in MySQL itself (set once at first init) and is copied into `.env`, `eol_php8_code/config/database.yml` and the webroot test pages. Change all of them together; never print the value.

```bash
# 1. New password, kept in a shell variable only
NEWPW=$(openssl rand -hex 24); export NEWPW

# 2. Change it inside MySQL (both root accounts); SQL goes via stdin, not the command line
docker compose exec -T -e NEWPW db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot <<SQL
ALTER USER '"'"'root'"'"'@'"'"'%'"'"' IDENTIFIED WITH mysql_native_password BY '"'"'$NEWPW'"'"';
ALTER USER '"'"'root'"'"'@'"'"'localhost'"'"' IDENTIFIED BY '"'"'$NEWPW'"'"';
SQL'

# 3. Put $NEWPW into MYSQL_ROOT_PASSWORD in .env, the matching database.yml sections (quoted),
#    and test.php / test_development.php — then recreate the containers so they read the new .env
docker compose up -d          # RHEL: docker compose -f docker-compose.yml up -d
unset NEWPW
```

Check: `test.php` shows rows. To find files still holding the old value, use `grep -rlF` with the old password from a variable (prints file names only).

**Old db images:** an image built before Oct 2026 has a root password in `/docker-entrypoint-initdb.d/eli.sql`. Rebuild and drop it (data in `MYSQL_DATA_DIR` is untouched):

```bash
docker compose build --no-cache --pull db && docker compose up -d db
docker image prune -f
docker run --rm --entrypoint ls docker_eol_connectors-db /docker-entrypoint-initdb.d/   # → test_MySQL_db.sql, zz-root-native-password.sh
```

---

## PHP version pins

| Image | How PHP is pinned | To raise it |
|-------|-------------------|-------------|
| **web** | Base image tag `FROM php:8.4.27-apache` | Change the tag to the new 8.4.x release |
| **jenkins** | Latest `php8.4-*` from packages.sury.org + build-time guard `ARG PHP_MIN_VERSION=8.4.27` | Change `PHP_MIN_VERSION` |

The Jenkins guard prints the installed version and stops the build if it is older than `PHP_MIN_VERSION`:

```text
PHP 8.4.27
ERROR: PHP is older than 8.4.27. Rebuild with --no-cache.
```

- A stale cached apt layer can still hold an old PHP → rebuild with `--no-cache --pull`.
- sury sometimes publishes **arm64** builds later than **amd64**. On an Apple Silicon Mac the guard may fail for a day or two after a PHP release while RHEL (amd64) builds fine. Temporary Mac-only workaround: `docker compose build --build-arg PHP_MIN_VERSION=<older> jenkins`, or build amd64 with `DOCKER_DEFAULT_PLATFORM=linux/amd64` (emulated, slower).

---

## PHP 8.4 migration notes

Changes made in **`eol_php8_code`** (webroot, its own git repo) so it runs on 8.4 without deprecation output. Note that `ActiveRecordError::handleError` **echoes every error, including deprecations**, regardless of `display_errors`.

| Change | Where | Fix |
|--------|-------|-----|
| `fgetcsv` / `fputcsv` / `str_getcsv` without `$escape` (deprecated 8.4) | 89 calls in app code + 6 in `vendor/` | Added `escape: '\\'` (the old default — behaviour unchanged) |
| `trigger_error(…, E_USER_ERROR)` (deprecated 8.4) | 4 in app code + 128 in `vendor/` | `E_USER_WARNING` followed by `exit(1)` (same halt + exit code as before) |
| `E_STRICT` constant (deprecated 8.4) | `vendor/php_active_record/classes/active_record_error.php` | Removed from the handler's error-type map (never raised since PHP 8.0) |

Still open (not changed):

- Indirect `E_USER_ERROR` in adodb (`ADODB_ERROR_HANDLER_TYPE`) and SimpleTest mock defaults; `E_STRICT` in monolog / SimpleTest.
- `vendor/google_client_lib_2023` is Composer-managed — `composer update` would undo the edits there.
- Files that do not parse on PHP 8 (pre-existing): `applications/species_stat/moreinfo.php`, `lib/connectors/SummaryDataResourcesAllAPI.php`, and 12 files in `vendor/rdfapi-php` / PHPExcel unit tests (rdfapi-php is only loaded when `USING_SPM`).
- `utf8_encode` / `utf8_decode` (194 calls) — deprecated since 8.2, still work in 8.4, removed in PHP 9.

---

## Upgrading Jenkins

Job data in `jenkins_home/jobs/` (`config.xml` + `builds/`) is read as-is by newer Jenkins. Jenkins may re-save migrated config in the newer format, which an **older** Jenkins may not read — so always back up first. Most problems come from **plugins**, not from job data (40 of the top-level `jobs/` entries are Folders → the `cloudbees-folder` plugin must load).

1. **Update all plugins on the current version** (Manage Jenkins → Plugins → Updates); restart; confirm **0 failed plugins**.
2. **Back up** `jenkins_home`:
   ```bash
   docker compose stop jenkins
   tar -czf ~/jenkins_home_$(date +%F).tgz -C <parent of jenkins_home> jenkins_home
   ```
3. Optional for big jumps: test on a **copy** — point `PATH_JENKINS_HOME` in `.env` at the copy. Jobs run on the copy still change the **real** webroot, `/extra`, MySQL and Python folders.
4. Change `FROM jenkins/jenkins:<lts>-jdk21` in `jenkins/Dockerfile`, then:
   ```bash
   docker compose build --no-cache --pull jenkins
   docker compose up -d jenkins
   docker compose logs -f jenkins     # wait for "Jenkins is fully up and running"
   ```
5. Verify: `cat <jenkins_home>/jenkins.install.InstallUtil.lastExecVersion` shows the new version; no `Failed Loading plugin` lines; **Manage Old Data** is clean; folders and jobs present; run 2–3 jobs.
6. **Update plugins again** on the new version and restart.

Notes:

- From **2.555.1** Jenkins requires Java 21 or 25 (the `-jdk21` image is fine).
- From **2.580.1** nine plugins are no longer bundled (bouncycastle-api, command-launcher, jdk-tool, jaxb, trilead-api, sshd, javax-activation-api, javax-mail-api, instance-identity). Jenkins downloads them from the update center when needed. If the RHEL server **cannot reach updates.jenkins.io**, copy those `.jpi` files into `jenkins_home/plugins/` before the first start.
- Read every LTS upgrade guide between your old and new version: https://www.jenkins.io/doc/upgrade-guide/
- The Workspace Cleanup plugin ("deletes the project workspace when invoked") only acts when a job uses it; updating it deletes nothing.

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
| Env vars | `NEO_*`, `PATH_NEO4J_*` in `.env` (from `.env.development.sample`) | present in `.env.production.sample` (ports on `127.0.0.1`), unused while no `neo4j` service is defined |
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
# Single service, no cache rebuild (--pull also refreshes the base image)
docker compose build --no-cache --pull web && docker compose up -d --force-recreate web

# Production (explicit — no override)
docker compose -f docker-compose.yml up -d

# Stop / remove
docker compose down

# Logs
docker compose logs -f web

# Shell into container
docker compose exec web bash

# PHP version in each image
docker compose exec web php -v
docker compose exec jenkins php -v

# Prune dangling <none> images
docker image prune -f
```

---

## Mac dev vs RHEL prod

| | Mac dev | RHEL prod |
|--|---------|-----------|
| Env template | `.env.development.sample` | `.env.production.sample` |
| `MY_ENVIRONMENT` | `development` | `production` |
| Override file | `docker-compose.override.yml` (from `.sample`) | **must not exist** |
| Services | web, db, jenkins, **neo4j** | web, db, jenkins only |
| Base paths | `/Volumes/OWC_Express/...` | `/opt/eol/...` |
| Compose | `docker compose up -d` | `docker compose -f docker-compose.yml up -d` |
| Extra data | `/Volumes` mount + dev symlinks | `/opt/eol/extra` → `/extra` |
| Non-public ports | `127.0.0.1` | `127.0.0.1` (SSH tunnel) |
| Web port | `127.0.0.1:81` | `10.252.248.39:8080` — public via Cloudflare → 160.111.248.42 |
| PHP errors | displayed | logged only (`docker compose logs web`) |

---

## Troubleshooting

| Symptom | Likely cause |
|---------|--------------|
| MySQL `Connection refused` from test.php | Using port 4001 inside container — use **3306** and host **`db`** |
| Empty `employees_tbl` | Init SQL ran once; wrong INSERT column order; re-init empty `MYSQL_DATA_DIR` |
| Port 80 / 8080 in use | Mac: often Docker (`com.docke`) — `docker ps --filter "publish=80"`. RHEL: the host's own `httpd` — `sudo systemctl disable --now httpd` |
| 403 on `eol_php8_code/config/…`, `*.yml`, `vendor/` | Expected — denied in `apache2.conf` (secrets/code not downloadable) |
| Blank page / no PHP error in production | Errors are logged, not shown — `docker compose logs web`, or `ini_set('display_errors', true)` on that page |
| Web tool can't start a Jenkins job | `JENKINS_DOMAIN` must be `jenkins:8080`; `web-trigger` token valid and has Build on the job |
| Permission denied on RHEL | SELinux — `semanage fcontext -a -t container_file_t "/opt/eol(/.*)?"` then `restorecon -Rv /opt/eol` |
| Override on production | Should not exist — gitignored; use `-f docker-compose.yml` only |
| Neo4j missing on Mac | Copy `docker-compose.override.sample.yml` → `docker-compose.override.yml` |
| Neo4j mount error on Mac | External drive not in Docker File Sharing (`/Volumes/Crucial_2TB`, etc.) |
| Nested `opendata/opendata` symlink | Dev entrypoint removes it; recreate web container if links look wrong |
| Jenkins empty after `.env` change | Use **`PATH_JENKINS_HOME`** / **`PATH_JENKINS_TMP`** for host paths — not `JENKINS_HOME` in `.env` |
| Jenkins build: `ERROR: PHP is older than 8.4.27` | Stale apt cache → `--no-cache --pull`; on Apple Silicon, sury arm64 may lag amd64 — see [PHP version pins](#php-version-pins) |
| `requested image's platform (linux/amd64) does not match the detected host platform` | Image built for amd64 on an arm64 Mac — runs emulated. Rebuild without `DOCKER_DEFAULT_PLATFORM` for a native image |
| Jenkins log: `Failed Loading plugin … Update required` | Dependency plugin too old — update the named plugin(s) (e.g. `ssh-credentials`, `cloudbees-folder`), restart |
| Jenkins on server not reachable from browser | Bound to `127.0.0.1` by design — use `ssh -L 8080:127.0.0.1:8080 <user>@<server>` |
| `Deprecated:` lines in PHP output | PHP 8.4 deprecations echoed by `ActiveRecordError::handleError` — see [PHP 8.4 migration notes](#php-84-migration-notes) |

---

## Notes

- **Web entrypoints** use `${PWD}` (`/var/www/html`) and **`ensure_symlink`** (`ln -sfn`) — see tables above.
- **Jenkins:** compose sets in-container `JENKINS_HOME=/var/jenkins_home`; host bind path is **`PATH_JENKINS_HOME`** in `.env`.
- **First MySQL init** runs SQL in `mysql/test_MySQL_db.sql` only when `MYSQL_DATA_DIR` is empty.
- **`docker-compose.override.yml`** is gitignored — on Mac, copy from **`docker-compose.override.sample.yml`** (adds `/Volumes` mount + Neo4j).
- **Neo4j** runs on Mac dev only; production `docker-compose.yml` has no Neo4j service.
- **PHP session IDs:** with the `sid_*` php.ini settings removed (PHP defaults now apply), existing session cookies are not recognised once — users holding one get a new session.
- For Kubernetes production workloads, use **`dock_eol_conn_wf`** + **`eol-apps-connectors`** [GitHub](https://github.com/EOL/eol-apps-connectors/tree/main/connectors) instead of this full compose stack.
