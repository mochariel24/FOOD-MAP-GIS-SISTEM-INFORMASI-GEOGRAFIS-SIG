<?php
declare(strict_types=1);

require __DIR__ . '/../app/bootstrap.php';

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "Jalankan skrip ini dari terminal.\n");
    exit(1);
}
$username = trim($argv[1] ?? 'admin');
if (!preg_match('/^[A-Za-z0-9_.-]{3,60}$/', $username)) {
    fwrite(STDERR, "Nama pengguna harus 3–60 karakter (huruf, angka, titik, _ atau -).\n");
    exit(1);
}
$password = rtrim(strtr(base64_encode(random_bytes(15)), '+/', 'AZ'), '=');
try {
    $stmt = db()->prepare('INSERT INTO admins (nama_pengguna, hash_kata_sandi) VALUES (:username, :hash) ON DUPLICATE KEY UPDATE hash_kata_sandi=VALUES(hash_kata_sandi)');
    $stmt->execute(['username' => $username, 'hash' => password_hash($password, PASSWORD_DEFAULT)]);
    fwrite(STDOUT, "Akun admin siap. Simpan kredensial ini sekarang:\nPengguna: {$username}\nKata sandi: {$password}\nJalankan ulang skrip untuk mereset kata sandi.\n");
} catch (Throwable $error) {
    fwrite(STDERR, "Gagal membuat admin: {$error->getMessage()}\n");
    exit(1);
}
