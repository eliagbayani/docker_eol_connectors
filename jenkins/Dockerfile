# FROM jenkins/jenkins:2.414.3-jdk17
# FROM jenkins/jenkins:2.462.3-jdk11
# FROM jenkins/jenkins:jdk17 #used for the longest time
# -> https://hub.docker.com/layers/jenkins/jenkins/jdk17/images/sha256-3f445a481e471c4342c08d3545c0350283060ad9d41be779941a6bf850075222

# FROM jenkins/jenkins:2.525-jdk21
# -> https://hub.docker.com/layers/jenkins/jenkins/2.525-jdk21/images/sha256-6959d893305279906614a2dfb46891f8cb6bddffe390f5c73704924dabd23912

FROM jenkins/jenkins:2.538-jdk21
# -> https://hub.docker.com/layers/jenkins/jenkins/2.538-jdk21/images/sha256-4ce8e89ff3e6c9392fa82b08de98f5b3965c0228f43b90b82cfc2813a1f91f3f

# FROM jenkins/jenkins:2.560-jdk21
# https://hub.docker.com/layers/jenkins/jenkins/2.560-jdk21/images/sha256-b86cbf6e32bbdb55361b4289a8885e6b06547a95899904af4eb8ffb9c26fcad5

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

# install PHP 8.2 from: https://php.watch/articles/install-php82-ubuntu-debian
RUN dpkg -l | grep php | tee packages.txt
RUN apt install apt-transport-https lsb-release ca-certificates wget -y
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg 
RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN apt update

# Expand the curly braces with all extensions necessary.
# RUN apt install php8.2 php8.2-cli php8.2-{bz2,curl,mbstring,intl}
RUN apt install -y php8.2 php8.2-cli php8.2-bz2 php8.2-curl php8.2-mbstring php8.2-intl php8.2-mysqli
RUN apt install -y php8.2-fpm
RUN apt install -y php8.2-mysqlnd php8.2-pdo php8.2-xml php8.2-bcmath
RUN apt install -y php8.2-zip 
RUN apt install -y php8.2-yaml 
RUN a2enconf php8.2-fpm

# =============================================================================

# - just proof of variable passing
ARG JENKINS_TMP_FROM_COMPOSE    
RUN echo " to display value only: "${JENKINS_TMP_FROM_COMPOSE}""

# =============================================================================
# gnparser — arch follows image platform (amd64 → linux-x86, arm64 → linux-arm)
# Override: --build-arg GNPARSER_URL=... or set GNPARSER_URL in .env for Compose
ARG GNPARSER_VERSION=1.15.0
ARG TARGETARCH
ARG GNPARSER_URL=
RUN set -eux; \
    if [ -n "${GNPARSER_URL}" ]; then \
      URL="${GNPARSER_URL}"; \
    else \
      case "${TARGETARCH}" in \
        amd64) GNPARSER_ARCH=x86 ;; \
        arm64) GNPARSER_ARCH=arm ;; \
        *) echo "Unsupported TARGETARCH: ${TARGETARCH}"; exit 1 ;; \
      esac; \
      URL="https://github.com/gnames/gnparser/releases/download/v${GNPARSER_VERSION}/gnparser-v${GNPARSER_VERSION}-linux-${GNPARSER_ARCH}.tar.gz"; \
    fi; \
    wget -qO /tmp/gnparser.tar.gz "${URL}"; \
    tar -xzf /tmp/gnparser.tar.gz -C /tmp; \
    mv /tmp/gnparser /usr/local/bin/gnparser; \
    chmod 755 /usr/local/bin/gnparser; \
    rm -f /tmp/gnparser.tar.gz
# =============================================================================

# drop back to the regular jenkins user - good practice
USER jenkins