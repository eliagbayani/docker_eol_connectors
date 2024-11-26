# FROM jenkins/jenkins:2.414.3-jdk17
FROM jenkins/jenkins:2.462.3-jdk11

# ARG JENKINS_HOME_USER_ID=0
# ARG JENKINS_HOME_GROUP_ID=0
# RUN groupadd -g $JENKINS_HOME_GROUP_ID jenkins && \
#     useradd -m jenkins -u $JENKINS_HOME_USER_ID -g $JENKINS_HOME_GROUP_ID

COPY --chown=jenkins:jenkins executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
# eagbayani j173

# Docker official Jenkins:
# -- https://hub.docker.com/r/jenkins/jenkins
# Jenkins and JDK versions:
# -- https://www.jenkins.io/doc/book/platform-information/support-policy-java/

# docker run    -p 8080:8080 -p 50000:50000 --restart=on-failure                                   jenkins/jenkins:lts-jdk17
# docker run    -p 8080:8080 -p 50000:50000 --restart=on-failure -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk17
# docker run -d               -p 8080:8080 -p 50000:50000 --restart=on-failure -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts-jdk17
# docker run --name myjenkins -p 8080:8080 -p 50000:50000 --restart=on-failure --env JAVA_OPTS=-Dhudson.footerURL=http://mycompany.com jenkins/jenkins:lts-jdk17


# mkdir data
# cat > data/log.properties <<EOF
# handlers=java.util.logging.ConsoleHandler
# jenkins.level=FINEST
# java.util.logging.ConsoleHandler.level=FINEST
# EOF
# docker run --name myjenkins -p 8080:8080 -p 50000:50000 --restart=on-failure 
#         --env JAVA_OPTS="-Djava.util.logging.config.file=/var/jenkins_home/log.properties" 
#         -v `pwd`/data:/var/jenkins_home 
#         jenkins/jenkins:lts-jdk17

# from: https://php.watch/articles/install-php82-ubuntu-debian
# if we want to install via apt
USER root
# RUN apt-get update && apt-get install -y ruby make more-thing-here
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
