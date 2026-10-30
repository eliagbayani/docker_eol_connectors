#!/usr/bin/env bash
# Read-only check of a running production stack (status report section F, RHEL guide).
# Run from the repo folder on the server, after `docker compose -f docker-compose.yml up -d`:
#   bash scripts/rhel9-verify.sh
# It changes nothing and never prints passwords or tokens. One line per check: OK, WARN (look at it)
# or FAIL (fix before go-live). Exit code 1 if anything failed.
# Settings (environment):
#   COMPOSE="docker compose -f docker-compose.yml"   how to reach the stack (e.g. add -p <project> for a test stack)
#   ENV_FILE=.env                                    for APACHE_LOGS and the expected memory limits

set -u
COMPOSE=${COMPOSE:-docker compose -f docker-compose.yml}
ENV_FILE=${ENV_FILE:-.env}
ok=0; warn=0; fail=0
OK()   { printf '[ OK ] %s\n' "$*"; ok=$((ok + 1)); }
WARN() { printf '[WARN] %s\n' "$*"; warn=$((warn + 1)); }
FAIL() { printf '[FAIL] %s\n' "$*"; fail=$((fail + 1)); }
dc() { $COMPOSE "$@"; }
envval() { [ -f "$ENV_FILE" ] && grep -E "^$1=" "$ENV_FILE" | tail -1 | cut -d= -f2- | sed 's/[[:space:]]*#.*//'; }

DB=$(dc ps -q db 2>/dev/null); WEB=$(dc ps -q web 2>/dev/null); JEN=$(dc ps -q jenkins 2>/dev/null)

echo "== Containers"
for pair in "db:$DB" "web:$WEB" "jenkins:$JEN"; do
    name=${pair%%:*}; id=${pair#*:}
    if [ -z "$id" ]; then FAIL "$name: not running"; continue; fi
    state=$(docker inspect -f '{{.State.Status}}{{if .State.Health}}/{{.State.Health.Status}}{{end}}' "$id")
    case "$state" in running|running/healthy) OK "$name: $state" ;; *) FAIL "$name: $state" ;; esac
done
[ -n "$DB" ] && [ -n "$WEB" ] && [ -n "$JEN" ] || { echo; echo "Stack not complete; start it first."; exit 1; }

echo "== Ports (B6): only web may listen beyond 127.0.0.1"
ports=$(for pair in "db:$DB" "web:$WEB" "jenkins:$JEN"; do
    docker inspect -f '{{range $p, $b := .NetworkSettings.Ports}}{{range $b}}'"${pair%%:*}"' {{$p}} {{.HostIp}}:{{.HostPort}}{{"\n"}}{{end}}{{end}}' "${pair#*:}"
done)
while read -r name cport host; do
    [ -n "$cport" ] || continue
    hip=${host%:*}
    if [ "$name" != web ] && [ "$hip" != 127.0.0.1 ]; then FAIL "$name $cport published on $host (must be 127.0.0.1)"
    elif [ "$name" = web ] && { [ "$hip" = 0.0.0.0 ] || [ "$hip" = "::" ] || [ -z "$hip" ]; }; then WARN "web $cport published on all interfaces ($host); production uses the internal IP (WEB_PORTS=10.252.248.39:8080:80)"
    else OK "$name $cport → $host"; fi
done <<< "$ports"
command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet httpd 2>/dev/null && FAIL "host httpd is running; the web container must own the web port"

echo "== Web: headers and blocked files (H1, H2, B3, B4, N11)"
ADDR=$(dc port web 80 2>/dev/null | head -1); ADDR=${ADDR/0.0.0.0/127.0.0.1}
if [ -z "$ADDR" ]; then FAIL "web port 80 is not published"; else
    U="http://$ADDR"
    hdr=$(curl -s -m 10 -o /dev/null -D - "$U/eol_php8_code/" | tr -d '\r')
    srv=$(printf '%s\n' "$hdr" | grep -i '^Server:' | cut -d' ' -f2-)
    [ "$srv" = Apache ] && OK "Server header: Apache (no version)" || FAIL "Server header: '$srv' (expected just 'Apache')"
    printf '%s\n' "$hdr" | grep -qi '^X-Powered-By:' && FAIL "X-Powered-By header present (PHP version visible)" || OK "no X-Powered-By header"
    code() { curl -s -m 10 -o /dev/null -w '%{http_code}' "$U$1"; }
    for p in /eol_php8_code/config/database.yml /eol_php_code/config/database.yml /eol_php8_code/Gemfile; do
        c=$(code "$p"); [ "$c" = 403 ] && OK "$p → 403" || FAIL "$p → $c (expected 403)"
    done
    c=$(code /eol_php8_code/.git/config); [ "$c" = 404 ] && OK "/eol_php8_code/.git/config → 404" || FAIL "/eol_php8_code/.git/config → $c (expected 404)"
    curl -s -m 10 "$U/dumps/" | grep -qi '<title>Index of' && FAIL "/dumps/ shows a folder listing" || OK "/dumps/ shows no folder listing"
    c=$(code /info.php); [ "$c" = 404 ] && OK "no info.php in the webroot" || FAIL "/info.php → $c: delete info.php from the webroot (B3)"
    c=$(code /test.php)
    if [ "$c" = 200 ]; then
        rows=$(curl -s -m 20 "$U/test.php" | grep -o 'Rows: [0-9]*' | head -1)
        [ -n "$rows" ] && WARN "test.php works ($rows): delete it after the smoke test (B3)" || FAIL "test.php is there but shows no Rows: check MySQL / eol_app password"
    elif [ "$c" = 404 ]; then OK "no test.php in the webroot"
    else FAIL "test.php → HTTP $c (fails, e.g. wrong eol_app password in it); fix or delete it"; fi
