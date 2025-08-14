# Docker for EOL Connectors

For machines that will host the EOL connectors.
A docker-compose file with three services:

1. Apache/2.4.62 + PHP 8.2.26
2. MySQL 8.4.3
3. Jenkins 2.462.3

## Steps

1. Download the zip file, unzip, open the folder.
2. Rename the file `.env_sample` to `.env` and enter your information.
   - For Mac, to see the hidden files press `cmd+shift+period`.
   - Make sure that MYSQL_DATA_DIR folder is empty, so that the required database/tables will be created.
3. From terminal, within the folder where `docker-compose.yml` is located run: `$ docker-compose up`
4. To test Apache + PHP + MySQL:
   - Edit `test_develoment.php or test_production.php` from your **WEBROOT_PATH**. Enter the **MYSQL_ROOT_PW** you entered in your `.env` file.
     ```sh
     $pass = 'mysql_root_password';
     ```
   - Go to browser: http://localhost:81/test_development.php
     - You should see a list of four names.
5. To test Jenkins:

   1. Go to browser: http://localhost:8081
   2. Follow instructions to initialize your Jenkins.
   3. To test PHP + MySQL + Jenkins

      1. From **Dashboard**, create a **New Item**
      2. Choose **Freestyle project**
      3. Under **Build Steps**, choose **Execute shell**
      4. Enter these three lines:
         ```sh
         cd /var/www/html
         php -v
         php test_development.php
         ```
      5. Then run **Build Now**
      6. This should output the same information as: http://localhost:81/test_development.php

6. To test MySQL from the host:
   ```sh
   Host = localhost
   Port = 4001
   User Name = root
   Password = {MYSQL_ROOT_PW}
   ```
7. - To remove containers run: `$ docker-compose down`
   - To stop containers run: `$ docker-compose stop`
   - To test a command without changing your application stack state.: `$ docker compose --dry-run up --build -d`

8. Other commands:

   - To stop a service from compose: `docker stop {container id of that service}`
   - To restart a service from compose: `docker-compose restart {service name}`

     This does not need to delete the container nor the image anymore.

   - To see all running containers: `docker ps`

9. Login to a container:

   - option 1: `docker start -i {container id}`
     -> by default logins as root
   - option 2: `docker exec -it -u john {container id} bash`
     -> login as user john
   - option 3: `docker exec -it {container id} bash`
     -> login as root
