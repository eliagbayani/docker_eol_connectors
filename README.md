# docker_eol_connectors

For machines that will host the EOL connectors.
A docker-compose file with three services:

1. Apache/2.4.62 + PHP 8.2.26
2. MySQL 8.4.3
3. Jenkins 2.462.3

## Steps

1. Download the file, open the folder.
2. Rename the `.env_sample` to `.env` and enter your information.
   - For Mac, to see the hidden files press `cmd+shit+period`.
4. From terminal, within the folder where `docker-compose.yml` is located run: `$ docker-compose up`
5. To test Apache + PHP + MySQL:
      - Edit `test.php` from your **WEBROOT_PATH**. Enter the **MYSQL_ROOT_PW** you entered in your `.env` file.
        
              $pass = 'root_pw';
        
      - Go to browser: http://localhost:81/test.php
        - You should see a list of four names.
6. To test Jenkins:

   1. Go to browser: http://localhost:8081
   2. Follow instructions to initialize your Jenkins.
   3. To test PHP + MySQL + Jenkins

      1. From **Dashboard**, create a **New Item**
      2. Choose **Freestyle project**
      3. Under **Build Steps**, choose **Execute shell**
      4. Enter these three lines:
        
               cd /webroot 
               php -v 
               php test.php

        
         
      6. Then run **Build Now**
      7. This should output the same information as: http://localhost:81/test.php

7. To test MySQL from host:
        
         Host = localhost
         Port = 4001
         User Name = root
         Password = {MYSQL_ROOT_PW}
               
        
9. To stop containers run: `$ docker-compose down`
