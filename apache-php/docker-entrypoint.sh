#!/bin/sh

# current working dir is /var/www/html; declared as WORKING_DIR in Dockerfile for apache-php
echo ${PWD}
echo ${TARGET_PATH}
ls -lt

[ -f ${TARGET_PATH}/test.php ]    && echo "File exists already (test.php)"    || cp test.php ${TARGET_PATH}

cp info.php ${TARGET_PATH}

# This will continue the container. Without it, the container will exit.
apache2-foreground
