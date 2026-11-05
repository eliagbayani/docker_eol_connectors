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
| **System files** | `/etc/docker/daemon.json` (`data-root` = `/extra/docker`); one line at the top of `/etc/containerd/config.toml` (`root = "/extra/containerd"`), both checked in step 1. The 10 GB root disk stays essentially unchanged | 1, 6 |
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

# 4. Put Docker's and containerd's storage on /extra (the 10 GB system disk is too small)
sudo mkdir -p /etc/docker /extra/docker /extra/containerd
echo '{ "data-root": "/extra/docker" }' | sudo tee /etc/docker/daemon.json
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

# 8. Check where the storage went (see the two checks below)
sudo docker info -f '{{.DockerRootDir}}'
sudo containerd config dump | grep -m1 '^root'

# 9. Let your login run docker without sudo (takes effect after you log in again)
sudo usermod -aG docker $USER
```

- [ ] **Check that Docker uses `/extra`:** `docker info` prints **`/extra/docker`**. If it prints `/var/lib/docker` (Docker's default), the `daemon.json` setting didn't take effect. **STOP and fix it before proceeding.**
- [ ] **Check that containerd uses `/extra`:** the `grep` prints **`root = '/extra/containerd'`** (a warning line before it, "Configuration migrated from version 0", is normal). If it prints `/var/lib/containerd` (containerd's default), the `config.toml` line didn't take effect. **STOP and fix it before proceeding.**
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

- [ ] The output shows `exists:` for `ckan_resources`, `eol_connector_data_files`, `dumps` and `other_files`, and `created:` for `gnfinder`. **STOP** if `dumps` or `ckan_resources` say `created`: `/extra` isn't the data volume (`findmnt /extra`).

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
- [ ] **Leave the Mac's Jenkins stopped.** 21 of the copied jobs run on a timer (e.g. *Zenodo monthly stats*, the *Dynamic Hierarchy* tasks, some connectors). From step 6 the server runs them, and two machines must not run them both. If you need the Mac's Jenkins later, first disable those timers there: Configure → Build Triggers → untick *Build periodically*.

**Back on the server:**

```bash
cd /extra/eol_docker/docker_eol_connectors

# 1. Check the GBIF download jobs use eol-archive's folder (/extra/other_files/GBIF_occurrence/, same path as on the Mac)
grep -rh --include=config.xml -e '^cd /Volumes' -e '<command>cd /extra/other_files/GBIF_occurrence/' /extra/eol_docker/jenkins_home/jobs | sed 's/^ *//'

# 2. Hand Jenkins' folders to Jenkins (uid 1000 in its container), and the code folder to you
sudo chown -R 1000:1000 /extra/eol_docker/jenkins_home /extra/eol_docker/jenkins_tmp
sudo chown $USER: /extra/eol_docker/webroot

# 3. Give the website (33) and Jenkins (1000) write access to the data folders, now and for new files (owners unchanged)
cd /extra && sudo setfacl -R -m u:33:rwX,u:1000:rwX,d:u:33:rwX,d:u:1000:rwX \
  dumps eol_connector_data_files ckan_resources other_files gnfinder
cd /extra/eol_docker/docker_eol_connectors

# 4. The GBIF jobs' download folder: create it if eol-archive doesn't have it (it inherits the write access from step 3)
ls -ld /extra/other_files/GBIF_occurrence || sudo mkdir /extra/other_files/GBIF_occurrence

# 5. SELinux: a rule that labels all of /extra for container use, then check the rule
sudo semanage fcontext -a -t container_file_t "/extra(/.*)?"
matchpathcon /extra/eol_php_resources /extra/docker /extra/containerd

