<?php
declare(strict_types=1);

require __DIR__ . '/../../app/bootstrap.php';

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'GET') {
    json_response([
        'authenticated' => !empty($_SESSION['admin_id']),
        'username' => $_SESSION['admin_username'] ?? null,
        'csrf_token' => csrf_token(),
    ]);
}
if (($_SERVER['REQUEST_METHOD'] ?? '') !== 'POST') {
    header('Allow: GET, POST');
    json_response(['error' => 'Metode tidak didukung.'], 405);
}
$input = request_json();
require_csrf($input);
$action = (string) ($input['action'] ?? 'login');
if ($action === 'logout') {
    require_admin();
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'], $params['secure'], $params['httponly']);
    }
    session_destroy();
    json_response(['ok' => true]);
}
$username = trim((string) ($input['username'] ?? ''));
$password = (string) ($input['password'] ?? '');
if ($username === '' || $password === '' || mb_strlen($username) > 60 || strlen($password) > 200) {
    json_response(['error' => 'Nama pengguna atau kata sandi belum benar.'], 422);
}
try {
    $stmt = db()->prepare('SELECT id_admin, nama_pengguna, hash_kata_sandi FROM admins WHERE nama_pengguna=? LIMIT 1');
    $stmt->execute([$username]);
    $admin = $stmt->fetch();
    if (!$admin || !password_verify($password, $admin['hash_kata_sandi'])) {
        usleep(250000);
        json_response(['error' => 'Nama pengguna atau kata sandi salah.'], 401);
    }
    session_regenerate_id(true);
    $_SESSION['admin_id'] = (int) $admin['id_admin'];
    $_SESSION['admin_username'] = $admin['nama_pengguna'];
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    db()->prepare('UPDATE admins SET login_terakhir=CURRENT_TIMESTAMP WHERE id_admin=?')->execute([$admin['id_admin']]);
    json_response(['ok' => true, 'username' => $admin['nama_pengguna'], 'csrf_token' => $_SESSION['csrf_token']]);
} catch (PDOException $error) {
    error_log('FoodMap auth database error: ' . $error->getMessage());
    json_response(['error' => 'Database belum siap. Jalankan tools/import_database.php.'], 503);
}
