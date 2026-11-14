# eol-archive: the current setup, and how to rebuild it

**As of 2026-11-12.** editors.eol.org runs on eol-archive since **2026-11-09** (DNS switch). The server check `scripts/rhel9-verify.sh` gives **84 OK, 0 WARN, 0 FAIL** (2026-11-11; 81 before the IP forwarding and internet access checks of 2026-11-10 and the `TERMS_MTCE_PASSWORD` check of 2026-11-11). Since 2026-11-14 it also checks `CROSSREF_MAILTO`, so expect **85 OK**.

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
| `…/eol_php8_code/config/environments/production.php` | code settings (`WEB_ROOT`, `JENKINS_DOMAIN`, `JENKINS_USER_TOKEN`, `TERMS_MTCE_PASSWORD`, `CROSSREF_MAILTO`, …) | no | **yes** |
| `…/eol_php8_code/applications/content_server/resources` | link to `/extra/eol_php_resources/` | no | the link |
| `…/FreshData_min/TSV_files` | link to `/extra/FreshData_TSV_files` | no | the link |
| `/extra/eol_docker/jenkins_home` | Jenkins: jobs, settings, users, credentials, secrets, plugins | no | **yes**, without build history, workspaces and plugin files (`plugins_current.txt` lists them) |
| `/extra/eol_docker/mysql_data` | MySQL's files | no | no: use the dump |
| `/extra/eol_docker/backups` | nightly MySQL dumps (newest 10) and `mysql-backup.log` | no | the newest dump |
| `/extra/eol_docker/certs` | HTTPS certificate and key (self-signed, 10 years) | no | **yes** |
| `/extra/eol_docker/apache2_logs` | Apache's access and error logs | no | no |
| `/extra/eol_docker/snapshots` | the snapshot archives | no | n/a |
| `/extra/dumps`, `eol_connector_data_files`, `ckan_resources`, `other_files`, `gnfinder`, `eol_php_resources`, `FreshData_TSV_files`, `eol_php_cache` | the data (about 3.8 TB) | no | no: it stays on `/extra` (the admins back up the server) |

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
- `TERMS_MTCE_PASSWORD` (added 2026-11-11, by hand on the server): the password for **[Upload to Zenodo]** on the Terms maintenance page, `applications/terms_maintenance/main.php`. Without it, uploading from that page is disabled. It's a page password only, not a Zenodo token. The `*_sample.php` files show the line, commented out.
- `CROSSREF_MAILTO` (added 2026-11-14): the contact email sent with every CrossRef call in the User-Agent (`FullReferenceSearchAPI.php`), as CrossRef asks. It puts our calls in CrossRef's "polite pool" (a higher rate limit). Without it, the calls still work at the public rate. Not a secret.

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
- ACLs for uid 33 (website) and uid 1000 (Jenkins), rwX with defaults, on: `dumps`, `eol_connector_data_files`, `ckan_resources`, `eol_php_resources` (incl. `cache`), `FreshData_TSV_files`, `gnfinder`, `other_files` (the 3 hashed caches on their folders only), `eol_php_cache`; read access on the webroot; rwX on the code's work folders; the deploying login can read `apache2_logs`
- `/etc/cron.allow` lists `eagbayani` (2026-11-10, with the admins' OK)
- crontab of `eagbayani`: `30 2 * * * cd /extra/eol_docker/docker_eol_connectors && bash scripts/mysql-backup.sh >> /extra/eol_docker/backups/mysql-backup.log 2>&1` (2:30 New York time)
- the host's own `httpd` disabled (if present)
- `/etc/sysctl.conf` line 54: `net.ipv4.ip_forward = 1` (changed by the network team on 2026-11-10, from the security baseline's `0`, rule `CCE-83998-5`, an approved exception; their comment above it unchanged). `/etc/sysctl.d/99-sysctl.conf` is a link to the same file. Docker needs it: see section 8
- firewalld `public` zone: `forward: no`, runtime and permanent (set by the network team on 2026-11-10, along with `ip_forward = 1`; it was `yes`). It blocks forwarding between `eno1` and `eno2`, so the server isn't a router between the internal and public networks. Docker's traffic (`public` ↔ `docker` zone, Docker's own rules) is unaffected: incoming 443 and the containers' downloads both work

**Front page** (in git, `apache-php/apache2.conf`, commit `81a8900`, live 2026-11-10): `https://editors.eol.org/` redirects (302) to the DwC-A validator, `/eol_php8_code/applications/dwc_validator/main.php`. Only the bare `/` is redirected; every other address is unchanged. The target is relative, so the visitor's scheme and host are kept (also on editors-test and the Mac). A 302 (temporary), so browsers don't remember it: to change or remove it, edit the `RedirectMatch` line, then rebuild web (section 5).

**Network team (outside the server):** firewall open for 443 to 160.111.248.39 (2026-11-06); Cloudflare's `editors.eol.org` record → 160.111.248.39, proxied (2026-11-09); test record `editors-test.eol.org` (to be removed by them); the old front device 160.111.248.42 is to be retired.

## 5. Routine operations (on eol-archive, in `/extra/eol_docker/docker_eol_connectors`)

| Task | Command |
|---|---|
| Check everything | `bash scripts/rhel9-verify.sh 2>&1 \| grep -E 'FAIL\|WARN\|Summary'` (wait 1–2 minutes after a restart) |
| State of the containers | `docker compose -f docker-compose.yml ps` |
| Logs | `docker compose -f docker-compose.yml logs --tail 50 web` (or `db`, `jenkins`); Apache: `/extra/eol_docker/apache2_logs/` |
| Database backup now | `bash scripts/mysql-backup.sh` (nightly at 2:30 anyway; newest 10 kept) |
| Restore the database | `gunzip -c /extra/eol_docker/backups/<file>.sql.gz \| docker compose -f docker-compose.yml exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot'` |
| Update the package | `git pull`, then `docker compose -f docker-compose.yml up -d`. A rebuild is needed if anything under `apache-php/` or `mysql/` changed (Dockerfiles, and the config files they copy into the image, e.g. `apache2.conf`): `docker compose -f docker-compose.yml build web` (or `db`), then `up -d web` (a few seconds' restart of that container only) |
| Update the PHP code | `cd /extra/eol_docker/webroot/eol_php8_code && git status --short && git pull --ff-only` as yourself, never with `sudo` (root-owned files break the website's and Jenkins' writes). Nothing to restart: PHP reads the new files on the next page load or job run |
| Test the site from the server | `curl -s -o /dev/null -w '%{http_code} %{redirect_url}\n' --resolve editors.eol.org:443:160.111.248.39 -k https://editors.eol.org/` → `302 …/dwc_validator/main.php`. HTTPS listens only on 160.111.248.39: `127.0.0.1` gives `000` (no connection), and through Cloudflare curl gets 403 |
| Change a setting in `.env` | edit `.env`, then `docker compose -f docker-compose.yml up -d` (recreates the containers that use it) |
| Snapshot of all settings | `sudo bash scripts/rhel9-snapshot.sh`, then copy it off the server (section 6) |

### After a server restart

The admins restart eol-archive now and then for system updates (2026-11-04, and 2026-11-09 at 14:16 New York time for a new kernel). **The stack needs nothing:** Docker starts after `/extra` is mounted, and the three containers come back by themselves (`restart: unless-stopped`). The nightly backup (crontab) and Jenkins' settings are unaffected.

**Will the containers come back after a reboot?** Yes, with no `docker compose` needed, because of two settings:
- **Docker starts at boot:** the `docker` service is enabled in systemd (`systemctl is-enabled docker` → `enabled`).
- **`restart: unless-stopped`** on each container: once Docker is up, it starts every container that was running before the reboot.

They **don't** come back by themselves in two cases:
- **Someone stopped them on purpose before the reboot,** with `docker compose stop` or `docker stop`. "Unless stopped" respects that. After `docker compose down` they are removed, so there's nothing to restart.
- **Docker itself doesn't start,** for example if it was disabled or broke in an OS upgrade.

Either way, start them with `cd /extra/eol_docker/docker_eol_connectors && docker compose up -d`. On 2026-11-09 the containers came back by themselves, and verify passed 81 OK.

1. **Did it restart, and cleanly?**
   ```bash
   uptime -s
   last -x reboot shutdown | head -4
   ```
2. **Check the stack:** wait 2 minutes after boot (Jenkins starts slowly), then:
   ```bash
   cd /extra/eol_docker/docker_eol_connectors
   docker compose -f docker-compose.yml ps --format '{{.Name}}  {{.Status}}'
   bash scripts/rhel9-verify.sh 2>&1 | grep -E 'FAIL|WARN|Summary'
   ```
   → all three `Up`, db `(healthy)`, `0 FAIL`.
3. **Long background jobs started by hand stop at a restart.** That means `setfacl`, `restorecon`, `find -delete` and `rm -rf` runs, even when detached with `setsid nohup`. A job whose log has no `ALL FINISHED`, and has no process in `pgrep -a -x 'find|rm|restorecon|setfacl' | cut -c1-80`, was stopped. Restart it the same way, with `sudo -v` first. Each continues with what's left:
   - **Deleting** (`find … -mindepth 1 -delete`, `rm -rf` of a list): the same command finds only what's still there. Rebuild a list from the current state, not the old list.
   - **Relabelling:** don't run `restorecon -R /extra` again from the start. Rebuild the list from the current labels: folders the run hadn't reached still carry an old label, **`unlabeled_t` or `default_t`** (check for both), at each level the run was inside:
     ```bash
     for d in /extra/*/ /extra/other_files/*/ /extra/other_files/GBIF_occurrence/*/; do ls -Zd "$d"; done 2>/dev/null \
       | grep -E 'unlabeled_t|default_t' | awk '{print $2}' | sed 's#/$##' > /tmp/relabel_list.txt
     ```
     Add the folder it was working in when it stopped: that folder's own label is new, but not all of its contents. Then run `restorecon -R` on each path in the list, detached, with a log.
   - **`setfacl`:** redo the folders whose log has no `done:` line; redoing a folder is harmless.

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
- SELinux's old labels come in two kinds on this volume: `default_t` and `unlabeled_t`. A check for unlabelled folders must look for both (on 2026-11-08 only `default_t` was checked, and 31 folders in `other_files` were missed).
- A server restart stops long background jobs, but not the stack: restart the jobs from the current state (section 5, *After a server restart*).
- Long pastes through the two SSH hops can arrive garbled. Paste long commands in short pieces, and run `sudo -v` on its own first.
- **Docker needs IP forwarding on (`net.ipv4.ip_forward = 1`), and the RHEL security baseline turns it off** (rule `CCE-83998-5` in `/etc/sysctl.conf`). On 2026-11-10 the site was down from about 06:20 to 07:50 New York time. Docker had switched forwarding on at the 04:45 restart, and a re-apply of the baseline around 06:17 switched it off again. The network team then set it to `1` in `/etc/sysctl.conf`, and the `public` zone to `forward: no` (section 4). It's an **approved exception** to `CCE-83998-5` for eol-archive, and no Ansible playbook re-applies the baseline periodically (Tom, 2026-11-10). The 06:17 switch-off was probably a one-off re-apply; with the file at `1`, a re-apply keeps it on. Forwarding carries the visitors' traffic to the web container and the containers' own downloads, so with it off, both stop.
  - **How it looks:**
    - Cloudflare shows **error 525** (SSL handshake failed).
    - Apache's access log has no visitor requests.
    - From the server itself, HTTPS works, and `rhel9-verify.sh` passed, because local requests don't need forwarding. It now checks forwarding and the containers' internet access directly.
    - From outside, the connection is reset after the TLS hello.
  - **Check:** `sysctl net.ipv4.ip_forward` → `1`. Containers' downloads: `docker exec docker_eol_connectors-jenkins-1 curl -s -m 10 -o /dev/null -w '%{http_code}\n' https://github.com` → `200`. With `0`, `sudo tcpdump -ni any 'tcp port 443'` shows `SYN`s arriving on `eno2` with no reply, and the `dnat to 10.10.0.x:443` counter in `sudo nft list ruleset` rises while the forward `accept` counter doesn't.
  - **Fix:** `/etc/sysctl.conf` belongs to the admins' baseline. Ask them; don't override it. `sudo sysctl -w net.ipv4.ip_forward=1` works at once and changes no file, but only with their OK.
- Apache's log times are UTC; the server's (`date`, `uptime`, the job logs) are New York time.
