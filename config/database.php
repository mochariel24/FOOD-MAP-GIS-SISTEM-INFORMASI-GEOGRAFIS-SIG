<?php
declare(strict_types=1);

$defaults = [
    'host' => getenv('FOODMAP_DB_HOST') ?: '127.0.0.1',
    'port' => (int) (getenv('FOODMAP_DB_PORT') ?: 3306),
    'database' => getenv('FOODMAP_DB_NAME') ?: 'foodmap_gis',
    'username' => getenv('FOODMAP_DB_USER') ?: 'root',
    'password' => getenv('FOODMAP_DB_PASSWORD') ?: '',
    'charset' => 'utf8mb4',
];

$localFile = __DIR__ . '/database.local.php';
$local = is_file($localFile) ? require $localFile : [];

return array_replace($defaults, is_array($local) ? $local : []);
