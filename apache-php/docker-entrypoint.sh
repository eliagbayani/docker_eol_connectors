#!/bin/sh
# ARG TARGET_PATH
echo ${PWD}
echo ${TARGET_PATH}
ls -lt
cp test.php ${TARGET_PATH} #not msg

# systemctl restart apache2
# /etc/init.d/apache2 restart

apache2-foreground

