# EOL Connectors — RHEL 9 production `.env` layout

**Project:** `docker_eol_connectors`  
**Updated:** 2026-10-26  
**Repo path:** `My_Docker/docker_eol_connectors/`  
**Template file:** `.env.production.sample`  
**Init script:** `scripts/rhel9-init-dirs.sh`

---

## Summary

The stack **will run on RHEL 9** if you:

1. Use **Linux paths** (e.g. `/opt/eol/...` or `/srv/eol/...`)
2. Set **`MY_ENVIRONMENT=production`**
3. Use **`.env.production.sample`** as the basis for server `.env` (`chmod 600 .env`)
4. Populate **`/opt/eol/extra`** subdirs expected by `docker-entrypoint_production.sh`
5. Handle **SELinux** labels on bind mounts (`semanage fcontext` + `restorecon`)
6. Keep non-public ports on **`127.0.0.1`** — Docker-published ports bypass firewalld
7. Bind web to the server's **internal IP** (`WEB_PORTS=10.252.248.39:8080:80`) — HTTPS ends upstream at 160.111.248.42, no certificate on the server (see *Public access: editors.eol.org*)

`docker-compose.override.yml` is **gitignored** — it stays on your Mac for dev (`/Volumes` mount + Neo4j) and is **not included in git clone/deploy** to RHEL.

---

## Stack versions (Oct 2026)

| Service | Image | Notes |
|---------|-------|-------|
| web | `php:8.4.27-apache` | PHP 8.4.27 fixes PHP2Shell (CVE-2026-109618 / CVE-2026-109619) |
| jenkins | `jenkins/jenkins:2.580.1-jdk21` | LTS; PHP 8.4.27 from packages.sury.org, build fails if older than `PHP_MIN_VERSION` |
| db | `mysql:8.4.13-oraclelinux9` | |
| neo4j | `neo4j:5.26.29-community-ubi10` | Mac dev only (override file) |

Details: repo **`README.md`** → *Recent updates*, *PHP version pins*, *Upgrading Jenkins*.

---

## Repo files for production (committed)

| File | Purpose |
|------|---------|
| `.env.production.sample` | RHEL 9 production `.env` template (`/opt/eol/...` paths, localhost-bound admin ports) |
| `scripts/rhel9-init-dirs.sh` | Creates host directory tree under `/opt/eol` |
| `scripts/eol-archive-inventory.sh` | Read-only inventory of the old server's data (webroot, `/extra`): sizes, file counts, newest files, symlinks leaving the tree, files not in git, crontabs. Runs on RHEL 7 and macOS |
| `scripts/eol-inventory-compare.sh` | Compares two inventories (old server vs a copy): missing folders, fewer files, smaller, newer on the source |
| `docker-compose.yml` | Main compose file — **three services: web, db, jenkins** |
| `neo4j/Dockerfile` | `FROM neo4j:5.26.29-community-ubi10` — used only by the Mac override file |
| `.gitignore` | Excludes `docker-compose.override.yml`, `.env`, Mac-only files |

**Not in repo (Mac dev only):** `docker-compose.override.yml`

---

## Neo4j — Community Edition (was Enterprise)

_Neo4j is **not** part of the RHEL production stack: `docker-compose.yml` has no `neo4j` service. It runs on Mac dev via `docker-compose.override.yml`. The notes below apply wherever a `neo4j` service exists (Mac, or a future RHEL test setup — TraitBank 1.0 testing only, never public)._

| | Previous | Current |
|--|----------|---------|
| Image | `neo4j:5.26.12-enterprise-ubi9` | **`neo4j:5.26.29-community-ubi10`** |
| Edition | Enterprise (license required) | **Community** (no license) |
| Base OS | UBI9 | **UBI10** (runs on RHEL 9 hosts in Docker) |
| User database | Named DBs (e.g. `db.eol`) | **Single DB: `neo4j`** |
| `NEO4J_ACCEPT_LICENSE_AGREEMENT` | Required | **Not used** |

### Community limitations (important)

| Enterprise command / feature | Community |
|------------------------------|-----------|
| `STOP DATABASE` / `START DATABASE` | **Not supported** — stop container instead |
| `CREATE DATABASE` | **Not supported** |
| Multiple user databases (`db.eol`, etc.) | **Not supported** — use **`neo4j`** only |
| `neo4j-admin database import full` | **Supported** — stop Neo4j container first |

### `.env` Neo4j settings (production sample)

On RHEL only the four connection vars are used — compose passes them to **jenkins** for Python jobs. The rest are unused unless a `neo4j` service is added.

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

