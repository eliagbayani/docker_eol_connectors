# Deployment day: eol-archive (RHEL 9.8)

The short version of `docs/rhel9_production_env_guide.md` (deploy steps 1–8). Each step lists the commands, what you should see, and where to **STOP** if it doesn't match.

- **Server:** eol-archive, RHEL 9.8, SELinux Enforcing. Root disk 10 GB, about 8.6 GB of it used by the admins' own tools (NetBackup, SentinelOne, Splunk); data volume `/extra` 9.1 TB (kept from the old server). The default umask is **0027** (new files 640, folders 750), so the containers' users can't read what you create unless a step gives them access.
- **Layout:** everything under `/extra`: Docker in `/extra/docker` and `/extra/containerd`, the stack in `/extra/eol_docker`, data in `/extra` as before.
- **Who:** your own login. Use `sudo` only where shown. No root shell (`sudo su`): in a root shell `~` is `/root`, and files get the wrong owner.
- **Time:** a full day. On 2026-11-07 most of it went to step 3 (permissions and SELinux labels on millions of small files, at about 60 files a second). The parts the stack needs first are done in minutes; the rest runs in the background, detached, and doesn't block steps 4–8.

## For the admins: what this deployment changes on the server

The EOL tools (website, MySQL and Jenkins) run as three Docker containers. Changes to eol-archive (10.252.248.39 / 160.111.248.39), by area:

