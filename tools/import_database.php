<?php
declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "Jalankan skrip ini dari terminal.\n");
    exit(1);
}

try {
    $pdo = db(true);
    $root = dirname(__DIR__);
    $additionalOnly = in_array('--additional-only', $argv, true);
    $paths = $additionalOnly
        ? [$root . '/database/additional_places.sql']
        : [$root . '/database/schema.sql', $root . '/database/seed.sql', $root . '/database/additional_places.sql'];
    foreach ($paths as $path) {
        $sqlFile = file_get_contents($path);
        if ($sqlFile === false) {
            throw new RuntimeException('Berkas SQL tidak ditemukan: ' . basename($path));
        }
        $statements = preg_split('/;\s*(?:\R|$)/', trim($sqlFile));
        foreach ($statements ?: [] as $statement) {
            $statement = preg_replace('/^\s*--.*$/m', '', trim($statement));
            if ($statement !== '') {
                $pdo->exec($statement);
            }
        }
    }
    $counts = $pdo->query('SELECT (SELECT COUNT(*) FROM penyedia_makanan) providers, (SELECT COUNT(*) FROM menu_makanan) menus')->fetch();
    $verb = $additionalOnly ? 'Database foodmap_gis diperbarui' : 'Database foodmap_gis siap';
    fwrite(STDOUT, "$verb: {$counts['providers']} penyedia, {$counts['menus']} menu.\n");
} catch (Throwable $error) {
    fwrite(STDERR, "Gagal menyiapkan database: {$error->getMessage()}\n");
    exit(1);
}
