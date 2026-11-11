<?php
declare(strict_types=1);

if (session_status() !== PHP_SESSION_ACTIVE) {
    $https = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
    session_name('foodmap_session');
    session_set_cookie_params([
        'lifetime' => 0,
        'path' => '/',
        'secure' => $https,
        'httponly' => true,
        'samesite' => 'Lax',
    ]);
    session_start();
}

function db(bool $withoutDatabase = false): PDO
{
    static $connections = [];
    $config = require __DIR__ . '/../config/database.php';
    $key = $withoutDatabase ? 'server' : 'database';
    if (isset($connections[$key])) {
        return $connections[$key];
    }
    $dsn = 'mysql:host=' . $config['host'] . ';port=' . $config['port'] . ';charset=' . $config['charset'];
    if (!$withoutDatabase) {
        $dsn .= ';dbname=' . $config['database'];
    }
    $connections[$key] = new PDO($dsn, $config['username'], $config['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
    return $connections[$key];
}

function json_response(array $body, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
}

function request_json(): array
{
    $raw = file_get_contents('php://input');
    $decoded = json_decode($raw ?: '{}', true);
    return is_array($decoded) ? $decoded : [];
}

function csrf_token(): string
{
    if (empty($_SESSION['csrf_token'])) {
        $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    }
    return (string) $_SESSION['csrf_token'];
}

function require_csrf(array $data): void
{
    $sent = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? ($data['_csrf'] ?? '');
    if (!is_string($sent) || !hash_equals(csrf_token(), $sent)) {
        json_response(['error' => 'Sesi keamanan kedaluwarsa. Muat ulang halaman dan coba lagi.'], 403);
    }
}

function require_admin(): void
{
    if (empty($_SESSION['admin_id'])) {
        json_response(['error' => 'Silakan masuk sebagai admin terlebih dahulu.'], 401);
    }
}

/** Return the matching Bandung district name, or null when the point is outside the city. */
function bandung_district_for_point(float $lat, float $lng): ?string
{
    static $features = null;
    if ($features === null) {
        $path = __DIR__ . '/../data/kecamatan_bandung.geojson';
        $json = is_file($path) ? json_decode((string) file_get_contents($path), true) : null;
        $features = is_array($json['features'] ?? null) ? $json['features'] : [];
    }
    foreach ($features as $feature) {
        $name = $feature['properties']['NAMA_KEC'] ?? null;
        $geometry = $feature['geometry'] ?? [];
        $polygons = ($geometry['type'] ?? '') === 'Polygon'
            ? [$geometry['coordinates'] ?? []]
            : (($geometry['type'] ?? '') === 'MultiPolygon' ? ($geometry['coordinates'] ?? []) : []);
        foreach ($polygons as $polygon) {
            $insidePolygon = true;
            foreach ($polygon as $ringIndex => $ring) {
                $insideRing = point_in_ring($lng, $lat, $ring);
                if ($ringIndex === 0 && !$insideRing) {
                    $insidePolygon = false;
                    break;
                }
                if ($ringIndex > 0 && $insideRing) {
                    $insidePolygon = false;
                    break;
                }
            }
            if ($insidePolygon && is_string($name)) {
                return mb_convert_case(mb_strtolower($name, 'UTF-8'), MB_CASE_TITLE, 'UTF-8');
            }
        }
    }
    return null;
}

function point_in_ring(float $x, float $y, array $ring): bool
{
    $inside = false;
    $count = count($ring);
    for ($i = 0, $j = $count - 1; $i < $count; $j = $i++) {
        $xi = (float) ($ring[$i][0] ?? 0);
        $yi = (float) ($ring[$i][1] ?? 0);
        $xj = (float) ($ring[$j][0] ?? 0);
        $yj = (float) ($ring[$j][1] ?? 0);
        $crosses = (($yi > $y) !== ($yj > $y))
            && ($x < (($xj - $xi) * ($y - $yi) / (($yj - $yi) ?: 1e-20)) + $xi);
        if ($crosses) {
            $inside = !$inside;
        }
    }
    return $inside;
}

function normalize_provider(array $input): array
{
    $name = trim((string) ($input['name'] ?? ''));
    $categoryId = filter_var($input['category_id'] ?? null, FILTER_VALIDATE_INT);
    $address = trim((string) ($input['address'] ?? ''));
    $lat = filter_var($input['latitude'] ?? null, FILTER_VALIDATE_FLOAT);
    $lng = filter_var($input['longitude'] ?? null, FILTER_VALIDATE_FLOAT);
    $open = trim((string) ($input['open_time'] ?? ''));
    $close = trim((string) ($input['close_time'] ?? ''));
    $phone = trim((string) ($input['phone'] ?? ''));
    $photo = trim((string) ($input['photo_url'] ?? ''));
    $source = trim((string) ($input['source_note'] ?? ''));
    $menus = is_array($input['menus'] ?? null) ? $input['menus'] : [];
    if ($name === '' || mb_strlen($name) > 120) {
        throw new InvalidArgumentException('Nama penyedia wajib diisi (maksimal 120 karakter).');
    }
    if (!$categoryId || $address === '' || mb_strlen($address) > 500) {
        throw new InvalidArgumentException('Kategori dan alamat wajib dipilih/diisi.');
    }
    if ($lat === false || $lng === false || $lat < -6.99 || $lat > -6.82 || $lng < 107.54 || $lng > 107.74) {
        throw new InvalidArgumentException('Koordinat harus berada di sekitar wilayah Kota Bandung.');
    }
    $district = bandung_district_for_point((float) $lat, (float) $lng);
    if ($district === null) {
        throw new InvalidArgumentException('Titik koordinat berada di luar batas Kota Bandung.');
    }
    foreach (['open_time' => $open, 'close_time' => $close] as $label => $value) {
        if ($value !== '' && !preg_match('/^([01]\d|2[0-3]):[0-5]\d$/', $value)) {
            throw new InvalidArgumentException('Format jam operasional tidak valid.');
        }
    }
    if ($phone !== '' && mb_strlen($phone) > 30) {
        throw new InvalidArgumentException('Nomor telepon terlalu panjang.');
    }
    if ($photo !== '' && !preg_match('~^(https://|/assets/)[^\s<>"\']{1,400}$~i', $photo)) {
        throw new InvalidArgumentException('Foto harus berupa URL HTTPS atau jalur aset lokal.');
    }
    $cleanMenus = [];
    foreach ($menus as $menu) {
        if (!is_array($menu)) {
            continue;
        }
        $menuName = trim((string) ($menu['name'] ?? ''));
        $price = filter_var($menu['price'] ?? null, FILTER_VALIDATE_INT);
        if ($menuName === '' && ($price === false || $price === null)) {
            continue;
        }
        if ($menuName === '' || $price === false || $price === null || $price < 1000 || $price > 5000000) {
            throw new InvalidArgumentException('Setiap menu harus memiliki nama dan harga Rp1.000–Rp5.000.000.');
        }
        $cleanMenus[] = [
            'name' => mb_substr($menuName, 0, 120),
            'price' => $price,
            'is_estimate' => !empty($menu['is_estimate']) ? 1 : 0,
        ];
    }
    if (count($cleanMenus) < 3) {
        throw new InvalidArgumentException('Setiap penyedia wajib memiliki sedikitnya 3 menu.');
    }
    if (count($cleanMenus) > 30) {
        throw new InvalidArgumentException('Maksimal 30 menu per penyedia.');
    }
    return [
        'name' => $name,
        'category_id' => (int) $categoryId,
        'address' => $address,
        'latitude' => (float) $lat,
        'longitude' => (float) $lng,
        'district' => $district,
        'open_time' => $open !== '' ? $open : null,
        'close_time' => $close !== '' ? $close : null,
        'phone' => $phone !== '' ? $phone : null,
        'photo_url' => $photo !== '' ? $photo : '/assets/food-placeholder.svg',
        'source_note' => $source !== '' ? mb_substr($source, 0, 500) : 'Ditambahkan melalui admin; verifikasi informasi sebelum publikasi.',
        'menus' => $cleanMenus,
    ];
}
