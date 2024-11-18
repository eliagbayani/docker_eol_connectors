# FROM jenkins/jenkins:2.414.3-jdk17
FROM jenkins/jenkins:2.462.3-jdk11
COPY --chown=jenkins:jenkins executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

# Docker official Jenkins:
# -- https://hub.docker.com/r/jenkins/jenkins
# Jenkions and JDK versions:
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