PORT_7474=127.0.0.1:7474:7474   # localhost only — SSH tunnel
PORT_7687=127.0.0.1:7687:7687
```

APOC is enabled in the override's neo4j service: `NEO4J_PLUGINS=["apoc"]`.

### TraitBank CSV import (Community)

Run where the `neo4j` service is defined (Mac: plain `docker compose`, which merges the override):

```bash
# Stop Neo4j completely (replaces Enterprise STOP DATABASE)
docker compose stop neo4j

docker compose run --rm --entrypoint neo4j-admin neo4j \
  database import full neo4j \
  --overwrite-destination=true \
  --nodes=import2/AnimalDiversityWeb_TraitBank_1_0_csv/nodes/Resource.csv \
  ... # remaining --nodes, --relationships, --schema flags

docker compose up -d neo4j
```

CSV path: host `PATH_NEO4J_IMPORT2` → container `/var/lib/neo4j/import2`.

### Verify Neo4j

```bash
docker compose logs neo4j
curl -I http://localhost:7474      # Mac dev: the host port from PORT_7474, e.g. 7494
```

Browser: `http://localhost:<port>/browser/` (on a server: through `ssh -L 7474:127.0.0.1:7474 -L 7687:127.0.0.1:7687 <user>@<server>`) — connect to database **`neo4j`**.

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
├── jenkins_home/            ← PATH_JENKINS_HOME → /var/jenkins_home
├── jenkins_tmp/             ← PATH_JENKINS_TMP → /jenkins_tmp
├── python_projects/         ← PYTHON_APP → /usr/src/app
├── neo4j/                   ← created by the init script; used only if a neo4j service is added
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
| `MY_ENVIRONMENT` | `production` | Uses `docker-entrypoint_production.sh`; eol_php8_code then uses the `production` and `jenkins_production` sections of `database.yml` |
| `EXTRA_PATH` | `/opt/eol/extra` | Mounted as `/extra`; symlinks at startup |
| `WEBROOT_PATH` | `/opt/eol/webroot` | PHP connector codebase |
| `MYSQL_DATA_DIR` | `/opt/eol/mysql_data` | **Empty** on first DB init |
| `MYSQL_USER` | `eol_app` (sample default) | Created by the MySQL image on first init with rights on `eol_production` only; the PHP code logs in as it (`database.yml`, `test.php`) |
| `MYSQL_PASSWORD` | *(set in .env)* | Official MySQL env var |
| `MYSQL_PORTS` | `127.0.0.1:4001:3306` | Localhost only |
| `JENKINS_MEM_LIMIT` / `WEB_MEM_LIMIT` / `DB_MEM_LIMIT` | *(unset)* → `32g` / `6g` / `2g` | Sized for the production server (at least 64 GB RAM, ~10 users): 40 GB in total, ~24 GB left for the OS and file cache. With more RAM, raise `JENKINS_MEM_LIMIT` first (connector runs) |
| `WEB_PORTS` | `10.252.248.39:8080:80` | Internal IP only — 160.111.248.42 forwards `editors.eol.org` to port 8080 (as with the old native Apache). No clash with Jenkins on `127.0.0.1:8080`. Port 80 instead needs .42 re-pointed |
| `JENKINS_PORTS` | `127.0.0.1:8080:8080` | Localhost only — SSH tunnel. Option B (`8080:8080`) only behind a TLS reverse proxy |
| `JENKINS_PORTS_COMMUNICATION` | *(commented out)* | Inbound-agent port. Not published: no agents, and the agent TCP port is disabled in Jenkins |
| `PORT_7474` / `PORT_7687` | `127.0.0.1:…` | Only relevant if a neo4j service is added |
| `NEO_DATABASE` | **`neo4j`** | Community single database (not `db.eol`) |
| MySQL DB name (auto) | `eol_production` | From `eol_${MY_ENVIRONMENT}` in compose |

Full template: **`.env.production.sample`**

```bash
cp .env.production.sample .env
chmod 600 .env
# Replace every CHANGE_ME_* value — one per password:  openssl rand -hex 24
# Do not reuse old dev passwords from git history.
```

---

## Compose notes (production-ready)

| Setting | Value | Notes |
|---------|-------|-------|
| `web` base image | `php:8.4.27-apache` | Raise the tag for new 8.4.x security releases |
| `jenkins` base image | `jenkins/jenkins:2.580.1-jdk21` | PHP from sury; `PHP_MIN_VERSION=8.4.27` guard in `jenkins/Dockerfile` |
| `db` → `MYSQL_PASSWORD` | `${MYSQL_PASSWORD}` | Official MySQL env var |
| `web` → `platform` | `linux/amd64` | Explicit amd64 for RHEL x86_64 |
| `neo4j` | not in `docker-compose.yml` | Mac override only |
| All services → `restart` | `unless-stopped` | Survives host reboot (with `docker.service` enabled) |

