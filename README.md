# docker_eol_connectors

For machines that will host the EOL connectors.
A docker-compose file with three services:

1. Apache/2.4.62 + PHP 8.2.26
2. MySQL 8.4.3
3. Jenkins 2.462.3

## Steps

1. Download the file, open the folder.
2. Rename the .env_sample to .env and enter your information.
3. $ docker-compose up
4. To test Apache + PHP + MySQL: Go to browser: http://localhost:81/test.php
5. To test Jenkins:

   1. Go to browser: http://localhost:8081
   2. Follow instructions to initialize your Jenkins.
   3. To test PHP + MySQL + Jenkins

      1. Create a New Item
      2. Choose 'Freestyle project'
      3. Under 'Build Steps', choose 'Execute shell'
      4. Enter these lines:

        <code>
           cd /webroot
           php -v
           php test.php               
        </code>

      5. Then run 'Build Now'
      6. This should output the same information as: http://localhost:81/test.php

6. $ docker-compose down
