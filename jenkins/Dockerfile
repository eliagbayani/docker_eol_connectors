# FROM jenkins/jenkins:2.414.3-jdk17
# FROM jenkins/jenkins:2.462.3-jdk11
# FROM jenkins/jenkins:jdk17 #used for the longest time
# -> https://hub.docker.com/layers/jenkins/jenkins/jdk17/images/sha256-3f445a481e471c4342c08d3545c0350283060ad9d41be779941a6bf850075222

# FROM jenkins/jenkins:2.525-jdk21
# -> https://hub.docker.com/layers/jenkins/jenkins/2.525-jdk21/images/sha256-6959d893305279906614a2dfb46891f8cb6bddffe390f5c73704924dabd23912

# FROM jenkins/jenkins:2.538-jdk21
# -> https://hub.docker.com/layers/jenkins/jenkins/2.538-jdk21/images/sha256-4ce8e89ff3e6c9392fa82b08de98f5b3965c0228f43b90b82cfc2813a1f91f3f

# FROM jenkins/jenkins:2.568.2-jdk21
FROM jenkins/jenkins:2.580.1-jdk21

# https://hub.docker.com/layers/jenkins/jenkins/2.568.2-jdk21/images/sha256-25a061bfd6a7f954b8c2e0b6d5ad07c33e8e29364f50484ecdc4d4d7bf4800d3
# https://hub.docker.com/layers/jenkins/jenkins/2.580.1-jdk21/images/sha256-5e70c4e8c97025f7784858bb5c4380912fc17e5fa0f0afa1d4833700a08666eb

# =============================================================================
COPY --chown=jenkins:jenkins executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
# eagbayani j173

# from: https://php.watch/articles/install-php82-ubuntu-debian
# if we want to install via apt
USER root
RUN apt-get update
RUN apt-get install file -y     # - important addition
# =============================================================================
# --------------------------- START python
RUN apt-get install python3-full python3-pip -y 
# Add any other Python-related packages or tools you need, e.g. python-pyset python3-flake8 etc.
RUN apt update
RUN [ -d /usr/src/app ] && echo "Folder exists" || mkdir /usr/src/app
RUN pip install --break-system-packages neo4j 
ENV PYTHONUNBUFFERED=1
# --------------------------- END python
# =============================================================================

RUN apt install zip unzip -y
RUN apt-get install curl -y
RUN apt install wget -y

# install PHP 8.4 (was 8.2) from: https://php.watch/articles/install-php82-ubuntu-debian
RUN dpkg -l | grep php | tee packages.txt
RUN apt install apt-transport-https lsb-release ca-certificates wget -y
# M4: sury's key signs only the sury source (signed-by), not every apt source as in trusted.gpg.d
RUN wget -O /usr/share/keyrings/sury-php.gpg https://packages.sury.org/php/apt.gpg
RUN sh -c 'echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN apt update

# Expand the curly braces with all extensions necessary.
# RUN apt install php8.4 php8.4-cli php8.4-{bz2,curl,mbstring,intl}
RUN apt install -y php8.4 php8.4-cli php8.4-bz2 php8.4-curl php8.4-mbstring php8.4-intl php8.4-mysqli
RUN apt install -y php8.4-fpm
RUN apt install -y php8.4-mysqlnd php8.4-pdo php8.4-xml php8.4-bcmath
RUN apt install -y php8.4-zip
# gd: lib/ContentManager.php image handling (the old eol-archive PHP had it)
RUN apt install -y php8.4-gd
RUN apt install -y php8.4-yaml
RUN a2enconf php8.4-fpm

# PHP2Shell (CVE-2026-109618 / CVE-2026-109619, Oct 2026) is fixed in 8.4.27.
# Fail the build if sury gave us an older 8.4.x (e.g. stale cached apt layer -> rebuild with --no-cache).
# Raise this when a newer 8.4.x security release comes out.
ARG PHP_MIN_VERSION=8.4.27
RUN php -r "echo 'PHP ', PHP_VERSION, PHP_EOL; exit(version_compare(PHP_VERSION, '${PHP_MIN_VERSION}', '>=') ? 0 : 1);" \
  || { echo "ERROR: PHP is older than ${PHP_MIN_VERSION}. Rebuild with --no-cache."; exit 1; }

# =============================================================================

# - just proof of variable passing
ARG JENKINS_TMP_FROM_COMPOSE    
RUN echo " to display value only: "${JENKINS_TMP_FROM_COMPOSE}""

# =============================================================================
# gnparser — arch follows image platform (amd64 → linux-x86, arm64 → linux-arm)
# Override: --build-arg GNPARSER_URL=... or set GNPARSER_URL in .env for Compose
# M3: the download must match a known SHA-256 (from the GitHub release, checked by download 2026-10-30).
# For another version or URL, set GNPARSER_SHA256 (in .env for Compose); otherwise the build stops.
ARG GNPARSER_VERSION=1.15.0
ARG TARGETARCH
ARG GNPARSER_URL=
ARG GNPARSER_SHA256=
ARG GNPARSER_SHA256_AMD64=50483cff07afedd9084ee122dc8bb25a454b567e5d99de66d30d7bf7ba3bbe7c
ARG GNPARSER_SHA256_ARM64=80e93745b519faa8e3dec06fc12139991c36a47db70e2597bd7e08e9faa19096
RUN set -eux; \
  case "${TARGETARCH}" in \
  amd64) GNPARSER_ARCH=x86; SHA="${GNPARSER_SHA256_AMD64}" ;; \
  arm64) GNPARSER_ARCH=arm; SHA="${GNPARSER_SHA256_ARM64}" ;; \
  *) echo "Unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
  esac; \
  URL="https://github.com/gnames/gnparser/releases/download/v${GNPARSER_VERSION}/gnparser-v${GNPARSER_VERSION}-linux-${GNPARSER_ARCH}.tar.gz"; \
  if [ -n "${GNPARSER_URL}" ]; then URL="${GNPARSER_URL}"; fi; \
  if [ -n "${GNPARSER_SHA256}" ]; then SHA="${GNPARSER_SHA256}"; fi; \
  wget -qO /tmp/gnparser.tar.gz "${URL}"; \
  if ! echo "${SHA}  /tmp/gnparser.tar.gz" | sha256sum -c -; then \
  echo "gnparser download does not match SHA-256 ${SHA}. For a new version or URL, set GNPARSER_SHA256." >&2; exit 1; \
  fi; \
  tar -xzf /tmp/gnparser.tar.gz -C /tmp; \
  mv /tmp/gnparser /usr/local/bin/gnparser; \
  chmod 755 /usr/local/bin/gnparser; \
  rm -f /tmp/gnparser.tar.gz
# =============================================================================

# drop back to the regular jenkins user - good practice
USER jenkins