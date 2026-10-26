#!/bin/bash
# Runs once, on first init of an empty data dir. Reads the password from the
# container env at runtime, so it is never stored in the image.
set -e
MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysql -uroot --protocol=socket <<SQL
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
SQL
