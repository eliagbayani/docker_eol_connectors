# Deployment day: eol-archive (RHEL 9.8)

The short version of `docs/rhel9_production_env_guide.md` (deploy steps 1–8). Each step lists the commands, what you should see, and where to **STOP** if it doesn't match.

- **Server:** eol-archive, RHEL 9.8, SELinux Enforcing. Root disk 10 GB; data volume `/extra` 9.1 TB (kept from the old server).
- **Layout:** everything under `/extra`: Docker in `/extra/docker` and `/extra/containerd`, the stack in `/extra/eol_docker`, data in `/extra` as before.
- **Who:** your own login. Use `sudo` only where shown. No root shell (`sudo su`): in a root shell `~` is `/root`, and files get the wrong owner.
- **Time:** about 2–3 hours. The longest part is the SELinux relabel of `/extra` (step 3), which runs in the background.

## For the admins: what this deployment changes on the server

The EOL tools (website, MySQL and Jenkins) run as three Docker containers. Changes to eol-archive (10.252.248.39 / 160.111.248.39), by area:

| Area | Change | Step |
|---|---|---|
| **Packages** | Docker's repository (`download.docker.com/linux/rhel`) added; `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-compose-plugin` and `policycoreutils-python-utils` installed; `podman-docker` / `buildah` removed if present | 1 |
| **Services** | `docker` (and `containerd`) enabled at boot, and wait for the `/extra` mount (drop-ins in `/etc/systemd/system/{docker,containerd}.service.d/extra.conf`). The host's own `httpd` is disabled if present | 1, 7 |
| **System files** | `/etc/docker/daemon.json` (`data-root` = `/extra/docker`); one line at the top of `/etc/containerd/config.toml` (`root = "/extra/containerd"`). The 10 GB root disk stays essentially unchanged | 1 |
| **SELinux** (stays Enforcing) | persistent rules: `/extra(/.*)?` → `container_file_t`; `/extra/docker` and `/extra/containerd` labelled like `/var/lib/docker` and `/var/lib/containerd`. A one-time `restorecon -R /extra` (3.8 TB) relabels the existing data from `default_t` | 1, 3 |
| **`/extra`** | new folders `docker/`, `containerd/`, `eol_docker/` (mode 700, owned by the deploying login) and `gnfinder/`. ACLs on `dumps`, `eol_connector_data_files`, `ckan_resources`, `other_files` and `gnfinder` give uid 33 (website) and uid 1000 (Jenkins) write access. **Existing data, owners and modes are not changed** | 1, 3 |
| **Network: listening** | **`10.252.248.39:8080`**: the website, plain HTTP, for the front device 160.111.248.42. `127.0.0.1:8080` (Jenkins) and `127.0.0.1:4001` (MySQL): local only, reached through SSH. **Nothing listens on the public 160.111.248.39.** Docker adds its own nftables rules for the published port; firewalld isn't changed | 6 |
| **Network: outgoing** (HTTPS, during the build and plugin install) | Docker Hub (base images `php`, `jenkins/jenkins`, `mysql`), `deb.debian.org` and `packages.sury.org` (PHP), `github.com` (code, gnparser), `updates.jenkins.io` and its download mirrors (`get.jenkins.io`, `mirrors.jenkins-ci.org` and others; Jenkins plugins) | 2, 5, 6 |
| **Users and groups** | the deploying login joins the `docker` group (**equivalent to root**, as for any Docker host). No new system users. Inside the containers, the website runs as uid 33 and Jenkins as uid 1000 | 1 |
| **Cron** | one line in the deploying login's crontab: a nightly MySQL dump at 2:30 into `/extra/eol_docker/backups` (14 kept) | 8 |

Before you start:
- [ ] The Mac's repo, `eol_php8_code`, `FreshData_min` and `LiteratureEditor_min` are pushed to GitHub.
- [ ] Nothing to prepare for passwords: step 4 makes new ones on the server with `openssl rand -hex 24`. Never reuse old ones.

### Before deployment: the network path

Visitors reach the site like this: Cloudflare (HTTPS) → front device **160.111.248.42** (ends HTTPS; internal address 10.252.248.42) → eol-archive **10.252.248.39:8080** (plain HTTP). The setup depends on this path: `WEB_PORTS=10.252.248.39:8080:80` in `.env`, and `REMOTEIP_PROXY=10.252.248.42` for real visitor IPs (the default; set it in `.env` only if it changes).

