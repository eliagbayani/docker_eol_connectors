# Docker for EOL Connectors

For machines that will host the EOL connectors.
A docker-compose file with four services:

1. Apache/2.4.62 + PHP 8.2.26
2. MySQL 8.4.3
3. Jenkins 2.538-jdk21
4. Neo4j 5.26.8-enterprise
5. Python 3.11.2

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

   1. Go to browser, open Jenkins: http://localhost:8081
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

6. To test MySQL from the host. Use these credentials:
   ```sh
   Host = localhost
   Port = 4001
   User Name = root
   Password = {MYSQL_ROOT_PW}
   ```
7. - To remove containers run: `$ docker-compose down`
   - To stop containers run: `$ docker-compose stop`
   - To test a command without changing your application stack state.: `$ docker compose --dry-run up --build -d`

   To re-create stuff:

   - Recreate containers even if their configuration and image haven't changed: `docker-compose up --build --force-recreate`
   - For specific service: `docker-compose up {service name} --build --force-recreate`
   - Do not use cache when building the image: `docker-compose build --no-cache`
   - Builds the images if they don’t exist, starts the containers in detached mode, forces recreation of the containers, and rebuilds the images even if they exist.: `docker-compose up -d --force-recreate --build`

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

10. To test your Neo4j database server, go to browser open: http://localhost:7474/browser/

11. To test Neo4j + Python + Python driver for Neo4j:

    1. Copy these 4 files from: https://github.com/eliagbayani/eol_python_code
       ```sh
       neo4j_credentials.py
       neo4j_functions.py
       test1.py
       test2.py
       ```
    2. Load it to your {PYTHON_APP} folder you declared in your .env file.
    3. Open Jenkins: http://localhost:8081
    4. From **Dashboard**, create a **New Item**
    5. Choose **Freestyle project**
    6. Under **Build Steps**, choose **Execute shell**
    7. Enter these three lines:
       ```sh
       cd /usr/src/app
       python3 -V
       python3 test1.py
       python3 test2.py
       ```
    8. Then run **Build Now**
    9. You should see this output:

       ```sh
       username: your_username
       password: your_password
       URI: bolt://neo4j:7687
       -Python accessing Neo4j OK-
       ```
