#!/bin/sh

# current working dir is /var/www/html; declared as WORKING_DIR in Dockerfile for apache-php
echo "pwd: " 
pwd #this is the Linux command: print working directory
echo "PWD: " + ${PWD}
echo "TARGET_PATH: " + ${TARGET_PATH}
ls -lt

[ -f ${TARGET_PATH}/test.php ]    && echo "File already exists (test.php)"    || cp /tmp/test.php ${TARGET_PATH}
cp /tmp/info.php ${TARGET_PATH}

# This will continue the container. Without it, the container will exit.
apache2-foreground