- [x] **The internal address survived the rebuild** (checked 2026-11-05):
  ```bash
  ip -4 addr show | grep -E 'inet (10\.252\.248\.39|160\.111\.248\.39)'
  ```
  → `10.252.248.39/24` on `eno1` (internal) and `160.111.248.39/24` on `eno2` (public). The public address sits directly on the server. That's why the web container binds to the internal address only: Docker bypasses firewalld, so `0.0.0.0:8080` would put the site straight on the internet, around Cloudflare.
- [ ] **The admins confirm the forwarding:**
  - .42 still sends `editors.eol.org` to 10.252.248.39, port 8080, from 10.252.248.42
  - nothing in between blocks port 8080
  - .42 sends `X-Forwarded-For` (and `X-Forwarded-Proto`?)

  If something differs: a new address → `WEB_PORTS` in `.env`; a different .42 address → `REMOTEIP_PROXY=<address>` in `.env`; other headers → the `RemoteIPHeader` note in the guide (*Public access*).

---

## 1. Docker, with its storage on `/extra`

```bash
sudo dnf remove -y podman-docker buildah 2>/dev/null || true
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin policycoreutils-python-utils
sudo mkdir -p /etc/docker /extra/docker /extra/containerd
echo '{ "data-root": "/extra/docker" }' | sudo tee /etc/docker/daemon.json
sudo sed -i '1i root = "/extra/containerd"' /etc/containerd/config.toml
sudo semanage fcontext -a -e /var/lib/docker /extra/docker
sudo semanage fcontext -a -e /var/lib/containerd /extra/containerd
sudo restorecon -R /extra/docker /extra/containerd
sudo systemctl restart containerd
sudo mkdir -p /etc/systemd/system/docker.service.d /etc/systemd/system/containerd.service.d
printf '[Unit]\nRequiresMountsFor=/extra\n' | sudo tee /etc/systemd/system/docker.service.d/extra.conf
sudo cp /etc/systemd/system/docker.service.d/extra.conf /etc/systemd/system/containerd.service.d/
sudo systemctl daemon-reload
sudo systemctl enable --now docker
sudo docker info -f '{{.DockerRootDir}}'
sudo usermod -aG docker $USER
```
- [ ] The last `docker info` prints **`/extra/docker`**. **STOP** if it prints `/var/lib/docker`: the 10 GB root disk would fill up.
- [ ] **Log out and back in** (for the `docker` group), then `docker ps` works without `sudo`.

## 2. The Docker package

```bash
sudo mkdir -p /extra/eol_docker && sudo chown $USER: /extra/eol_docker
chmod 700 /extra/eol_docker
git clone https://github.com/eliagbayani/docker_eol_connectors.git /extra/eol_docker/docker_eol_connectors
cd /extra/eol_docker/docker_eol_connectors
```
- [ ] `git log --oneline -1` shows the Mac's latest commit.

## 3. Folders, Jenkins data, permissions, SELinux

```bash
sudo bash scripts/rhel9-init-dirs.sh
sudo chown $USER: /extra/eol_docker/jenkins_home
```
- [ ] The output shows `exists:` for `ckan_resources`, `eol_connector_data_files`, `dumps` and `other_files`, and `created:` for `gnfinder`. **STOP** if `dumps` or `ckan_resources` say `created`: `/extra` isn't the data volume (`findmnt /extra`).

**On the Mac**, with Jenkins stopped, copy Jenkins' **jobs, settings, users and secrets** (about 20 MB). The build history (1.55 GB) and the plugins aren't copied. Instead, a list of the 94 plugins with their exact versions goes along as `plugins.txt`, and step 6 installs them.
```bash
cd /Volumes/OWC_Express/other_files/My_Docker/docker_eol_connectors && docker compose stop jenkins
JH=/Volumes/OWC_Express/other_files/My_Docker_content/jenkins_home
for m in $JH/plugins/*/META-INF/MANIFEST.MF; do
  awk -F': ' '/^Short-Name:/ { n = $2 } /^Plugin-Version:/ { v = $2 } END { gsub(/\r/, "", n); gsub(/\r/, "", v); print n ":" v }' "$m"
done > /tmp/jenkins_plugins.txt
wc -l < /tmp/jenkins_plugins.txt
rsync -a --exclude='builds/' --exclude='lastStable' --exclude='lastSuccessful' --exclude='/plugins/' --exclude='/war/' \
  --exclude='/logs/' --exclude='/updates/' --exclude='/workspace/' --exclude='/.cache/' --exclude='/.java/' --exclude='/.local/' \
  --exclude='.DS_Store' --exclude='.bash_history' "$JH/" archive:/extra/eol_docker/jenkins_home/
rsync -a /tmp/jenkins_plugins.txt archive:/extra/eol_docker/jenkins_home/plugins.txt
```
- [ ] `wc -l` prints **94** (one line per plugin, e.g. `matrix-auth:3.3`).
- [ ] **Leave the Mac's Jenkins stopped.** 22 jobs run on a timer (e.g. *Zenodo monthly stats*, the *Dynamic Hierarchy* tasks, some connectors). From step 6 the server runs them, and two machines must not run them both. If you need the Mac's Jenkins later, first disable those timers there: Configure → Build Triggers → untick *Build periodically*.

