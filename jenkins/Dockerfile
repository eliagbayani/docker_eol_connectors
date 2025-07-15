# FROM jenkins/jenkins:2.414.3-jdk17

# FROM jenkins/jenkins:2.462.3-jdk11
# -> worked OK but Java 11 is no longer supported. Java 11 end of life in Jenkins.

FROM jenkins/jenkins:jdk17
# -> https://hub.docker.com/layers/jenkins/jenkins/jdk17/images/sha256-3f445a481e471c4342c08d3545c0350283060ad9d41be779941a6bf850075222


# ---------------- start sol'n for permission error
# ARG JENKINS_HOME_FROM_COMPOSE
# USER root
# RUN mkdir ${JENKINS_HOME_FROM_COMPOSE}
# RUN chown 1000 ${JENKINS_HOME_FROM_COMPOSE}
# RUN chmod 777 ${JENKINS_HOME_FROM_COMPOSE}
# USER jenkins
# ---------------- -end-

COPY --chown=jenkins:jenkins executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
# eagbayani j173

COPY --chown=jenkins:jenkins /src/gnparser /bin/gnparser
# todo: try to download and extract gnparser

# from: https://php.watch/articles/install-php82-ubuntu-debian
# if we want to install via apt
USER root
RUN apt-get update
RUN apt-get install file -y     # - important addition

# install zip packages, curl, etc:
RUN apt install zip unzip -y
RUN apt-get install curl -y
# RUN apt-get install iputils-ping -y
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
# OR
# RUN apt install libapache2-mod-php8.2

# sudo yum install php php-common 
# sudo yum install php php-cgi .... { , , , , , , }
RUN apt install -y php8.2-mysqlnd php8.2-pdo php8.2-xml php8.2-bcmath


# install zip packages, curl, etc:
RUN apt install -y php8.2-zip 
# php8.2-unzip
# RUN apt-get install iputils-ping -y
# RUN apt install -y php8.2-wget


# php8.2-pear - not located
# php8.2-json - not located

RUN a2enconf php8.2-fpm


## trying to fix Jenkins /tmp permissions
# RUN chown -R root:jenkins /var/tmp
# RUN chown -R jenkins /tmp


# - just proof of variable passing
ARG JENKINS_TMP_FROM_COMPOSE    
RUN echo " to display value only: "${JENKINS_TMP_FROM_COMPOSE}""


# drop back to the regular jenkins user - good practice
USER jenkins