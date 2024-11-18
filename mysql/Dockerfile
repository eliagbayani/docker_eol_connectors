FROM mysql:8.4.3-oraclelinux9
# https://hub.docker.com/layers/library/mysql/8.4.3-oraclelinux9/images/sha256-71da9b9b29db60ff36bae7c55b517428c86f56f97832b6cab5eb207e7e3ab5f8?context=explore

# FROM mysql:8.4.3-oracle

# Required. This is important:
# Without it, will have an error: Plugin 'mysql_native_password' is not loaded
COPY enable-mysql-native-password.cnf /etc/mysql/conf.d/





# ============================================== copied template
# I got an error: ERROR [db internal] load metadata for docker.io/library/mysql:8.0-debian   
# vi ~/.docker/config.json
# deleted this line: "credsStore": "desktop",
# but didn't work

# RUN --mysql-native-password=ON
# RUN mysql -uroot -pmyXXX --default-authentication-plugin=mysql_native_password

# RUN cd /home
# RUN echo "ALTER USER 'root' IDENTIFIED WITH mysql_native_password BY 'myXXX';" > eli.sql

