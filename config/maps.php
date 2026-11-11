<?php
declare(strict_types=1);

$defaults = ['api_key' => getenv('GOOGLE_MAPS_API_KEY') ?: ''];
$localFile = __DIR__ . '/maps.local.php';
$local = is_file($localFile) ? require $localFile : [];
return array_replace($defaults, is_array($local) ? $local : []);
