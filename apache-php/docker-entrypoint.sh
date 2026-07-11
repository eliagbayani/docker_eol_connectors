#!/bin/sh

[ -f ${PWD}/test.php ]    && echo "File already exists (test.php)"    || cp /tmp/test.php ${PWD}
cp /tmp/info.php ${PWD}

apache2-foreground