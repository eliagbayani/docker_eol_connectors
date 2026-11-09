# eol-archive: the current setup, and how to rebuild it

**As of 2026-11-10.** editors.eol.org runs on eol-archive since **2026-11-09** (DNS switch). The server check `scripts/rhel9-verify.sh` gives **81 OK, 0 WARN, 0 FAIL**.

This document records everything that makes up the running setup: what is in git, what is not, and every setting changed after the deployment checklist (`docs/deploy_day_checklist.md`). With the checklist, this document and a snapshot archive (section 6), the stack can be rebuilt on another machine.

No passwords, tokens or keys are in this document. They are in `.env`, `database.yml`, `production.php`, Jenkins' `secrets/` and the HTTPS key, all of which are in the snapshot archive.

---

## 1. The server

| | |
|---|---|
| Host | eol-archive, RHEL 9.8, physical server, SELinux **Enforcing** |
| Addresses | **160.111.248.39** (public, `eno2`), **10.252.248.39** (internal, `eno1`) |
| Disks | root 10 GB (about 8.6 GB used by the admins' agents: NetBackup, SentinelOne, Splunk); data volume **`/extra`** 9.1 TB (XFS, ~3.8 TB data kept from the old server) |
| Memory | 62 GB; our stack uses about 1.3 GB |
| Default umask | **0027** (new files 640, folders 750), which is why the containers' users get ACLs |
| Login | from the Mac: `ssh archive` (`~/.ssh/config`: 10.252.248.39 through the jump host `si`); the deploying login `eagbayani` is in the `docker` group |
| Who does what | network team: firewall, Cloudflare, DNS. Us: everything under `/extra/eol_docker` and the containers |

## 2. What runs

Three containers, from the Docker package in `/extra/eol_docker/docker_eol_connectors` (git: `github.com/eliagbayani/docker_eol_connectors`, branch `main`):

| Container | Software | Listens on | Memory cap |
|---|---|---|---|
| `docker_eol_connectors-web-1` | Apache + PHP **8.4.27** (sury), gnparser 1.15.0 | **160.111.248.39:443** (HTTPS, Cloudflare only) and **10.252.248.39:8080** (plain HTTP, internal) | 6g |
| `docker_eol_connectors-db-1` | MySQL **8.4.13** | 127.0.0.1:4001 | 2g |
| `docker_eol_connectors-jenkins-1` | Jenkins **2.580.2** (JDK 21), PHP 8.4, gnparser | 127.0.0.1:8080 | 32g |

- Docker 29.9.3 with Docker Compose, storage on `/extra/docker` and `/extra/containerd`, internal networks in **10.10.0.0/16** (the stack's network is `10.10.0.0/24`, the default bridge `10.10.1.0/24`).
- All three start at boot (`restart: unless-stopped`; Docker waits for `/extra`).
- **Visitors:** Cloudflare (proxied, SSL mode *Full*) → 160.111.248.39:443. Apache admits only Cloudflare's ranges, plus the server and its containers (`HTTPS_ALSO_ALLOW`); everyone else gets 403. Visitor IPs in the log come from `X-Forwarded-For`.
- **Jenkins from the Mac:** `ssh -N -L 8090:127.0.0.1:8080 archive`, then http://localhost:8090.

## 3. Where everything is

| Path on eol-archive | What | In git? | In the snapshot? |
|---|---|---|---|
| `/extra/eol_docker/docker_eol_connectors/` | the Docker package (compose file, Dockerfiles, scripts, docs) | **yes** | local changes only (`git diff`) |
| `…/docker_eol_connectors/.env` | settings: passwords, ports, paths, limits | no | **yes** |
| `/extra/eol_docker/webroot/eol_php8_code`, `FreshData_min`, `LiteratureEditor_min` | the PHP code (3 GitHub repos) | **yes** | the 2 config files and the links |
| `…/eol_php8_code/config/database.yml` | database logins (production section: `db`, `eol_app`) | no | **yes** |
| `…/eol_php8_code/config/environments/production.php` | code settings (`WEB_ROOT`, `JENKINS_DOMAIN`, `JENKINS_USER_TOKEN`, …) | no | **yes** |
| `…/eol_php8_code/applications/content_server/resources` | link to `/extra/eol_php_resources/` | no | the link |
| `…/FreshData_min/TSV_files` | link to `/extra/FreshData_TSV_files` | no | the link |
| `/extra/eol_docker/jenkins_home` | Jenkins: jobs, settings, users, credentials, secrets, plugins | no | **yes**, without build history, workspaces and plugin files (`plugins_current.txt` lists them) |
| `/extra/eol_docker/mysql_data` | MySQL's files | no | no: use the dump |
| `/extra/eol_docker/backups` | nightly MySQL dumps (newest 10) and `mysql-backup.log` | no | the newest dump |
| `/extra/eol_docker/certs` | HTTPS certificate and key (self-signed, 10 years) | no | **yes** |
| `/extra/eol_docker/apache2_logs` | Apache's access and error logs | no | no |
| `/extra/eol_docker/snapshots` | the snapshot archives | no | n/a |
| `/extra/dumps`, `eol_connector_data_files`, `ckan_resources`, `other_files`, `gnfinder`, `eol_php_resources`, `FreshData_TSV_files`, `eol_php_cache`, `eol_php_cache2` | the data (about 3.8 TB) | no | no: it stays on `/extra` (the admins back up the server) |

## 4. Settings beyond the deployment checklist

Everything here was set or changed on the running server, and the snapshot captures it.

**`.env`** (from `.env.production.sample`, then):
- two new random passwords (`MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, 48 characters)
- `SELF_FETCH_HOST=editors.eol.org`, `SELF_FETCH_IP=160.111.248.39` (added 2026-11-09): inside web and jenkins, the code's requests to its own site go straight to the server, because through Cloudflare they get 403 from its bot check
- memory caps: the defaults (jenkins 32g, web 6g, db 2g). Raising them to `JENKINS_MEM_LIMIT=40g` and `WEB_MEM_LIMIT=8g` was considered and postponed (2026-11-10); the server has room for it.

**`production.php`** (copied from the Mac, then):
- `WEB_ROOT` = `https://editors.eol.org/eol_php8_code/` (the Mac's `host.docker.internal:81` breaks the web tools' download links on the server)
- `JENKINS_DOMAIN` = `jenkins:8080`
- `JENKINS_USER_TOKEN` = `'web-trigger:<token>'` (user name, colon, token)

**`database.yml`:** the production section uses host `db`, port 3306, user `eol_app`, and the `MYSQL_PASSWORD` from `.env` (quoted).

**Jenkins** (configuration copied from the Mac on 2026-11-07, then):
- Jenkins URL: `http://localhost:8090/`
- admin user `eagbayani` (password changed on the server); user `web-trigger` with a new API token (made in the Script Console, the copied tokens revoked)
- security: matrix authorization (`eagbayani` Administer, `web-trigger` Read + Build); agents' TCP port disabled
- plugins: the 94 from the Mac, then updated in Jenkins (incl. 8 with security advisories). The current list is in the snapshot (`plugins_current.txt`).
- the WoRMS job's *Build other projects* link to a Neo4j job removed
- **all 21 timers removed** (2026-11-08): the timed jobs run on the Mac only. The old schedules are in `jenkins_home/timers_removed.tsv`. List of the jobs: see the reports folder, `scheduled_jobs.md`
- not copied: the Neo4j jobs, build history

**Host:**
- `/etc/docker/daemon.json`: `data-root` `/extra/docker`, `bip` `10.10.1.1/24`, address pool `10.10.2.0/16` (size 24)
- `/etc/containerd/config.toml`: first line `root = "/extra/containerd"`
- systemd drop-ins `/etc/systemd/system/{docker,containerd}.service.d/extra.conf`: `RequiresMountsFor=/extra`
- SELinux rules (`semanage fcontext`): `/extra(/.*)?` → `container_file_t`; `/extra/docker` and `/extra/containerd` equal to `/var/lib/docker` and `/var/lib/containerd`
- ACLs for uid 33 (website) and uid 1000 (Jenkins), rwX with defaults, on: `dumps`, `eol_connector_data_files`, `ckan_resources`, `eol_php_resources` (incl. `cache`), `FreshData_TSV_files`, `gnfinder`, `other_files` (the 3 hashed caches on their folders only), `eol_php_cache`, `eol_php_cache2`; read access on the webroot; rwX on the code's work folders; the deploying login can read `apache2_logs`
- `/etc/cron.allow` lists `eagbayani` (2026-11-10, with the admins' OK)
- crontab of `eagbayani`: `30 2 * * * cd /extra/eol_docker/docker_eol_connectors && bash scripts/mysql-backup.sh >> /extra/eol_docker/backups/mysql-backup.log 2>&1` (2:30 New York time)
- the host's own `httpd` disabled (if present)

**Network team (outside the server):** firewall open for 443 to 160.111.248.39 (2026-11-06); Cloudflare's `editors.eol.org` record → 160.111.248.39, proxied (2026-11-09); test record `editors-test.eol.org` (to be removed by them); the old front device 160.111.248.42 is to be retired.

## 5. Routine operations (on eol-archive, in `/extra/eol_docker/docker_eol_connectors`)

| Task | Command |
|---|---|
| Check everything | `bash scripts/rhel9-verify.sh 2>&1 \| grep -E 'FAIL\|WARN\|Summary'` (wait 1–2 minutes after a restart) |
| State of the containers | `docker compose -f docker-compose.yml ps` |
| Logs | `docker compose -f docker-compose.yml logs --tail 50 web` (or `db`, `jenkins`); Apache: `/extra/eol_docker/apache2_logs/` |
| Database backup now | `bash scripts/mysql-backup.sh` (nightly at 2:30 anyway; newest 10 kept) |
| Restore the database | `gunzip -c /extra/eol_docker/backups/<file>.sql.gz \| docker compose -f docker-compose.yml exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot'` |
| Update the package | `git pull`, then `docker compose -f docker-compose.yml up -d` (a rebuild only if a Dockerfile changed: `build`, then `up -d`) |
| Change a setting in `.env` | edit `.env`, then `docker compose -f docker-compose.yml up -d` (recreates the containers that use it) |
| Snapshot of all settings | `sudo bash scripts/rhel9-snapshot.sh`, then copy it off the server (section 6) |

## 6. Saving everything: the snapshot

`scripts/rhel9-snapshot.sh` packs everything that is not in git into one archive:

```bash
cd /extra/eol_docker/docker_eol_connectors
sudo bash scripts/rhel9-snapshot.sh
```
→ `/extra/eol_docker/snapshots/eol-archive_snapshot_YYYYMMDD_HHMM.tar.gz` (mode 600)

| In the archive | What |
|---|---|
| `REPORT.txt` | versions, git commits of the 4 repos, containers, images, network, ports, memory, disks |
| `stack/.env`, `stack/certs/`, `stack/git_diff_…patch` | the settings, the HTTPS certificate and key, any local change to the package |
| `code_config/database.yml`, `code_config/production.php`, `symlinks.txt`, `git_status_*.txt` | the code's private config files and links |
| `jenkins/jenkins_home_config.tar`, `jenkins/plugins_current.txt` | Jenkins' configuration (jobs, users, credentials, secrets) and its plugins with versions |
| `host/` | `daemon.json`, containerd's first lines, the systemd drop-ins, the SELinux rules, `cron.allow`, the crontab, permissions/ACLs/labels of the key folders, firewalld, addresses |
| `db/` | the newest MySQL dump |
| `MISSING.txt` | anything the script expected but didn't find |

**It holds passwords, tokens and keys.** Keep it as private as `.env`. Copy it off the server, for example to the Mac:
```bash
scp archive:/extra/eol_docker/snapshots/eol-archive_snapshot_YYYYMMDD_HHMM.tar.gz <a private folder>/
```
Make a new snapshot after any change to the settings, Jenkins' jobs or the host.

## 7. Rebuilding on another machine

1. **Follow `docs/deploy_day_checklist.md`**, steps 1–8, with these differences:
   - **Step 1:** use the new server's addresses, and check its umask (`umask`). With 0027, the ACL steps are needed as written.
   - **Step 3:** Jenkins' data comes from the snapshot instead of the Mac: `tar -xf jenkins/jenkins_home_config.tar -C /extra/eol_docker/jenkins_home`, then `jenkins/plugins_current.txt` as `plugins.txt`, then `chown -R 1000:1000`.
   - **Step 4:** start from `stack/.env` instead of the sample, and adjust the addresses (`WEB_HTTPS_PORTS`, `WEB_PORTS`, `HTTPS_ALSO_ALLOW`, `SELF_FETCH_IP`). Keep the passwords, or make new ones; with new ones, `database.yml` needs the new `MYSQL_PASSWORD`.
   - **Step 5:** take `database.yml` and `production.php` from `code_config/`. Recreate the links from `symlinks.txt`.
   - **Certificate:** copy `stack/certs/*` to `/extra/eol_docker/certs` (key mode 600), or let the web container make a new self-signed one.
   - **Step 6:** after the first start, load the newest dump from `db/` (the restore command in section 5). Jenkins keeps its users, token and jobs from the snapshot; the web-trigger token in `production.php` still matches.
   - **Step 8:** the crontab line and `/etc/cron.allow` as in `host/`.
2. **Host settings:** compare with `host/` (`daemon.json`, the systemd drop-ins, the SELinux rules).
3. **The data on `/extra`** isn't in the snapshot (3.8 TB). It moves with the volume, or is copied separately.
4. **Network team:** the firewall for 443, and Cloudflare's record pointing to the new public address.
5. **Check:** `bash scripts/rhel9-verify.sh` → `0 FAIL`.

## 8. Lessons from this deployment (details in the checklist and the RHEL guide)

- The server's umask 0027: every Dockerfile `COPY` sets `--chmod`; the webroot and data folders get ACLs for uids 33 and 1000.
- Millions of small files make `setfacl` and `restorecon` slow (about 60 files a second): the stack's folders first, the hashed caches on their folders only, the full relabel in the background. Long jobs run detached (`setsid nohup`) with a log, after `sudo -v` on its own.
- MySQL's first start takes minutes: the health check uses TCP and allows 10 minutes.
- Through Cloudflare, the server's own requests get 403: hence `SELF_FETCH_HOST` / `SELF_FETCH_IP`.
- Right after a restart, Jenkins needs 1–2 minutes before the check passes.
