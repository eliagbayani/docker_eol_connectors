<?php
/* This is to be used with plain Docker implementation:
$host = 'db';                   //DO NOT change. This is the Docker service name in docker-compose.yml.
$port = 4001;
*/

/* This is to be used for Kubernetes implementation:
$host = 'host.docker.internal'; //DO NOT change. To be used in K8s cluster setup.
$port = 30306;
*/

$user = 'root';                 //DO NOT change
$pass = 'mysql_root_password';  //CHANGE THIS. Use value from .env file {MYSQL_ROOT_PASSWORD}

$db = 'eol_xxx';                //CHANGE THIS. Replace xxx with either 'development' or 'production'. Without the quotes.

if($mysqli = new mysqli($host, $user, $pass, $db, $port)) {
    echo "\nEmployees database connected. OK\n";
    $result = $mysqli->query("SELECT * FROM employees_tbl;"); 
    echo "<br>Rows: " . mysqli_num_rows($result); //same effect
    echo "<br>Rows: " . $result->num_rows;
    while($r = $result->fetch_assoc()) {
        echo "<br>\n";
        echo " - " . $r['first_name'] . " " . $r['last_name'];
    }
    echo "<br>\n";
    $result->close(); //or $result->free();
}
echo "<hr>"; //=============================================================
$out = shell_exec("gnparser 'Gadus morhua Linnaeus, 1758' -f pretty");
echo "\n<pre>$out</pre>\n";

echo "<hr>"; //=============================================================
$yaml_string = "
name: 'singular: null'
plural: null
fields:
    price: 'label: Preis'
    company_id:
        label: null
        placeholder: null
";
$array_output = yaml_parse($yaml_string);
echo "\n<pre>\n";
print_r($array_output);
echo "\n</pre>\n";
?>