---

## Deploy steps on RHEL 9

```bash
# 1. Install Docker CE (from Docker's repo; remove the Podman docker shim first)
sudo dnf remove -y podman-docker buildah 2>/dev/null || true
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker $USER   # re-login after. Note: docker group = root-equivalent access

# 2. Clone repo (override file not included — gitignored)
git clone <repo-url> /opt/eol/docker_eol_connectors
cd /opt/eol/docker_eol_connectors

# 3. Host directories + SELinux (persistent labels — survive a relabel)
sudo bash scripts/rhel9-init-dirs.sh
sudo chown -R 1000:1000 /opt/eol/jenkins_home /opt/eol/jenkins_tmp
sudo dnf install -y policycoreutils-python-utils   # provides semanage
sudo semanage fcontext -a -t container_file_t "/opt/eol(/.*)?"
sudo restorecon -Rv /opt/eol

# 4. Configure env
cp .env.production.sample .env
chmod 600 .env
# replace CHANGE_ME_* (openssl rand -hex 24); check ports; NEO_DATABASE=neo4j

# 5. Copy application code + datasets
# rsync webroot (incl. eol_php8_code/) and extra/ — rsync -a, so file dates are kept
# Check the copy against the old server's inventory (made on eol-archive before the wipe):
#   on eol-archive:  sudo bash eol-archive-inventory.sh             (→ ~/eol_inventory_<host>_<date>/)
#   here:            sudo bash scripts/eol-archive-inventory.sh /opt/eol/webroot=webroot /opt/eol/extra=extra
#                    bash scripts/eol-inventory-compare.sh <old report folder> <new report folder>

# 6. Build and start (fresh: picks up current base images and sury PHP)
docker compose -f docker-compose.yml build --no-cache --pull
#   → jenkins build log must show "PHP 8.4.27"
docker compose -f docker-compose.yml up -d

# 7. 10.252.248.39:8080 belongs to the web container — the host's own Apache must not run
#    (the old RHEL 7 eol-archive ran Apache + PHP natively on that port, no Docker)
sudo systemctl disable --now httpd 2>/dev/null; sudo ss -ltnp | grep ':8080 '
#    No firewall-cmd needed: Docker bypasses firewalld; access is limited by
#    binding web to the internal IP (WEB_PORTS=10.252.248.39:8080:80)
```

**Firewall note:** Docker writes its own nftables rules for published ports, so firewalld does **not** restrict them. A port published on all interfaces is reachable even if firewalld never opens it. That is why `.env.production.sample` binds MySQL, Jenkins (8080) and Neo4j to `127.0.0.1` (the agent port 50000 is not published at all) instead of relying on `firewall-cmd`.

## Public access: editors.eol.org (HTTPS)

