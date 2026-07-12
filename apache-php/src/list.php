<?php
echo "<pre>";
// This will recursively list everything in the web directory
$path = realpath('/var/www/html');
$objects = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($path), RecursiveIteratorIterator::SELF_FIRST);
foreach($objects as $name => $object){
    echo $name . "\n";
}
echo "</pre>";
?>
