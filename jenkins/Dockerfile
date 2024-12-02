# FROM jenkins/jenkins:2.414.3-jdk17
FROM jenkins/jenkins:2.462.3-jdk11

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

# from: https://php.watch/articles/install-php82-ubuntu-debian
# if we want to install via apt
USER root
RUN apt-get update

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

RUN a2enconf php8.2-fpm

# drop back to the regular jenkins user - good practice
USER jenkins