Confirmed on eol-archive 2026-10-26/27 (a test request landed in Apache's `access_log`; its config has only `Listen 10.252.248.39:8080` and the `editors.eol.org` vhost on `*:8080`):

```
browser ──HTTPS──▶ Cloudflare (proxied) ──HTTPS──▶ 160.111.248.42 ──HTTP:8080──▶ server 10.252.248.39
```

- **HTTPS ends at 160.111.248.42** (a network device; it reaches the server from `10.252.248.42`). The last hop is plain HTTP on the internal network, so **no certificate is needed on the server**. The old `ssl.conf` / `apache.crt` on 443 is not used by this path.
- **Bind web to the internal IP, port 8080:** `WEB_PORTS=10.252.248.39:8080:80`, so .42 needs no change and the site isn't reachable on the public `160.111.248.39`.
- **Network team:** if the rebuilt server keeps internal IP `10.252.248.39`, nothing changes on .42 (still port 8080); otherwise .42 must be re-pointed.
- **Cloudflare** (zone `eol.org`, Business plan, SSL mode *full*): uploads over **200 MB** and requests over **100 s** fail (524) — run long work as Jenkins jobs.
- **Visitor IPs:** built in (`apache-php/zz-remoteip.conf`, `mod_remoteip`). Apache takes the visitor's IP from `X-Forwarded-For`, but only on requests from `REMOTEIP_PROXY` (default `10.252.248.42`; set it in `.env` if .42 changes). Cloudflare's own addresses (`apache-php/cloudflare-ips.txt`) are skipped. Logs and PHP's `REMOTE_ADDR` then show the visitor; nothing in the code uses it for access control.
  - **Check after go-live:** open the site through `editors.eol.org`, then `tail /opt/eol/apache2_logs/access.log`. Your own public IP (e.g. from `curl ifconfig.me` on your laptop) should appear, not `10.252.248.42`.
  - If it still shows `10.252.248.42`, .42 doesn't send `X-Forwarded-For`. Ask the network team which header it sends; if it only passes Cloudflare's `CF-Connecting-IP`, change `RemoteIPHeader` to that and rebuild web.
  - If it shows a `104.x`/`162.158.x`/`172.64.x` address, Cloudflare's IP list has changed: refresh `cloudflare-ips.txt` from https://www.cloudflare.com/ips-v4 and `/ips-v6`, rebuild web.
- **Secure cookies:** PHP sees plain HTTP. If .42 sends `X-Forwarded-Proto`, add `SetEnvIf X-Forwarded-Proto https HTTPS=on`. Set `session.cookie_secure = 1` in `zz-production.ini` only if nobody uses the site over internal plain HTTP.
- **Old URLs:** eol-archive served the PHP 5.6 tree at `/eol_php_code/...`; `apache2.conf` aliases that path to `eol_php8_code`, so existing links keep working.
- **Not carried over:** mod_security rule exceptions (no mod_security in the container), the stock `localhost.crt` on 443.

**Jenkins from your machine** (bound to localhost on the server):

```bash
ssh -L 8080:127.0.0.1:8080 <user>@<server>   # then browse http://localhost:8080
```

**Jenkins first start:** 2.580.1 no longer bundles nine plugins (bouncycastle-api, command-launcher, jdk-tool, jaxb, trilead-api, sshd, javax-activation-api, javax-mail-api, instance-identity). Jenkins downloads them when needed — if the server cannot reach `updates.jenkins.io`, copy the `.jpi` files into `/opt/eol/jenkins_home/plugins/` before the first start. If you bring an existing `jenkins_home` over from an older Jenkins, follow README → *Upgrading Jenkins* (back up, update plugins before and after, check **Manage Old Data**).

### Verify

```bash
docker compose -f docker-compose.yml ps
curl -I http://localhost/test.php

# MySQL — password is read from the container's env, not your shell
docker compose -f docker-compose.yml exec db \
  sh -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD" eol_production -e "SHOW TABLES;"'

# PHP versions
docker compose -f docker-compose.yml exec web php -v
docker compose -f docker-compose.yml exec jenkins php -v

# Jenkins version + startup
cat /opt/eol/jenkins_home/jenkins.install.InstallUtil.lastExecVersion   # 2.580.1
docker compose -f docker-compose.yml logs jenkins | grep -E "fully up and running|Failed Loading plugin"
```

---

## test.php on production

Inside containers, MySQL host is **`db`**, port **`3306`** (not host-mapped 4001):

```php
$host = 'db';
$port = 3306;
$user = 'eol_app';                      // MYSQL_USER
$pass = '<MYSQL_PASSWORD from .env>';
$db   = 'eol_production';
```

Browser (from inside the network): `http://10.252.248.39:8080/test.php`, or `https://editors.eol.org/test.php` once .42 forwards to the new server

## eol_php8_code `config/database.yml` (gitignored — copy by hand)

The `production` and `jenkins_production` sections must use the Compose service name, not `127.0.0.1` or a container IP:

```yaml
production:
  host: db
  username: eol_app
  password: "<MYSQL_PASSWORD from .env>"
  database: eol_production
  encoding: utf8
  port: 3306
```

Same for `jenkins_production`. Quote the password. Use the app user, not root (N3): root stays for admin work by hand, and its password lives only in `.env`. Use **new** passwords on the server: everything in this repo's git history, and eol-archive's old `database.yml`, counts as exposed.

`test.php` runs `shell_exec`: put it in `/opt/eol/webroot` by hand for the smoke test, then remove it. The production image and entrypoint never copy `info.php` (phpinfo); if the webroot was copied from the Mac, delete any `info.php` in it (the web container logs a warning when it finds one).

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

Pre-built images must be rebuilt after each PHP / Jenkins security bump — a `latest` tag pushed before the bump still has the old versions.

---

## Known issues to watch

| Issue | Detail |
|-------|--------|
| Apache log looks cut off | `rotatelogs -n 5` cycles `access.log` → `access.log.1` … `.4` → back to `access.log` (50 MB each; `error.log` 20 MB). The newest lines may be in any of them: `ls -lt /opt/eol/apache2_logs` |
| A container is killed with exit code 137 | It hit its memory limit (`docker inspect <container> --format '{{.State.OOMKilled}}'`). Raise `*_MEM_LIMIT` in `.env`, then `docker compose -f docker-compose.yml up -d` |
| `required variable X is missing a value` | `X` is missing or empty in `.env` (M8). Add it (see `.env.production.sample`); Compose checks this before starting anything |
| Build stops: `gnparser download does not match SHA-256` | The download changed or `GNPARSER_VERSION`/`GNPARSER_URL` was changed (M3). For a new version, take the SHA-256 from the GitHub release page, check it, and set `GNPARSER_SHA256` in `.env` |
| `UnsupportedAdministrationCommand: STOP DATABASE` | Enterprise-only — use `docker compose stop neo4j` |
| `db.eol` not found | Community uses **`neo4j`** — update `NEO_DATABASE` and app configs |
| Neo4j import "database in use" | Stop container before `neo4j-admin database import full` |
| Enterprise dump → Community | Block dumps may fail — re-import CSV instead |
| `no such service: neo4j` with `-f docker-compose.yml` | Expected — Neo4j is defined only in the Mac override |
| First MySQL init | `MYSQL_DATA_DIR` must be empty; init SQL runs once only |
| SELinux permission denied | `semanage fcontext -a -t container_file_t "/opt/eol(/.*)?"` + `restorecon -Rv /opt/eol`. If you add mount suffixes, use `:z` (webroot / extra are shared by web + jenkins), not `:Z` |
| Port open although firewalld blocks it | Docker bypasses firewalld — bind to `127.0.0.1` in `.env` |
| Jenkins build: `ERROR: PHP is older than 8.4.27` | Stale apt layer → `build --no-cache --pull jenkins` |
| Jenkins: `Failed Loading plugin … Update required` | Update the named dependency plugin(s), restart |
| Port 8080 conflicts | Check with `sudo ss -ltnp \| grep ':8080 '` — usually the host's own `httpd`: `sudo systemctl disable --now httpd` |
| `JAVA_OPTS` spacing | Leading space in compose value — verify Jenkins starts cleanly |
| PHP sessions reset once | `session.sid_*` php.ini settings removed for PHP 8.4 — existing session cookies are not recognised once |

**Resolved:** `MYSQL_USER_PW` → **`MYSQL_PASSWORD`** in compose and env samples.

---

## Mac dev vs RHEL prod

| | Mac dev | RHEL prod |
|--|---------|-----------|
| Override file | local only (`docker-compose.override.yml`, gitignored) | not in repo |
| `MY_ENVIRONMENT` | `development` | `production` |
| Symlinks | `/Volumes/AKiTiO4/...` (dev entrypoint) | `/extra/...` (prod entrypoint) |
| Base path | `/Volumes/OWC_Express/...` | `/opt/eol/...` |
| Env template | `.env.development.sample` | `.env.production.sample` |
| Neo4j | Community 5.26.29 UBI10 (override) | **not running** (no service in `docker-compose.yml`) |
| `NEO_DATABASE` | **`neo4j`** | **`neo4j`** (passed to jenkins) |
| Admin ports (MySQL, Jenkins, Neo4j) | `127.0.0.1` only | `127.0.0.1` only — SSH tunnel |
| Web port | `127.0.0.1:81` (Mac only) | `10.252.248.39:8080` — public via Cloudflare → 160.111.248.42 |
| Compose (Mac) | `docker compose up -d` | n/a |
| Compose (RHEL) | n/a | `docker compose -f docker-compose.yml up -d` |
| Web platform | `linux/amd64` in compose (emulated on Apple Silicon) | `platform: linux/amd64` in compose |
| Jenkins image arch | native arm64 (sury arm64 PHP builds may lag a day or two) | amd64 |

---

## Quick reference commands

```bash
# Rebuild web only, no cache (--pull refreshes the base image)
docker compose -f docker-compose.yml build --no-cache --pull web
docker compose -f docker-compose.yml up -d --force-recreate web

# Rebuild jenkins (back up /opt/eol/jenkins_home first when the Jenkins version changes)
docker compose -f docker-compose.yml build --no-cache --pull jenkins
docker compose -f docker-compose.yml up -d jenkins

# Re-init MySQL (destroys data — backup first)
docker compose -f docker-compose.yml down
sudo rm -rf /opt/eol/mysql_data/*
docker compose -f docker-compose.yml build --no-cache db
docker compose -f docker-compose.yml up -d db

# Reset Neo4j graph store — Mac dev (override); destroys data — backup first
docker compose stop neo4j
rm -rf "<PATH_NEO4J_DATA>"/*
docker compose up -d neo4j
```

See also: repo **`README.md`** (Recent updates, Security notes, Upgrading Jenkins, Neo4j) · **`desktop/devops/docker_compose_up_info.md`**