**Back on the server:**
```bash
cd /extra/eol_docker/docker_eol_connectors
sudo chown -R 1000:1000 /extra/eol_docker/jenkins_home /extra/eol_docker/jenkins_tmp
sudo chown $USER: /extra/eol_docker/webroot
cd /extra && sudo setfacl -R -m u:33:rwX,u:1000:rwX,d:u:33:rwX,d:u:1000:rwX \
  dumps eol_connector_data_files ckan_resources other_files gnfinder
cd /extra/eol_docker/docker_eol_connectors
sudo semanage fcontext -a -t container_file_t "/extra(/.*)?"
matchpathcon /extra/eol_php_resources /extra/docker /extra/containerd
sudo nohup restorecon -R /extra > /tmp/restorecon.log 2>&1 &
```
- [ ] `find /extra/eol_docker/jenkins_home/jobs -name config.xml | wc -l` shows **443** (47 folders + 396 jobs), and `/extra/eol_docker/jenkins_home/plugins.txt` exists.
- [ ] `matchpathcon` prints `container_file_t` for `eol_php_resources` and `container_var_lib_t` for both `docker` and `containerd`. **STOP** if `/extra/docker` shows `container_file_t`.
- [ ] The relabel runs in the background (an hour or more). Steps 4 and 5 can be done meanwhile. **Wait until `pgrep restorecon` prints nothing before step 6.**

## 4. Settings (`.env`)