# 6. Apply the labels to the existing 3.8 TB, in the background (an hour or more)
sudo nohup restorecon -R /extra > /tmp/restorecon.log 2>&1 &
```

- [ ] `find /extra/eol_docker/jenkins_home/jobs -name config.xml | wc -l` shows **277** (40 folders + 237 jobs; the Mac's 443 minus the 166 Neo4j ones), `ls /extra/eol_docker/jenkins_home/jobs | grep -c Neo4j` prints **0**, and `/extra/eol_docker/jenkins_home/plugins.txt` exists.
- [ ] The GBIF `grep` prints exactly **4 lines**, all `<command>cd /extra/other_files/GBIF_occurrence/…` (National, Countries, Waterbody and Continent), and **no** `cd /Volumes` line. **STOP and fix it before proceeding** if a `cd /Volumes` line shows up: that job would fail on the server (the Mac's Jenkins needs the same fix, then copy again).
- [ ] `ls -ld /extra/other_files/GBIF_occurrence` shows a folder (or, if it was missing, the `mkdir` created it; `getfacl /extra/other_files/GBIF_occurrence` then shows `user:33:rwx` and `user:1000:rwx`).
- [ ] `matchpathcon` prints `container_file_t` for `eol_php_resources` and `container_var_lib_t` for both `docker` and `containerd`. **STOP** if `/extra/docker` shows `container_file_t`.
- [ ] The relabel runs in the background (an hour or more). Steps 4 and 5 can be done meanwhile. **Wait until `pgrep restorecon` prints nothing before step 6.**

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

# 4. Check the addresses and ports the containers listen on
grep -E '^(WEB_PORTS|JENKINS_PORTS|MYSQL_PORTS)=' .env
```

