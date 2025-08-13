<?php
$host = 'db';               //do not change
$user = 'root';             //do not change
$pass = 'root_password';    //use value from .env file {MYSQL_ROOT_PW}
$db = 'eol_development';    //do not change
if($mysqli = new mysqli($host, $user, $pass, $db)) {
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
echo "<hr>";
$out = shell_exec("gnparser 'Gadus morhua Linnaeus, 1758' -f pretty");
echo "\n<pre>$out</pre>\n";
?>