Each `openssl rand -hex 24` gives a new random 48-character password, written straight into `.env`. Nothing is shown on screen.
```bash
cd /extra/eol_docker/docker_eol_connectors
cp .env.production.sample .env && chmod 600 .env
sed -i "s/^MYSQL_ROOT_PASSWORD=CHANGE_ME.*/MYSQL_ROOT_PASSWORD=$(openssl rand -hex 24)/" .env
sed -i "s/^MYSQL_PASSWORD=CHANGE_ME.*/MYSQL_PASSWORD=$(openssl rand -hex 24)/" .env
sed -i "s/^NEO_PASSWORD=CHANGE_ME.*/NEO_PASSWORD=$(openssl rand -hex 24)/" .env
grep -v '^\s*#' .env | grep -c CHANGE_ME
grep -E '^(MYSQL_ROOT_PASSWORD|MYSQL_PASSWORD|NEO_PASSWORD)=' .env | awk -F= '{ print $1, length($2), "chars" }'
grep -E '^(WEB_PORTS|JENKINS_PORTS|MYSQL_PORTS)=' .env
```
- [ ] `grep -c` prints **0**, and the last command prints the three names with **48 chars** each (the passwords themselves aren't shown).
- [ ] The ports are **`WEB_PORTS=10.252.248.39:8080:80`**, `JENKINS_PORTS=127.0.0.1:8080:8080` and `MYSQL_PORTS=127.0.0.1:4001:3306`. **STOP** if `WEB_PORTS` has no address in front (e.g. `80:80`): the site would be on the public IP, around Cloudflare. Leave the paths as they are in the sample.
- To see a password later (e.g. to log in to MySQL by hand): `grep '^MYSQL_ROOT_PASSWORD=' .env`. Don't paste it anywhere.

## 5. Code, work folders, config files

```bash
cd /extra/eol_docker/webroot
git clone https://github.com/eliagbayani/eol_php8_code.git
git clone https://github.com/eliagbayani/FreshData_min.git
git clone https://github.com/eliagbayani/LiteratureEditor_min.git
cd /extra/eol_docker/webroot/eol_php8_code
mkdir -p temp tmp/cache applications/content_server/tmp \
  applications/{BOLD2iNAT,BOLD2iNAT_csv,branch_graft,specimen_image_export,taxonomic_validation,trait_data_import,xls2dwca_jenkins}/temp \
  applications/{dwc_validator_jenkins,DwC_branch_extractor,genHigherClass,genHigherClass_jenkins,CheckListBank_tool}/temp \
  ../FreshData_min/sh_files
ln -s /extra/eol_php_resources/ applications/content_server/resources
ln -s /extra/FreshData_TSV_files ../FreshData_min/TSV_files
chmod 777 temp tmp/cache applications/content_server/tmp applications/*/temp ../FreshData_min/sh_files
setfacl -R -m u:33:rwX,u:1000:rwX,d:u:33:rwX,d:u:1000:rwX update_resources/connectors/files
git status --short | wc -l
ls -ld /extra/eol_php_resources/ /extra/FreshData_TSV_files/
```
- [ ] `git status` gives **0**, and both `ls -ld` lines show real folders.

**On the Mac**, copy the 3 config files that aren't in git:
```bash
cd /Volumes/OWC_Express/other_files/My_Docker_content/webroot/eol_php8_code/config
scp database.yml archive:/extra/eol_docker/webroot/eol_php8_code/config/
scp environments/production.php environments/jenkins_production.php archive:/extra/eol_docker/webroot/eol_php8_code/config/environments/
```

**On the server:**
```bash
cd /extra/eol_docker/webroot/eol_php8_code/config
# production + jenkins_production get the MYSQL_PASSWORD from .env; the other sections (the Mac's) get an empty password
P=$(grep '^MYSQL_PASSWORD=' /extra/eol_docker/docker_eol_connectors/.env | cut -d= -f2)
awk -v p="$P" '/^[a-z_]+:[[:space:]]*$/ { s = $1 }
  /^[[:space:]]+password:/ { if (s == "production:" || s == "jenkins_production:") sub(/password:.*/, "password: \"" p "\""); else sub(/password:.*/, "password: \"\"") }
  { print }' database.yml > database.yml.new && mv database.yml.new database.yml
grep -cF "\"$P\"" database.yml; unset P
chmod 640 database.yml environments/production.php environments/jenkins_production.php
grep -A4 -E '^(production|jenkins_production):' database.yml | grep -E '^\s+(host|username):'
```
- [ ] `grep -cF` prints **2** (both production sections have the password), and the last command shows `host: db` and `username: eol_app` twice.
- [ ] `production.php` has `JENKINS_DOMAIN` set to `jenkins:8080`. The token is replaced after step 6.

## 6. Build, start, check

```bash
cd /extra/eol_docker/docker_eol_connectors
pgrep restorecon || echo "relabel done"
docker compose -f docker-compose.yml build --no-cache --pull 2>&1 | tee /tmp/build.log | tail -3
grep -m1 "PHP 8.4" /tmp/build.log
df -h /
# Jenkins' plugins, from the list copied in step 3 (needs HTTPS to updates.jenkins.io; about 3 minutes)
docker compose -f docker-compose.yml run --rm --no-deps --entrypoint jenkins-plugin-cli jenkins \
  --plugin-file /var/jenkins_home/plugins.txt --plugin-download-directory /var/jenkins_home/plugins 2>&1 | tail -3
ls /extra/eol_docker/jenkins_home/plugins/*.jpi | wc -l
docker compose -f docker-compose.yml up -d
docker compose -f docker-compose.yml ps
bash scripts/rhel9-verify.sh
```
- [ ] The relabel is done. The build log shows **`PHP 8.4.27`** (or newer). `df -h /` is still about 3 GB used.
- [ ] The plugin tool ends with `Done`, and `ls … | wc -l` prints **94**. **STOP** if it's fewer, or the tool can't reach `updates.jenkins.io`: Jenkins can't read its security settings or folders without them. Run the command again (it retries mirrors), or copy the plugins from the Mac instead: `rsync -a /Volumes/OWC_Express/other_files/My_Docker_content/jenkins_home/plugins/ archive:/extra/eol_docker/jenkins_home/plugins/`, then `sudo chown -R 1000:1000 /extra/eol_docker/jenkins_home/plugins`.
- [ ] `ps`: db `healthy`; web and jenkins `Up`.
- [ ] **`rhel9-verify.sh` ends with `0 FAIL`.** Every FAIL line says what to fix. Fix it and run the check again. Don't go on with a FAIL.

**Jenkins** listens only on the server's `127.0.0.1:8080`. Open it from the Mac through an SSH tunnel to your `archive` host (eol-archive, reached through `si`; see the guide, *Jenkins from your Mac*). No Safari proxy setting is needed (the old SOCKS + `http://160.111.248.39:8090` way no longer works):
```bash
ssh -N -L 8090:127.0.0.1:8080 archive    # keep this window open; Ctrl-C closes the tunnel
```
Then open **http://localhost:8090** in Safari. (Optional: the `~/.ssh/config` entry in the guide, *Jenkins from your Mac*, shortens this to `ssh -N eol-jenkins`.)
- [ ] Manage Jenkins → System → **Jenkins URL** → `http://localhost:8090/` (the copied setting is the Mac's `http://localhost:8081/`), then Save.
- [ ] Log in, then **change the admin password** (it came from the Mac).
- [ ] User `web-trigger` → **revoke the copied API token, create a new one** → put it in `production.php` as `JENKINS_USER_TOKEN`.
- [ ] Security: matrix authorization `eagbayani` = Administer, `web-trigger` = Read + Build. Agents TCP port: **Disabled**.
- [ ] Manage Jenkins → no "Failed Loading plugin" messages.
- [ ] **Update the plugins with known security fixes.** The Mac's versions of 8 plugins have published Jenkins advisories (2026-04 to 2026-09): `credentials-binding`, `email-ext`, `gradle`, `ldap`, `pipeline-build-step`, `pipeline-groovy-lib`, `workflow-cps`, `workflow-multibranch`. Manage Jenkins → Plugins → **Updates** → select them (or all) → Update → tick *Restart Jenkins when installation is complete*. Jenkins offers only versions that work with 2.580.2.
- [ ] Run `bash scripts/rhel9-verify.sh` again: `web → Jenkins login as 'web-trigger' works`, and **0 FAIL**.

## 7. Port 8080 belongs to the web container

```bash
sudo systemctl disable --now httpd 2>/dev/null
sudo ss -ltnp | grep ':8080 '
```
- [ ] Only `docker-proxy` listens on `10.252.248.39:8080` (and Jenkins on `127.0.0.1:8080`). No `httpd`.

## 8. Nightly database backup

```bash
cd /extra/eol_docker/docker_eol_connectors && bash scripts/mysql-backup.sh
( crontab -l 2>/dev/null; echo '30 2 * * * cd /extra/eol_docker/docker_eol_connectors && bash scripts/mysql-backup.sh >> /extra/eol_docker/backups/mysql-backup.log 2>&1' ) | crontab -
crontab -l
```
- [ ] The first run prints `OK /extra/eol_docker/backups/mysql_….sql.gz`. `crontab -l` shows the 2:30 line.
- [ ] Put your copy of the old scheduled jobs back (`crontab -e`), adjusted to the new paths if needed.

---

## Go-live checks

- [ ] **Test with the real data:**
  - DwC validator: upload an archive → "Valid Archive"
  - run 2–3 connectors from Jenkins
  - submit one job from a web tool (e.g. trait_data_import)
- [ ] **Through the public name:** open `https://editors.eol.org/…`, then `tail /extra/eol_docker/apache2_logs/access.log`. It should show **your own** IP, not `10.252.248.42`. If it shows `10.252.248.42`, see "Public access" in the guide.
- [ ] **The next morning:** `ls -l /extra/eol_docker/backups/` has a new dump from 2:30.

## If something goes wrong

| Symptom | Look at |
|---|---|
| A container restarts or doesn't start | `docker compose -f docker-compose.yml logs --tail 50 <web\|db\|jenkins>` |
| "Permission denied" on `/extra` in the logs | Did the relabel finish? `ls -Zd /extra/dumps` should show `container_file_t` |
| A Jenkins job can't write | `rhel9-verify.sh`, section "Work folders"; `getfacl /extra/<folder>` |
| Root disk filling up | `sudo du -xsh /var/lib/docker /var/lib/containerd` (should be tiny); `docker info -f '{{.DockerRootDir}}'` |
| Web → Jenkins fails | the token in `production.php` (step 6) |
| Restore the database | `gunzip -c /extra/eol_docker/backups/<file>.sql.gz \| docker compose -f docker-compose.yml exec -T db sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot'` |