- [ ] `grep -c` prints **0**, and the last command prints the two names with **48 chars** each (the passwords themselves aren't shown).
- [ ] The ports are **`WEB_PORTS=10.252.248.39:8080:80`**, `JENKINS_PORTS=127.0.0.1:8080:8080` and `MYSQL_PORTS=127.0.0.1:4001:3306`. **STOP** if `WEB_PORTS` has no address in front (e.g. `80:80`): the site would be on the public IP, around Cloudflare. Leave the paths as they are in the sample.
- To see a password later (e.g. to log in to MySQL by hand): `grep '^MYSQL_ROOT_PASSWORD=' .env`. Don't paste it anywhere.

## 5. Code, work folders, config files

**This step puts the PHP code on the server**, in `/extra/eol_docker/webroot`. The web and jenkins containers both use this folder (as `/var/www/html`). Git doesn't save the code's work folders or its private config files, so this step creates the folders and copies the config files from the Mac. Without them, jobs fail quietly while Jenkins still says "success".

```bash
# 1. Download the three code repos from GitHub
cd /extra/eol_docker/webroot
git clone https://github.com/eliagbayani/eol_php8_code.git
git clone https://github.com/eliagbayani/FreshData_min.git
git clone https://github.com/eliagbayani/LiteratureEditor_min.git
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

**On the Mac**, copy the 2 config files that aren't in git. Only these two are used: the code loads `environments/production.php` for the website and for every Jenkins job. `jenkins_production.php` is never loaded (a Jenkins job only switches to the `jenkins_production:` section of `database.yml`), so it stays on the Mac.

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
#    production + jenkins_production get the MYSQL_PASSWORD from .env; the other sections (the Mac's) get an empty password
P=$(grep '^MYSQL_PASSWORD=' /extra/eol_docker/docker_eol_connectors/.env | cut -d= -f2)
awk -v p="$P" '/^[a-z_]+:[[:space:]]*$/ { s = $1 }
  /^[[:space:]]+password:/ { if (s == "production:" || s == "jenkins_production:") sub(/password:.*/, "password: \"" p "\""); else sub(/password:.*/, "password: \"\"") }
  { print }' database.yml > database.yml.new && mv database.yml.new database.yml
grep -cF "\"$P\"" database.yml; unset P

# 2. Close the config files to other users
chmod 640 database.yml environments/production.php
ls environments/

# 3. Check the production sections connect to the db container as eol_app
grep -A4 -E '^(production|jenkins_production):' database.yml | grep -E '^\s+(host|username):'
```

- [ ] `ls environments/` shows `production.php` next to the three files from git (`development_sample.php`, `production_sample.php`, `test_sample.php`), and no `jenkins_production.php`.
- [ ] `grep -cF` prints **2** (both production sections have the password), and the last command shows `host: db` and `username: eol_app` twice.
- [ ] `production.php` has `JENKINS_DOMAIN` set to `jenkins:8080`. The token is replaced after step 6.

## 6. Build, start, check

**This step builds the three containers and starts them.** The build downloads the base images and installs PHP 8.4 and the tools in the web and jenkins images, and Apache in the web image (this takes a while). Jenkins' plugins are installed from the list before its first start. Then the server check (`rhel9-verify.sh`) tests everything: containers, folders, permissions, SELinux, ports, database and Jenkins.

```bash
cd /extra/eol_docker/docker_eol_connectors

# 1. The relabel from step 3 must be finished
pgrep restorecon || echo "relabel done"

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

# 5. Start web, db and jenkins (they also start again at every boot), and show their state
docker compose -f docker-compose.yml up -d
docker compose -f docker-compose.yml ps

# 6. The server check
bash scripts/rhel9-verify.sh
```

- [ ] The relabel is done. The build log shows **`PHP 8.4.27`** (or newer). `df -h /` is still about 3 GB used, and `du` shows `/var/lib/docker` and `/var/lib/containerd` as absent or tiny (the images are under `/extra`).
- [ ] The plugin tool ends with `Done`, and `ls … | wc -l` prints **94**. **STOP** if it's fewer, or the tool can't reach `updates.jenkins.io`: Jenkins can't read its security settings or folders without them. Run the command again (it retries mirrors), or copy the plugins from the Mac instead: `rsync -a /Volumes/OWC_Express/other_files/My_Docker_content/jenkins_home/plugins/ archive:/extra/eol_docker/jenkins_home/plugins/`, then `sudo chown -R 1000:1000 /extra/eol_docker/jenkins_home/plugins`.
- [ ] `ps`: db `healthy`; web and jenkins `Up`.
- [ ] **`rhel9-verify.sh` ends with `0 FAIL`.** Every FAIL line says what to fix. Fix it and run the check again. Don't go on with a FAIL.

**Jenkins** listens only on the server's `127.0.0.1:8080`. Open it from the Mac through an SSH tunnel to your `archive` host (eol-archive, reached through `si`; see the guide, *Jenkins from your Mac*). No Safari proxy setting is needed (the old SOCKS + `http://160.111.248.39:8090` way no longer works):

```bash
ssh -N -L 8090:127.0.0.1:8080 archive    # keep this window open; Ctrl-C closes the tunnel
```

Then open **http://localhost:8090** in Safari. (Optional: the `~/.ssh/config` entry in the guide, *Jenkins from your Mac*, shortens this to `ssh -N eol-jenkins`.)

These settings came over from the Mac, so they're changed once here:

- [ ] Manage Jenkins → System → **Jenkins URL** → `http://localhost:8090/` (the copied setting is the Mac's `http://localhost:8081/`), then Save.
- [ ] Log in, then **change the admin password** (it came from the Mac).
- [ ] User `web-trigger` → **revoke the copied API token, create a new one** → put it in `production.php` as `JENKINS_USER_TOKEN`.
- [ ] Security: matrix authorization `eagbayani` = Administer, `web-trigger` = Read + Build. Agents TCP port: **Disabled**.
- [ ] Manage Jenkins → no "Failed Loading plugin" messages.
- [ ] **`01 EOL Connectors` → `(0026) WoRMS` → Configure → Post-build Actions:** remove *Build other projects* (`/00 Neo4j_PHP_connectors/01 Prepare DwCAs/005_WoRMS_x`, a Neo4j job that isn't on the server), then Save.
- [ ] **Update the plugins with known security fixes.** The Mac's versions of 8 plugins have published Jenkins advisories (2026-04 to 2026-09): `credentials-binding`, `email-ext`, `gradle`, `ldap`, `pipeline-build-step`, `pipeline-groovy-lib`, `workflow-cps`, `workflow-multibranch`. Manage Jenkins → Plugins → **Updates** → select them (or all) → Update → tick *Restart Jenkins when installation is complete*. Jenkins offers only versions that work with 2.580.2.
- [ ] Run `bash scripts/rhel9-verify.sh` again: `web → Jenkins login as 'web-trigger' works`, and **0 FAIL**.

## 7. Port 8080 belongs to the web container

**This step makes sure only the web container answers on port 8080**, where the front device sends visitors. If the host's own Apache (`httpd`) is installed, it's turned off for good.

```bash
# 1. Stop the host's Apache and keep it off at boot (nothing happens if it isn't installed)
sudo systemctl disable --now httpd 2>/dev/null

# 2. Show what listens on port 8080
sudo ss -ltnp | grep ':8080 '
```

- [ ] Only `docker-proxy` listens on `10.252.248.39:8080` (and Jenkins on `127.0.0.1:8080`). No `httpd`.

## 8. Nightly database backup

**This step turns on the nightly MySQL backup.** `scripts/mysql-backup.sh` dumps all databases from inside the db container into `/extra/eol_docker/backups` and keeps the newest 14. The password never leaves the container.

```bash
# 1. Run one backup now, to check it works
cd /extra/eol_docker/docker_eol_connectors && bash scripts/mysql-backup.sh

# 2. Add it to your crontab for 2:30 every night (your other cron lines are kept)
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
