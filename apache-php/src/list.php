<?php
// Recursively list files under /var/www/html, or under an optional subpath.
// Examples:
//   list.php
//   list.php?path=resources/
//   list.php?path=content_server/resources/cache/
//   list.php?path=resources/cache/
echo "<pre>";

$base = realpath('/var/www/html');
if ($base === false) {
    echo "Base path error: /var/www/html not found";
    echo "</pre>";
    exit;
}

$requested = isset($_GET['path']) ? trim((string) $_GET['path']) : '';

if ($requested === '') {
    $path = $base;
    echo "Listing: {$path}\n\n";
} else {
    $requested = trim($requested, '/');
    $candidate = $base . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $requested);
    $path = realpath($candidate);

    if ($path === false || !is_dir($path)) {
        echo "Path error: not found or not a directory: /{$requested}\n";
        echo "Resolved candidate: {$candidate}\n";
        echo "</pre>";
        exit;
    }

    // Prevent directory traversal outside the web root
    if (strpos($path, $base) !== 0) {
        echo "Path error: access denied outside web root\n";
        echo "</pre>";
        exit;
    }

    echo "Listing: {$path}\n";
    echo "Requested path: /{$requested}/\n\n";
}

try {
    $directory = new RecursiveDirectoryIterator($path, RecursiveDirectoryIterator::SKIP_DOTS);

    $objects = new RecursiveIteratorIterator(
        $directory,
        RecursiveIteratorIterator::SELF_FIRST,
        RecursiveIteratorIterator::CATCH_GET_CHILD
    );

    foreach ($objects as $name => $object) {
        echo $name . "\n";
    }
} catch (Exception $e) {
    echo "Listing error: " . $e->getMessage();
}

echo "</pre>";
echo "<br>-- End --<br>";
?>