| Area | Change | Step |
|---|---|---|
| **Packages** | Docker's repository (`download.docker.com/linux/rhel`) added; `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-compose-plugin` and `policycoreutils-python-utils` installed; `podman-docker` / `buildah` removed if present | 1 |
| **Services** | `docker` (and `containerd`) enabled at boot, and wait for the `/extra` mount (drop-ins in `/etc/systemd/system/{docker,containerd}.service.d/extra.conf`). The host's own `httpd` is disabled if present | 1, 7 |
| **System files** | `/etc/docker/daemon.json` (`data-root` = `/extra/docker`; Docker's internal networks: `bip` `10.10.1.1/24` and the address pool `10.10.2.0/16`, as the network team recommended; Docker reads a /16 from its start, so the pool is `10.10.0.0/16` and the stack's network comes out as e.g. `10.10.0.0/24`); one line at the top of `/etc/containerd/config.toml` (`root = "/extra/containerd"`), both checked in step 1. The 10 GB root disk stays essentially unchanged | 1, 6 |
| **SELinux** (stays Enforcing) | persistent rules: `/extra(/.*)?` → `container_file_t`; `/extra/docker` and `/extra/containerd` labelled like `/var/lib/docker` and `/var/lib/containerd`. A one-time `restorecon -R /extra` (3.8 TB) relabels the existing data from `default_t` | 1, 3 |
| **`/extra`** | new folders `docker/`, `containerd/`, `eol_docker/` (mode 700, owned by the deploying login; it holds `certs/`, the website's HTTPS certificate) and `gnfinder/`. ACLs on `dumps`, `eol_connector_data_files`, `ckan_resources`, `eol_php_resources`, `FreshData_TSV_files`, `other_files` and `gnfinder` give uid 33 (website) and uid 1000 (Jenkins) write access. **Existing data, owners and modes are not changed** | 1, 3 |
| **Network: listening** | **`160.111.248.39:443`**: the website over HTTPS, for Cloudflare. HTTPS ends in the web container (the front device 160.111.248.42 is being retired). Port 443 accepts only Cloudflare's published ranges, plus the server itself for tests; others get 403. The certificate is self-signed (`/extra/eol_docker/certs`), which Cloudflare's SSL mode *Full* accepts; for *Full (strict)* a Cloudflare Origin certificate replaces the 2 files, no rebuild. **`10.252.248.39:8080`**: plain HTTP on the internal address, as the old Apache listened (for .42 while it still forwards, and internal tests). `127.0.0.1:8080` (Jenkins) and `127.0.0.1:4001` (MySQL): local only, reached through SSH. Docker adds its own nftables rules for the published ports; firewalld isn't changed | 6 |
| **Firewall and DNS (network team)** | Cloudflare reaches 160.111.248.39 on 443 (the network team's firewall change, done 2026-11-06; open to all for now, maybe Cloudflare only after the switch), then Cloudflare's record for `editors.eol.org` moves from 160.111.248.42 to **160.111.248.39**. Until then, the site works through .42 as today (→ `10.252.248.39:8080`). To roll back: point the record back to .42 | Go-live |
| **Network: outgoing** (HTTPS, during the build and plugin install) | Docker Hub (base images `php`, `jenkins/jenkins`, `mysql`), `deb.debian.org` and `packages.sury.org` (PHP), `github.com` (code, gnparser), `updates.jenkins.io` and its download mirrors (`get.jenkins.io`, `mirrors.jenkins-ci.org` and others; Jenkins plugins) | 2, 5, 6 |
| **Users and groups** | the deploying login joins the `docker` group (**equivalent to root**, as for any Docker host). No new system users. Inside the containers, the website runs as uid 33 and Jenkins as uid 1000 | 1 |
| **Cron** | one line in the deploying login's crontab: a nightly MySQL dump at 2:30 into `/extra/eol_docker/backups` (10 kept). On eol-archive, crontab is limited to listed users (`/etc/cron.allow`): the admins add the deploying login | 8 |

Before you start:
- [ ] The Mac's repo, `eol_php8_code`, `FreshData_min` and `LiteratureEditor_min` are pushed to GitHub.
- [ ] Nothing to prepare for passwords: step 4 makes new ones on the server with `openssl rand -hex 24`. Never reuse old ones.

### Before deployment: the network path

After the DNS switch, visitors reach the site like this: Cloudflare (HTTPS, proxied) → eol-archive **160.111.248.39:443** (HTTPS ends in the web container). The network team's answer (2026-11-05): the front device 160.111.248.42 (eol-datastore1) is being retired, so HTTPS has to end on eol-archive, and they move Cloudflare's DNS record from .42 to .39 once the site runs here. Until then the old path (Cloudflare → .42 → `10.252.248.39:8080`) still works, so `WEB_PORTS=10.252.248.39:8080:80` stays.

The `.env` settings this depends on (all in the production sample): `WEB_HTTPS_PORTS=160.111.248.39:443:443`, `HTTPS_CERTS_PATH=/extra/eol_docker/certs` and `HTTPS_ALSO_ALLOW` (the server's own addresses, for the tests below). Visitor IPs come from `X-Forwarded-For`, believed only from Cloudflare's ranges (and from .42).

- [x] **Both addresses survived the rebuild** (checked 2026-11-05):
  ```bash
  ip -4 addr show | grep -E 'inet (10\.252\.248\.39|160\.111\.248\.39)'
  ```
  → `10.252.248.39/24` on `eno1` (internal) and `160.111.248.39/24` on `eno2` (public). The public address sits directly on the server, and Docker bypasses firewalld. That's why every published port names its address (`0.0.0.0` would publish on all of them), and why Apache itself turns away anyone on 443 who isn't Cloudflare.
- [x] **The network team answered** (2026-11-05): .42 goes away, HTTPS ends on .39, and they change the DNS record once things are up and running. Their Varnish and ssl-terminator containers on .42 aren't needed on eol-archive (the web container ends HTTPS itself). They confirmed the order: deploy (the site works through .42 meanwhile) → their firewall change → we test 443 → their DNS switch.
- [x] **The network team opened the firewall** (2026-11-06): Cloudflare can reach 160.111.248.39 on 443. For now it allows all traffic; they may tighten it to Cloudflare only after the switch. Either way the site is safe: Apache itself lets only Cloudflare (and the server) in on 443, and everyone else gets 403.
- [x] **The DNS switch** (2026-11-09): the network team pointed `editors.eol.org` to 160.111.248.39. The log shows real visitor IPs (IPv4 and IPv6) on 443 right after, and no new lines from the old route through .42.
- [x] **Cloudflare's SSL mode is *Full*** (read from Cloudflare's settings, 2026-10-26), so the self-signed certificate works. If it's *Full (strict)*, Cloudflare shows error **526** after the DNS switch: ask the network team for a Cloudflare Origin certificate and swap it in (*If something goes wrong*, below).

---

## 1. Docker, with its storage on `/extra`

**This step installs Docker, the container runtime, on eol-archive. Nothing else gets installed on the server itself.** PHP, Apache, MySQL and Jenkins come inside the three containers (web, db, jenkins), which are built in step 6. After this step the server has Docker, with its storage on `/extra`, starting at boot.

First, check that you're in your own login, not a root shell (`sudo su` / `sudo -i`). The `$USER` in this step and in steps 2, 3 and 5 must be you:

```bash
echo $USER
```

- [ ] It prints **your login name**. If it prints `root`, type `exit` until it prints your name. **STOP and fix it before proceeding.**

```bash
# 1. Remove Podman's docker look-alike and buildah if present (they clash with the real Docker; harmless if absent)
sudo dnf remove -y podman-docker buildah 2>/dev/null || true

# 2. Add Docker's official package source for RHEL (RHEL itself doesn't include Docker)
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# 3. Install the runtime: the engine (docker-ce), the docker command (docker-ce-cli),
#    the layer that runs the containers (containerd.io) and `docker compose` (docker-compose-plugin).
#    policycoreutils-python-utils isn't Docker: it gives `semanage`, used below for SELinux.
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin policycoreutils-python-utils

# 4. Docker's settings: its storage on /extra (the 10 GB system disk is too small), and its internal networks
#    on 10.10.x.x, as the network team recommends (instead of Docker's default 172.17-172.31 ranges);
#    then containerd's storage on /extra too
sudo mkdir -p /etc/docker /extra/docker /extra/containerd
echo '{ "data-root": "/extra/docker", "bip": "10.10.1.1/24", "default-address-pools": [ { "base": "10.10.2.0/16", "size": 24 } ] }' | sudo tee /etc/docker/daemon.json
sudo sed -i '1i root = "/extra/containerd"' /etc/containerd/config.toml

# 5. SELinux: label the new storage folders like Docker's default ones
sudo semanage fcontext -a -e /var/lib/docker /extra/docker
sudo semanage fcontext -a -e /var/lib/containerd /extra/containerd
sudo restorecon -R /extra/docker /extra/containerd
sudo systemctl restart containerd

# 6. At boot, start Docker and containerd only after /extra is mounted
sudo mkdir -p /etc/systemd/system/docker.service.d /etc/systemd/system/containerd.service.d
printf '[Unit]\nRequiresMountsFor=/extra\n' | sudo tee /etc/systemd/system/docker.service.d/extra.conf
sudo cp /etc/systemd/system/docker.service.d/extra.conf /etc/systemd/system/containerd.service.d/
sudo systemctl daemon-reload

# 7. Start Docker now and at every boot
sudo systemctl enable --now docker

# 8. Check where the storage went, and Docker's network (see the checks below)
sudo docker info -f '{{.DockerRootDir}}'
sudo containerd config dump | grep -m1 '^root'
ip -4 addr show docker0 | grep inet

# 9. Let your login run docker without sudo (takes effect after you log in again)
sudo usermod -aG docker $USER
```

- [ ] **Check that Docker uses `/extra`:** `docker info` prints **`/extra/docker`**. If it prints `/var/lib/docker` (Docker's default), the `daemon.json` setting didn't take effect. **STOP and fix it before proceeding.**
- [ ] **Check that containerd uses `/extra`:** the `grep` prints **`root = '/extra/containerd'`** (a warning line before it, "Configuration migrated from version 0", is normal). If it prints `/var/lib/containerd` (containerd's default), the `config.toml` line didn't take effect. **STOP and fix it before proceeding.**
- [ ] **Check Docker's network:** `ip … docker0` shows **`inet 10.10.1.1/24`**. If it shows `172.17.0.1/16` (Docker's default), the network part of `daemon.json` didn't take effect. **STOP and fix it before proceeding.**
- [ ] **Log out and back in** (for the `docker` group), then `docker ps` works without `sudo`.

## 2. The Docker package

**This step puts our Docker package (`docker-compose.yml`, the Dockerfiles, the scripts) on the server**, in `/extra/eol_docker`. That folder will hold everything that belongs to the stack: the package, the code, MySQL's data, Jenkins' data, logs and backups. It's locked to your login (mode 700), so the containers can't read the settings file or Jenkins' secrets through `/extra`.

```bash
# 1. Create the stack's folder, owned by you and closed to everyone else
sudo mkdir -p /extra/eol_docker && sudo chown $USER: /extra/eol_docker
chmod 700 /extra/eol_docker

# 2. Download the Docker package from GitHub and go into it
git clone https://github.com/eliagbayani/docker_eol_connectors.git /extra/eol_docker/docker_eol_connectors
cd /extra/eol_docker/docker_eol_connectors
```

- [ ] `git log --oneline -1` shows the Mac's latest commit.

## 3. Folders, Jenkins data, permissions, SELinux

**This step prepares the folders the containers use, brings Jenkins' data over from the Mac, and gives the containers access to the data on `/extra`.** The website runs as uid 33 and Jenkins as uid 1000 inside their containers, so they get write access (ACLs) to the data folders they write to. The existing owners and files stay as they are. SELinux stays on: `/extra` gets a label that lets containers use it.

```bash
# 1. Create the stack's folders under /extra/eol_docker (only the missing ones; existing data folders are left alone)
sudo bash scripts/rhel9-init-dirs.sh

# 2. Jenkins' folder belongs to you for now, so the copy from the Mac (below) can write into it
sudo chown $USER: /extra/eol_docker/jenkins_home
```

- [ ] The output shows `exists:` for `ckan_resources`, `eol_connector_data_files`, `dumps`, `other_files`, `eol_php_resources` and `FreshData_TSV_files`, `created:` for `gnfinder` and `certs`, and `acl: …/apache2_logs readable by` your login (so you can `tail` the web logs). **STOP** if `dumps` or `ckan_resources` say `created`: `/extra` isn't the data volume (`findmnt /extra`).

**On the Mac**, with Jenkins stopped, copy Jenkins' **jobs, settings, users and secrets** (about 20 MB). The build history (1.55 GB) and the plugins aren't copied. **The Neo4j jobs aren't copied either** (the folders `00 Neo4j_PHP_connectors`, `00 Neo4j_Python_connectors` and `01 Neo4j_PHP_connectors`): eol-archive has no Neo4j, so they stay on the Mac. Instead, a list of the 94 plugins with their exact versions goes along as `plugins.txt`, and step 6 installs them.

```bash
# 1. Stop the Mac's Jenkins, so nothing changes during the copy (and its timed jobs stop running)
cd /Volumes/OWC_Express/other_files/My_Docker/docker_eol_connectors && docker compose stop jenkins

# 2. Make the plugin list: one "name:version" line per installed plugin
JH=/Volumes/OWC_Express/other_files/My_Docker_content/jenkins_home
for m in $JH/plugins/*/META-INF/MANIFEST.MF; do
  awk -F': ' '/^Short-Name:/ { n = $2 } /^Plugin-Version:/ { v = $2 } END { gsub(/\r/, "", n); gsub(/\r/, "", v); print n ":" v }' "$m"
done > /tmp/jenkins_plugins.txt
wc -l < /tmp/jenkins_plugins.txt

# 3. Copy jobs, settings, users and secrets to the server (no build history, plugins, logs, caches or Neo4j jobs)
rsync -a --exclude='builds/' --exclude='lastStable' --exclude='lastSuccessful' --exclude='/plugins/' --exclude='/war/' \
  --exclude='/logs/' --exclude='/updates/' --exclude='/workspace/' --exclude='/.cache/' --exclude='/.java/' --exclude='/.local/' \
  --exclude='.DS_Store' --exclude='.bash_history' --exclude='/jobs/*Neo4j_P*/' "$JH/" archive:/extra/eol_docker/jenkins_home/

# 4. Copy the plugin list next to it
rsync -a /tmp/jenkins_plugins.txt archive:/extra/eol_docker/jenkins_home/plugins.txt
```

- [ ] `wc -l` prints **94** (one line per plugin, e.g. `matrix-auth:3.3`).
- [ ] **The timed jobs stay on the Mac** (decided 2026-11-08). 21 of the copied jobs run on a timer (e.g. *Zenodo monthly stats*, the GBIF download requests, the *Routine Utilities*). Two machines must not run them both, so after step 6 remove their timers on the server (Script Console, step 6). Until then, keep the Mac's Jenkins stopped.

**Back on the server:**

```bash
cd /extra/eol_docker/docker_eol_connectors

# 1. Check the GBIF download jobs use eol-archive's folder (/extra/other_files/GBIF_occurrence/, same path as on the Mac)
grep -rh --include=config.xml -e '^cd /Volumes' -e '<command>cd /extra/other_files/GBIF_occurrence/' /extra/eol_docker/jenkins_home/jobs | sed 's/^ *//'

# 2. Hand Jenkins' folders to Jenkins (uid 1000 in its container), and the code folder to you
sudo chown -R 1000:1000 /extra/eol_docker/jenkins_home /extra/eol_docker/jenkins_tmp
sudo chown $USER: /extra/eol_docker/webroot

# 3. Give the website (33) and Jenkins (1000) write access to the data folders, now and for new files (owners unchanged).
#    Runs in the background, detached from the window (setsid nohup), one folder at a time, with a log. sudo -v first,
#    so the background sudo doesn't need to ask for the password. The 3 hashed caches (over 100 million small files
#    in 2 levels of folders) get it on their folders only: new files inherit it, and deleting old ones needs only
#    the folder. Done file by file, they would take weeks. other_files goes last: it still takes hours.
sudo -v
cd /extra && sudo setsid nohup bash -c 'A="u:33:rwX,u:1000:rwX"; D="d:u:33:rwX,d:u:1000:rwX"
C="other_files/GBIF_occurrence/multimedia_gbifID other_files/GBIF_occurrence/GBIF_taxa_csv_dwca other_files/iNat_image_DwCA/cache_image_score"
echo "start: caches (folders only) $(date +%T)"
for c in $C; do if [ -d "$c" ]; then find "$c" -maxdepth 2 -type d -exec setfacl -m "$A,$D" {} + || echo "ERROR: $c"; fi; done; echo "done:  caches $(date +%T)"
for d in dumps eol_connector_data_files ckan_resources eol_php_resources FreshData_TSV_files gnfinder other_files; do
  echo "start: $d $(date +%T)"
  find "$d" \( -path other_files/GBIF_occurrence/multimedia_gbifID -o -path other_files/GBIF_occurrence/GBIF_taxa_csv_dwca \
    -o -path other_files/iNat_image_DwCA/cache_image_score \) -prune -o -type d -exec setfacl -m "$A,$D" {} + -o -type f -exec setfacl -m "$A" {} + \
    && echo "done:  $d $(date +%T)" || echo "ERROR: $d $(date +%T)"
done; echo ALL FINISHED' > /tmp/setfacl.log 2>&1 < /dev/null &
cd /extra/eol_docker/docker_eol_connectors
sleep 3; cat /tmp/setfacl.log; pgrep -x setfacl

# 4. The GBIF jobs' download folder: create it if eol-archive doesn't have it (it inherits the write access from step 3)
ls -ld /extra/other_files/GBIF_occurrence || sudo mkdir /extra/other_files/GBIF_occurrence

# 5. SELinux: a rule that labels all of /extra for container use, then check the rule
sudo semanage fcontext -a -t container_file_t "/extra(/.*)?"
matchpathcon /extra/eol_php_resources /extra/docker /extra/containerd

# 6. Apply the labels, in the background, detached from the window. First the folders the stack uses (minutes),
#    and other_files without the 3 hashed caches (on 2026-11-08, 13 of its folders were still unlabelled while the full run
#    sat in the GBIF image cache); then all of /extra (3.8 TB: weeks on this disk, for the caches; it doesn't block anything).
#    Both can run alongside part 3. Until the full run reaches them, jobs can't read the caches' old files (new ones are fine).
sudo -v
sudo setsid nohup bash -c 'for d in /extra/eol_docker /extra/dumps /extra/ckan_resources /extra/eol_connector_data_files \
    /extra/eol_php_resources /extra/FreshData_TSV_files /extra/gnfinder; do
  echo "start: $d $(date +%T)"
  restorecon -R "$d" && echo "done:  $d $(date +%T)" || echo "ERROR: $d $(date +%T)"
done
echo "start: other_files without the 3 hashed caches $(date +%T)"
restorecon -R -e /extra/other_files/GBIF_occurrence/multimedia_gbifID -e /extra/other_files/GBIF_occurrence/GBIF_taxa_csv_dwca \
  -e /extra/other_files/iNat_image_DwCA/cache_image_score /extra/other_files \
  && echo "done:  other_files $(date +%T)" || echo "ERROR: other_files $(date +%T)"
echo ALL FINISHED' > /tmp/restorecon-stack.log 2>&1 < /dev/null &
sudo setsid nohup restorecon -R /extra > /tmp/restorecon.log 2>&1 < /dev/null &
```

- [ ] `find /extra/eol_docker/jenkins_home/jobs -name config.xml | wc -l` shows **277** (40 folders + 237 jobs; the Mac's 443 minus the 166 Neo4j ones), `ls /extra/eol_docker/jenkins_home/jobs | grep -c Neo4j` prints **0**, and `/extra/eol_docker/jenkins_home/plugins.txt` exists.
- [ ] The GBIF `grep` prints exactly **4 lines**, all `<command>cd /extra/other_files/GBIF_occurrence/…` (National, Countries, Waterbody and Continent), and **no** `cd /Volumes` line. **STOP and fix it before proceeding** if a `cd /Volumes` line shows up: that job would fail on the server (the Mac's Jenkins needs the same fix, then copy again).
- [ ] `ls -ld /extra/other_files/GBIF_occurrence` shows a folder (or, if it was missing, the `mkdir` created it; `getfacl /extra/other_files/GBIF_occurrence` then shows `user:33:rwx` and `user:1000:rwx`).
- [ ] `matchpathcon` prints `container_file_t` for `eol_php_resources` and `container_var_lib_t` for both `docker` and `containerd`. **STOP** if `/extra/docker` shows `container_file_t`.
- [ ] `setfacl` and the relabels run in the background, detached: closing the window or a dropped connection doesn't stop them. Steps 4 and 5 can be done meanwhile. **Before step 6, wait until `/tmp/restorecon-stack.log` ends with `ALL FINISHED`, and `/tmp/setfacl.log` has a `done:` line for every folder before `other_files` (no `ERROR` line).** `other_files` and the full `restorecon -R /extra` may still be running: the stack starts without them, and Jenkins jobs that write into a part of `other_files` not reached yet fail with *Permission denied* until it's done. Check them with `tail -n 2 /tmp/setfacl.log; pgrep -x setfacl; pgrep -x restorecon` (not `pgrep -a`: it prints thousands of file names). If `setfacl` stopped early, run part 3 again with only the folders not done; redoing a folder is harmless. If the log was lost, `getfacl -p /extra/gnfinder | grep user:33` shows whether a folder was reached.

## 4. Settings (`.env`)

**This step makes the stack's settings file, `.env`.** It holds the database passwords and says which address and port each container listens on, and where on `/extra` its data lives. It starts as a copy of the production sample, and only the passwords change.

Each `openssl rand -hex 24` gives a new random 48-character password, written straight into `.env`. Nothing is shown on screen.

```bash
cd /extra/eol_docker/docker_eol_connectors

# 1. Start from the production sample; only you can read the file
cp .env.production.sample .env && chmod 600 .env

# 2. Replace each CHANGE_ME with a new random password
sed -i "s/^MYSQL_ROOT_PASSWORD=CHANGE_ME.*/MYSQL_ROOT_PASSWORD=$(openssl rand -hex 24)/" .env
sed -i "s/^MYSQL_PASSWORD=CHANGE_ME.*/MYSQL_PASSWORD=$(openssl rand -hex 24)/" .env

# 3. Check: no CHANGE_ME left, each password 48 characters (lengths only, never the passwords)
grep -v '^\s*#' .env | grep -c CHANGE_ME
grep -E '^(MYSQL_ROOT_PASSWORD|MYSQL_PASSWORD)=' .env | awk -F= '{ print $1, length($2), "chars" }'

# 4. Check the addresses and ports the containers listen on, and the HTTPS settings
grep -E '^(WEB_HTTPS_PORTS|WEB_PORTS|JENKINS_PORTS|MYSQL_PORTS|HTTPS_CERTS_PATH|HTTPS_ALSO_ALLOW|SELF_FETCH_HOST|SELF_FETCH_IP)=' .env
```

- [ ] `grep -c` prints **0**, and the last command prints the two names with **48 chars** each (the passwords themselves aren't shown).
- [ ] The ports are **`WEB_HTTPS_PORTS=160.111.248.39:443:443`**, **`WEB_PORTS=10.252.248.39:8080:80`**, `JENKINS_PORTS=127.0.0.1:8080:8080` and `MYSQL_PORTS=127.0.0.1:4001:3306`. **STOP** if a port has no address in front (e.g. `443:443` or `80:80`): it would be published on every address of the server.
- [ ] `HTTPS_CERTS_PATH=/extra/eol_docker/certs` and `HTTPS_ALSO_ALLOW=127.0.0.1 10.10.0.0/16 160.111.248.39 10.252.248.39`. `SELF_FETCH_HOST=editors.eol.org` and `SELF_FETCH_IP=160.111.248.39`: inside the containers, the code's requests to its own site go straight to this server, because through Cloudflare they get 403 (its bot check). Leave the paths as they are in the sample.
- To see a password later (e.g. to log in to MySQL by hand): `grep '^MYSQL_ROOT_PASSWORD=' .env`. Don't paste it anywhere.

## 5. Code, work folders, config files

**This step puts the PHP code on the server**, in `/extra/eol_docker/webroot`. The web and jenkins containers both use this folder (as `/var/www/html`). Git doesn't save the code's work folders or its private config files, so this step creates the folders and copies the config files from the Mac. Without them, jobs fail quietly while Jenkins still says "success".

```bash
# 1. Download the three code repos from GitHub
cd /extra/eol_docker/webroot
git clone https://github.com/eliagbayani/eol_php8_code.git
git clone https://github.com/eliagbayani/FreshData_min.git
git clone https://github.com/eliagbayani/LiteratureEditor_min.git
# The server's umask 0027 makes the code 640/750: let the website (33) and Jenkins (1000) read it, now and for new files
setfacl -R -m u:33:rX,u:1000:rX,d:u:33:rX,d:u:1000:rX /extra/eol_docker/webroot
cd /extra/eol_docker/webroot/eol_php8_code

# 2. Create the work folders git doesn't save (temp and cache folders, the web tools' upload folders)
mkdir -p temp tmp/cache applications/content_server/tmp \
  applications/{BOLD2iNAT,BOLD2iNAT_csv,branch_graft,specimen_image_export,taxonomic_validation,trait_data_import,xls2dwca_jenkins}/temp \
  applications/{dwc_validator_jenkins,DwC_branch_extractor,genHigherClass,genHigherClass_jenkins,CheckListBank_tool}/temp \
  ../FreshData_min/sh_files

# 3. Link the two folders that hold existing data on /extra
ln -s /extra/eol_php_resources/ applications/content_server/resources
ln -s /extra/FreshData_TSV_files ../FreshData_min/TSV_files

# 4. Let the website and Jenkins write into the work folders and the GBIF download folder
chmod 777 temp tmp/cache applications/content_server/tmp applications/*/temp ../FreshData_min/sh_files
setfacl -R -m u:33:rwX,u:1000:rwX,d:u:33:rwX,d:u:1000:rwX update_resources/connectors/files

# 5. Check: the code is unchanged from GitHub, and both links point to real folders
git status --short | wc -l
ls -ld /extra/eol_php_resources/ /extra/FreshData_TSV_files/
```

- [ ] `git status` gives **0**, and both `ls -ld` lines show real folders.

**On the Mac**, copy the 2 config files that aren't in git: `database.yml` (the database logins) and `environments/production.php` (the code's settings). The website and every Jenkins job use the same two: `production.php` and the `production:` section of `database.yml`.

```bash
# database.yml: database connections; production.php: the code's settings (e.g. how the web tools reach Jenkins)
cd /Volumes/OWC_Express/other_files/My_Docker_content/webroot/eol_php8_code/config
scp database.yml archive:/extra/eol_docker/webroot/eol_php8_code/config/
scp environments/production.php archive:/extra/eol_docker/webroot/eol_php8_code/config/environments/
```

**On the server:**

```bash
cd /extra/eol_docker/webroot/eol_php8_code/config

# 1. Put the new database password from .env into database.yml, without showing it:
#    the production: section (used by the website and by Jenkins jobs) gets the MYSQL_PASSWORD from .env;
#    the Mac's sections (development:, test:) get an empty password
P=$(grep '^MYSQL_PASSWORD=' /extra/eol_docker/docker_eol_connectors/.env | cut -d= -f2)
awk -v p="$P" '/^[a-z_]+:[[:space:]]*$/ { s = $1 }
  /^[[:space:]]+password:/ { if (s == "production:") sub(/password:.*/, "password: \"" p "\""); else sub(/password:.*/, "password: \"\"") }
  { print }' database.yml > database.yml.new && mv database.yml.new database.yml
grep -cF "\"$P\"" database.yml; unset P

# 2. Close the config files to other users
chmod 640 database.yml environments/production.php
ls environments/

# 3. Check the production section connects to the db container as eol_app
grep -A4 '^production:' database.yml | grep -E '^\s+(host|username):'
```

- [ ] `ls environments/` shows `production.php` next to the three files from git (`development_sample.php`, `production_sample.php`, `test_sample.php`), and nothing else.
- [ ] `grep -cF` prints **1** (the production section has the password), and the last command shows `host: db` and `username: eol_app`.
- [ ] `production.php` has `JENKINS_DOMAIN` set to `jenkins:8080`, and **`WEB_ROOT` set to `https://editors.eol.org/eol_php8_code/`** (the Mac's copy has `http://host.docker.internal:81/…`, which only works on the Mac: the web tools' download links would be broken). Change it on the server only:
  ```bash
  sed -i "s|^define('WEB_ROOT', 'http://host.docker.internal:81/eol_php8_code/');|define('WEB_ROOT', 'https://editors.eol.org/eol_php8_code/');|" environments/production.php
  grep -n "^define('WEB_ROOT'" environments/production.php
  ```
  The token is replaced after step 6.

## 6. Build, start, check

**This step builds the three containers and starts them.** The build downloads the base images and installs PHP 8.4 and the tools in the web and jenkins images, and Apache in the web image (this takes a while). Jenkins' plugins are installed from the list before its first start. At its first start the web container makes a self-signed HTTPS certificate in `/extra/eol_docker/certs`. Then the server check (`rhel9-verify.sh`) tests everything: containers, folders, permissions, SELinux, ports, HTTPS, database and Jenkins.

```bash
cd /extra/eol_docker/docker_eol_connectors

# 1. The stack's relabel from step 3 must be finished (the full /extra one may still run)
tail -n 1 /tmp/restorecon-stack.log

# 2. Build the images from scratch, with fresh base images; keep the log
docker compose -f docker-compose.yml build --no-cache --pull 2>&1 | tee /tmp/build.log | tail -3
grep -m1 "PHP 8.4" /tmp/build.log

# 3. Check the images went to /extra, not the 10 GB system disk
df -h /
sudo du -sh /var/lib/docker /var/lib/containerd 2>/dev/null

# 4. Jenkins' plugins, from the list copied in step 3 (needs HTTPS to updates.jenkins.io; about 3 minutes)
docker compose -f docker-compose.yml run --rm --no-deps --entrypoint jenkins-plugin-cli jenkins \
  --plugin-file /var/jenkins_home/plugins.txt --plugin-download-directory /var/jenkins_home/plugins 2>&1 | tail -3
ls /extra/eol_docker/jenkins_home/plugins/*.jpi | wc -l

# 5. Start web, db and jenkins (they also start again at every boot), and show their state.
#    The first start waits a few minutes for MySQL to set up its new database (db "health: starting");
#    web and jenkins start once it's healthy.
docker compose -f docker-compose.yml up -d
docker compose -f docker-compose.yml ps
docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' docker_eol_connectors_default
docker compose -f docker-compose.yml logs web | grep 'HTTPS certificate'

# 6. The server check
bash scripts/rhel9-verify.sh
```

- [ ] `restorecon-stack.log` ends with `ALL FINISHED`. The build log shows **`PHP 8.4.27`** (or newer). `df -h /` hasn't grown since before the build (on eol-archive about 8.6 GB of 10 GB, all the admins' tools), and `du` shows `/var/lib/docker` and `/var/lib/containerd` as absent or tiny (the images are under `/extra`).
- [ ] The plugin tool ends with `Done`, and `ls … | wc -l` prints **94**. **STOP** if it's fewer, or the tool can't reach `updates.jenkins.io`: Jenkins can't read its security settings or folders without them. Run the command again (it retries mirrors), or copy the plugins from the Mac instead: `rsync -a /Volumes/OWC_Express/other_files/My_Docker_content/jenkins_home/plugins/ archive:/extra/eol_docker/jenkins_home/plugins/`, then `sudo chown -R 1000:1000 /extra/eol_docker/jenkins_home/plugins`.
- [ ] `ps`: db `healthy`; web and jenkins `Up`. The stack's network is a **`10.10.x.0/24`** (e.g. `10.10.0.0/24`), from the network team's range. The web log says `HTTPS certificate: created a self-signed one for editors.eol.org (10 years)` (or, on a later start, the certificate's name and end date).
- [ ] The HTTPS section shows `HTTPS published on 160.111.248.39:443` and `https://editors.eol.org/eol_php8_code/applications/dwc_validator_jenkins/main.php on 160.111.248.39:443 → 200 (plain HTTP 200 too)`.
- [ ] **`rhel9-verify.sh` ends with `0 FAIL`.** Every FAIL line says what to fix. Fix it and run the check again. Don't go on with a FAIL.

**Jenkins** listens only on the server's `127.0.0.1:8080`. Open it from the Mac through an SSH tunnel to your `archive` host (eol-archive, reached through `si`; see the guide, *Jenkins from your Mac*). No Safari proxy setting is needed (the old SOCKS + `http://160.111.248.39:8090` way no longer works):

```bash
ssh -N -L 8090:127.0.0.1:8080 archive    # keep this window open; Ctrl-C closes the tunnel
```

Then open **http://localhost:8090** in Safari. (Optional: the `~/.ssh/config` entry in the guide, *Jenkins from your Mac*, shortens this to `ssh -N eol-jenkins`.)

These settings came over from the Mac, so they're changed once here:

- [ ] Manage Jenkins → System → **Jenkins URL** → `http://localhost:8090/` (the copied setting is the Mac's `http://localhost:8081/`), then Save.
- [ ] Log in. Changing the admin password (it came from the Mac) is optional. If Safari crashes on a Jenkins *Save* button, use Chrome.
- [ ] **A new API token for `web-trigger`**, so the web tools can start Jenkins jobs. Jenkins' page doesn't let an admin make a token for another user, so use the Script Console: Manage Jenkins → **Script Console**, paste this, **Run**. It revokes the copied tokens and prints the new one once:
  ```groovy
  import jenkins.security.ApiTokenProperty
  def u = hudson.model.User.getById('web-trigger', false)
  def s = u.getProperty(ApiTokenProperty).tokenStore
  s.getTokenListSortedByName().each { s.revokeToken(it.uuid) }
  def r = s.generateNewToken('eol-archive web tools')
  u.save()
  println r.plainValue
  ```
  Copy the token, then on the server put it in `production.php` **as `web-trigger:<token>`** (user name, colon, token; without the `web-trigger:` the web tools get 401). Nothing is shown on screen:
  ```bash
  cd /extra/eol_docker/webroot/eol_php8_code/config/environments
  read -rs -p "Paste the new web-trigger token, then press Enter: " T; echo
  [[ $T =~ ^[0-9a-f]{32,40}$ ]] && echo "looks like a token" || echo "NOT a token: stop"
  n=$(grep -n "^define('JENKINS_USER_TOKEN'" production.php | tail -1 | cut -d: -f1); echo "line $n"
  sed -i "${n}s/'JENKINS_USER_TOKEN', *'[^']*'/'JENKINS_USER_TOKEN', 'web-trigger:$T'/" production.php
  grep -cF "'web-trigger:$T'" production.php; unset T
  ```
  → `looks like a token`, the line number of the active `define` (the last one; earlier ones sit in comment blocks), and **1**.
- [ ] Security: matrix authorization `eagbayani` = Administer, `web-trigger` = Read + Build. Agents TCP port: **Disabled**.
- [ ] Manage Jenkins → no "Failed Loading plugin" messages.
- [ ] **`01 EOL Connectors` → `(0026) WoRMS` → Configure → Post-build Actions:** remove *Build other projects* (`/00 Neo4j_PHP_connectors/01 Prepare DwCAs/005_WoRMS_x`, a Neo4j job that isn't on the server), then Save.
- [ ] **Update the plugins with known security fixes.** The Mac's versions of 8 plugins have published Jenkins advisories (2026-04 to 2026-09): `credentials-binding`, `email-ext`, `gradle`, `ldap`, `pipeline-build-step`, `pipeline-groovy-lib`, `workflow-cps`, `workflow-multibranch`. Manage Jenkins → Plugins → **Updates** → select them (or all) → Update → tick *Restart Jenkins when installation is complete*. Jenkins offers only versions that work with 2.580.2.
- [ ] **Remove the timers on the server** (the timed jobs run on the Mac): Manage Jenkins → Script Console, then Run. The jobs stay, for manual runs; the removed schedules are saved in `jenkins_home/timers_removed.tsv`:
  ```groovy
  import hudson.triggers.TimerTrigger
  def out = []
  Jenkins.instance.getAllItems(hudson.model.AbstractProject).each { j ->
    def t = j.getTrigger(TimerTrigger)
    if (t) { out << j.fullName + '\t' + t.spec.readLines().join('\\n'); j.removeTrigger(t.descriptor); j.save() }
  }
  new File(Jenkins.instance.rootDir, 'timers_removed.tsv').text = out.join('\n') + '\n'
  println "removed ${out.size()} timers:"; out.each { println '  ' + it.split('\t')[0] }
  ```
  → `removed 21 timers:`. Then start the Mac's Jenkins again.
- [ ] Run `bash scripts/rhel9-verify.sh` again: `web → Jenkins login as 'web-trigger' works`, and **0 FAIL**.

## 7. Ports 443 and 8080 belong to the web container

**This step makes sure only the web container answers on the website's ports**: 443 on the public address (Cloudflare) and 8080 on the internal one. If the host's own Apache (`httpd`) is installed, it's turned off for good.

```bash
# 1. Stop the host's Apache and keep it off at boot (nothing happens if it isn't installed)
sudo systemctl disable --now httpd 2>/dev/null

# 2. Show what listens on ports 443 and 8080
sudo ss -ltnp | grep -E ':(443|8080) '
```

- [ ] Only `docker-proxy` listens on `160.111.248.39:443` and `10.252.248.39:8080` (and Jenkins on `127.0.0.1:8080`). No `httpd`.

## 8. Nightly database backup

**This step turns on the nightly MySQL backup.** `scripts/mysql-backup.sh` dumps all databases from inside the db container into `/extra/eol_docker/backups` and keeps the newest 10 (each new one beyond 10 deletes the oldest). The password never leaves the container.

```bash
# 1. Run one backup now, to check it works
cd /extra/eol_docker/docker_eol_connectors && bash scripts/mysql-backup.sh

# 2. Add it to your crontab for 2:30 every night (your other cron lines are kept)
( crontab -l 2>/dev/null; echo '30 2 * * * cd /extra/eol_docker/docker_eol_connectors && bash scripts/mysql-backup.sh >> /extra/eol_docker/backups/mysql-backup.log 2>&1' ) | crontab -
crontab -l
```

- [ ] The first run prints `OK /extra/eol_docker/backups/mysql_….sql.gz`. `crontab -l` shows the 2:30 line. If crontab says *You (…) are not allowed to use this program*, the server limits crontab to listed users: ask the admins to allow your login, and don't work around it (e.g. with a file in `/etc/cron.d`). Until then, run the backup by hand when needed. Don't move it into a Jenkins job: that would need Docker access or MySQL's root password inside Jenkins.
- [ ] Put your copy of the old scheduled jobs back (`crontab -e`), adjusted to the new paths if needed.

---

## Go-live checks

**Before the DNS switch**, test the new server the way Cloudflare will reach it:

```bash
# On the server: the HTTPS site on the public address, with the real name (-k: the certificate is self-signed)
curl -sk -o /dev/null -w '%{http_code}\n' --resolve editors.eol.org:443:160.111.248.39 https://editors.eol.org/eol_php8_code/applications/dwc_validator_jenkins/main.php

# On the Mac: from outside Cloudflare, the firewall lets you reach 443, and Apache turns you away (403)
curl -sk -o /dev/null -w '%{http_code}\n' --resolve editors.eol.org:443:160.111.248.39 https://editors.eol.org/eol_php8_code/applications/dwc_validator_jenkins/main.php

# On the Mac: a tunnel to the server's port 443 (keep it open), then open https://localhost:8444/eol_php8_code/applications/dwc_validator_jenkins/main.php in Safari
# (8444, not 8443: the Mac's own stack may use 8443)
ssh -N -L 8444:160.111.248.39:443 archive
```

- [ ] On the server, `curl` prints **200**.
- [ ] On the Mac, `curl` prints **403**: the firewall is open and only Cloudflare gets in. `000` (no answer) means your connection doesn't reach 443: try from another network, or ask the network team. **STOP** if it prints `200`: the site would be open to everyone, around Cloudflare. Check `HTTPS_ALSO_ALLOW` in `.env` and `rhel9-verify.sh`, section HTTPS.
- [ ] Through the tunnel, in Safari: accept the certificate warning once (it's the self-signed one); the site works.
- [ ] **Test with the real data** (through the tunnel):
  - DwC validator: upload an archive → "Valid Archive"
  - submit one job from a web tool (e.g. trait_data_import)

**Meanwhile, through .42:** right after step 6 the old path works again (Cloudflare → .42 → `10.252.248.39:8080`). Open `https://editors.eol.org/…` and `tail /extra/eol_docker/apache2_logs/access.log`: it shows your own IP, or `10.252.248.42` if .42 doesn't send `X-Forwarded-For` (only the log is affected, and only until the switch).

**Through Cloudflare, before the switch:** the network team made a test record, `editors-test.eol.org` (proxied, pointing to eol-archive; 2026-11-06). Open `https://editors-test.eol.org/eol_php8_code/applications/dwc_validator_jenkins/main.php` in Safari and run a test; `access.log` should show your own IP. `curl` to that name gets **403 with `cf-mitigated: challenge`**: that's Cloudflare's bot check on command-line tools, not our server (the request doesn't reach `access.log`).

**The DNS switch** (the firewall is already open). Ask the network team to point Cloudflare's `editors.eol.org` record to **160.111.248.39** (proxied, as now). Then:

- [ ] **Through the public name:** open `https://editors.eol.org/…` (no certificate warning: Cloudflare shows its own), then `tail /extra/eol_docker/apache2_logs/access.log`. It should show **your own** IP (`curl ifconfig.me` on the Mac), not a Cloudflare address (`104.x`, `162.158.x`, `172.64.x`). Errors 526 / 521 / 522: see below.
- [ ] **The next morning:** `ls -l /extra/eol_docker/backups/` has a new dump from 2:30.

## If something goes wrong

| Symptom | Look at |
|---|---|
| A container restarts or doesn't start | `docker compose -f docker-compose.yml logs --tail 50 <web\|db\|jenkins>` |
| "Permission denied" on `/extra` in the logs | Did the relabel finish? `ls -Zd /extra/dumps` should show `container_file_t` |
| A Jenkins job can't write | `rhel9-verify.sh`, section "Work folders"; `getfacl /extra/<folder>` |
| Root disk filling up | `sudo du -xsh /var/lib/docker /var/lib/containerd` (should be tiny); `docker info -f '{{.DockerRootDir}}'` |
| Web → Jenkins fails | the token in `production.php` (step 6) |
| Cloudflare error **526** after the DNS switch | Cloudflare's SSL mode is *Full (strict)* and won't take the self-signed certificate. Ask the network team for a Cloudflare Origin certificate for `editors.eol.org`, save it as `/extra/eol_docker/certs/editors.eol.org.crt` and its key as `editors.eol.org.key` with `sudo` (the folder belongs to root), `sudo chmod 600` the key, then `docker compose -f docker-compose.yml restart web`. No rebuild. Or roll back (below) meanwhile |
| Cloudflare error **521 / 522** | Cloudflare can't reach 160.111.248.39:443: step 7's `ss` line, and ask the network team whether their firewall lets Cloudflare in on 443 |
| `403` on `https://` for everyone | the request didn't come from a Cloudflare address: `rhel9-verify.sh`, section HTTPS. If Cloudflare announced new ranges, refresh `apache-php/cloudflare-ips.txt` and rebuild web |
| Roll back the switch | the network team points the DNS record back to 160.111.248.42 (as long as it exists) |
| Restore the database | `gunzip -c /extra/eol_docker/backups/<file>.sql.gz \| docker compose -f docker-compose.yml exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot'` |