fi

echo "== Web container"
[ "$(docker exec "$WEB" cat /proc/1/comm 2>/dev/null)" = apache2 ] && OK "Apache is PID 1 (M1)" || FAIL "Apache is not PID 1"
docker exec "$WEB" apache2ctl -t >/dev/null 2>&1 && OK "Apache config syntax OK" || FAIL "apache2ctl -t failed"
docker exec "$WEB" apache2ctl -M 2>/dev/null | grep -q remoteip_module && OK "mod_remoteip loaded (H6); REMOTEIP_PROXY=$(docker exec "$WEB" printenv REMOTEIP_PROXY)" || FAIL "mod_remoteip not loaded"
docker exec "$WEB" php -r 'exit(ini_get("display_errors") ? 1 : 0);' && OK "PHP display_errors off (H1)" || FAIL "PHP display_errors is on (production image expected)"
w=$(docker logs "$WEB" 2>&1 | grep -c '^WARNING')
if [ "$w" = 0 ]; then OK "start-up log: no webroot link/folder warnings"; else
    WARN "start-up log: $w warning(s) about webroot links/folders:"; docker logs "$WEB" 2>&1 | grep -A20 '^WARNING' | head -25 | sed 's/^/         /'; fi

echo "== Environment and database (N3, N14)"
for pair in "web:$WEB" "jenkins:$JEN"; do
    name=${pair%%:*}; id=${pair#*:}
    e=$(docker exec "$id" printenv MY_ENV)
    [ "$e" = production ] && OK "$name: MY_ENV=production" || FAIL "$name: MY_ENV='$e' (expected production)"
done
PHPDB='include "config/environment.php"; $r=$GLOBALS["db_connection"]->query("SELECT DATABASE() d, CURRENT_USER() u")->fetch_assoc(); echo "\nRESULT ",$GLOBALS["ENV_NAME"]," ",$r["d"]," ",$r["u"],"\n";'
# On failure show the code's own error line (e.g. Access denied); never the password
dbcheck() {  # label container expected [argv...]
    local label=$1 id=$2 want=$3; shift 3
    local out r; out=$(docker exec -w /var/www/html/eol_php8_code "$id" php -r "$PHPDB" "$@" 2>&1)
    r=$(printf '%s\n' "$out" | grep '^RESULT')
    if [ "$r" = "RESULT $want" ]; then OK "$label: $want"
    else FAIL "$label: expected '$want', got '${r#RESULT }' $(printf '%s\n' "$out" | grep -m1 -iE 'denied|error|exception' | cut -c1-160)"; fi
}
dbcheck "web code" "$WEB" "production eol_production eol_app@%"
dbcheck "Jenkins job code" "$JEN" "jenkins_production eol_production eol_app@%" jenkins
g=$(docker exec "$DB" sh -c 'MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -u root -N -e "SHOW GRANTS FOR eol_app@\"%\""' 2>/dev/null | grep -v 'GRANT USAGE ON \*\.\*')
# (mysql -N prints the backslash in `eol\_production` doubled)
if [ "$(printf '%s\n' "$g" | grep -c .)" = 1 ] && printf '%s\n' "$g" | grep -qE '^GRANT ALL PRIVILEGES ON `eol\\*_production`\.\* TO `eol_app`@`%`$'; then OK "eol_app has rights on eol_production only"
else FAIL "eol_app grants differ from 'ALL on eol_production only': $(echo "$g" | tr '\n' ';')"; fi
n=$(docker exec "$JEN" env | grep -c '^MYSQL_'); [ "$n" = 0 ] && OK "Jenkins has no MYSQL_* variables (N1)" || FAIL "Jenkins has $n MYSQL_* variables"

echo "== Code settings (production.php) seen by Jenkins jobs"
PHPSET='include "config/environment.php"; echo "\nRESULT|",JENKINS_DOMAIN,"|",GNPARSER_PATH,"|",is_executable(GNPARSER_PATH)?1:0,"|",DUMPS_LOCAL_PATH,"|",is_dir(DUMPS_LOCAL_PATH)?1:0,"\n";'
IFS='|' read -r _ jd gp gx dp dx <<< "$(docker exec -w /var/www/html/eol_php8_code "$JEN" php -r "$PHPSET" jenkins 2>&1 | grep '^RESULT')"
[ "$jd" = jenkins:8080 ] && OK "JENKINS_DOMAIN=jenkins:8080 (N12)" || FAIL "JENKINS_DOMAIN='$jd' (expected jenkins:8080)"
[ "$gx" = 1 ] && OK "GNPARSER_PATH=$gp exists" || FAIL "GNPARSER_PATH='$gp' is not an executable in the container"
[ "$dx" = 1 ] && OK "DUMPS_LOCAL_PATH=$dp exists" || WARN "DUMPS_LOCAL_PATH='$dp' does not exist (TreatmentBank jobs; copy /extra/dumps)"
PHPTOK='include "config/environment.php"; $c=curl_init("http://".JENKINS_USER_TOKEN."@".JENKINS_DOMAIN."/api/json"); curl_setopt_array($c,[CURLOPT_RETURNTRANSFER=>1,CURLOPT_TIMEOUT=>10]); curl_exec($c); echo "\nRESULT ",curl_getinfo($c,CURLINFO_HTTP_CODE)," ",explode(":",JENKINS_USER_TOKEN)[0],"\n";'
read -r _ hc tu <<< "$(docker exec -w /var/www/html/eol_php8_code "$WEB" php -r "$PHPTOK" 2>&1 | grep '^RESULT')"
[ "$hc" = 200 ] && OK "web → Jenkins login as '$tu' works (H3, N12)" || FAIL "web → Jenkins as '$tu' → HTTP $hc: create the web-trigger token in Jenkins and put it in production.php"

echo "== Jenkins (B1, H3, N7)"
jl=$(docker logs "$JEN" 2>&1)
printf '%s\n' "$jl" | grep -q 'Jenkins is fully up and running' && OK "Jenkins is fully up" || FAIL "Jenkins not fully up yet (check docker logs)"
n=$(printf '%s\n' "$jl" | grep -c 'Failed Loading plugin'); [ "$n" = 0 ] && OK "no plugin load failures" || FAIL "$n 'Failed Loading plugin' lines"
n=$(printf '%s\n' "$jl" | grep -c SEVERE); [ "$n" = 0 ] && OK "no SEVERE log lines" || WARN "$n SEVERE log lines (docker logs jenkins | grep SEVERE)"
c=$(docker exec "$JEN" curl -s -m 10 -o /dev/null -w '%{http_code}' http://localhost:8080/login); [ "$c" = 200 ] && OK "Jenkins login page 200" || FAIL "Jenkins login page → $c"
cfg=$(docker exec "$JEN" cat /var/jenkins_home/config.xml 2>/dev/null)
printf '%s\n' "$cfg" | grep -q '<slaveAgentPort>-1</slaveAgentPort>' && OK "inbound agent TCP port disabled" || FAIL "inbound agent TCP port is not disabled (Security → Agents)"
printf '%s\n' "$cfg" | grep -q 'ProjectMatrixAuthorizationStrategy\|GlobalMatrixAuthorizationStrategy' && OK "matrix authorization in use" || FAIL "Jenkins is not using matrix authorization (H3)"

echo "== Tools"
for pair in "web:$WEB" "jenkins:$JEN"; do
    name=${pair%%:*}; id=${pair#*:}
    v=$(docker exec "$id" php -r 'echo PHP_VERSION;'); docker exec "$id" php -r 'exit(version_compare(PHP_VERSION,"8.4.27",">=")?0:1);' && OK "$name: PHP $v" || FAIL "$name: PHP $v (expected ≥ 8.4.27)"
    docker exec "$id" sh -c 'echo "Homo sapiens L." | gnparser -f compact' 2>/dev/null | grep -q '"parsed":true' && OK "$name: gnparser parses names" || FAIL "$name: gnparser does not work"
done

echo "== Limits and logs (M6)"
for pair in "db:$DB:DB_MEM_LIMIT:2g" "web:$WEB:WEB_MEM_LIMIT:6g" "jenkins:$JEN:JENKINS_MEM_LIMIT:32g"; do
    IFS=: read -r name id var def <<< "$pair"
    want=$(envval "$var"); want=${want:-$def}
    m=$(docker inspect -f '{{.HostConfig.Memory}}' "$id"); g=$(awk -v m="$m" 'BEGIN{printf "%g", m/1073741824}')
    [ "$m" -gt 0 ] && OK "$name memory limit ${g}g (expected $want)" || FAIL "$name has no memory limit"
    l=$(docker inspect -f '{{.HostConfig.LogConfig.Type}} {{index .HostConfig.LogConfig.Config "max-size"}} {{index .HostConfig.LogConfig.Config "max-file"}}' "$id")
    [ "$l" = "json-file 50m 3" ] && OK "$name Docker log: json-file 50m × 3" || FAIL "$name Docker log settings: $l"
done
AL=$(envval APACHE_LOGS)
if [ -n "$AL" ] && [ -f "$AL/access.log" ]; then OK "Apache access log at $AL/access.log"
elif [ -n "$AL" ]; then WARN "no $AL/access.log yet (it appears after the first request)"; fi

echo
echo "Summary: $ok OK, $warn WARN, $fail FAIL"
[ "$fail" = 0 ]
