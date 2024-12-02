<?php
$host = 'db';
$user = 'root';
$pass = 'my173';
$db = 'Employees';
if($mysqli = new mysqli($host, $user, $pass, $db)) {
    echo "\nDatabase connected. OK\n";
    $result = $mysqli->query("SELECT * FROM employees_tbl;"); 
    // echo "<br>Rows: " . mysqli_num_rows($result); //same effect
    echo "<br>Rows: " . $result->num_rows;
    while($r = $result->fetch_assoc()) {
        echo "<br>\n";
        echo " - " . $r['first_name'] . " " . $r['last_name'];
    }
    echo "<br>\n";
    // $result->free(); or close()
    $result->close();
}
?>