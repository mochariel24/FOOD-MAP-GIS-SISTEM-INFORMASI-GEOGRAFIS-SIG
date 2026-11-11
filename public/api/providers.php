<?php
declare(strict_types=1);

require __DIR__ . '/../../app/bootstrap.php';

function make_slug(string $text): string
{
    $text = mb_strtolower(trim($text), 'UTF-8');
    $text = preg_replace('/[^\pL\pN]+/u', '-', $text) ?? '';
    return trim($text, '-') ?: 'penyedia-makanan';
}

function require_category(PDO $pdo, int $id): void
{
    $check = $pdo->prepare('SELECT 1 FROM kategori_makanan WHERE id_kategori = ?');
    $check->execute([$id]);
    if (!$check->fetchColumn()) {
        throw new InvalidArgumentException('Kategori yang dipilih tidak tersedia.');
    }
}

$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
try {
    $pdo = db();
    if ($method === 'GET') {
        $providers = $pdo->query('SELECT p.id_penyedia, p.id_kategori, p.slug, p.nama_penyedia, p.alamat, p.kecamatan, p.latitude, p.longitude, p.jam_buka, p.jam_tutup, p.no_telepon, p.foto, p.sumber_url, p.catatan_sumber, k.nama_kategori FROM penyedia_makanan p JOIN kategori_makanan k ON k.id_kategori=p.id_kategori WHERE p.aktif=1 ORDER BY p.nama_penyedia')->fetchAll();
        $menuRows = $pdo->query('SELECT id_penyedia, id_menu, nama_menu, harga, harga_estimasi, sumber_harga FROM menu_makanan ORDER BY harga, nama_menu')->fetchAll();
        $menusByProvider = [];
        foreach ($menuRows as $menu) {
            $providerId = (int) $menu['id_penyedia'];
            $menusByProvider[$providerId][] = [
                'id' => (int) $menu['id_menu'],
                'name' => $menu['nama_menu'],
                'price' => (int) $menu['harga'],
                'is_estimate' => (bool) $menu['harga_estimasi'],
                'source' => $menu['sumber_harga'],
            ];
        }
        foreach ($providers as &$provider) {
            $provider['id'] = (int) $provider['id_penyedia'];
            $provider['category_id'] = (int) $provider['id_kategori'];
            $provider['latitude'] = (float) $provider['latitude'];
            $provider['longitude'] = (float) $provider['longitude'];
            $provider['district'] = bandung_district_for_point($provider['latitude'], $provider['longitude']) ?? ($provider['kecamatan'] ?: 'Bandung');
            $provider['menus'] = $menusByProvider[$provider['id']] ?? [];
            $prices = array_column($provider['menus'], 'price');
            $provider['min_price'] = $prices ? min($prices) : 0;
            $provider['max_price'] = $prices ? max($prices) : 0;
            unset($provider['id_penyedia'], $provider['id_kategori'], $provider['kecamatan']);
        }
        unset($provider);
        $categories = $pdo->query('SELECT id_kategori AS id, nama_kategori AS name, slug FROM kategori_makanan ORDER BY nama_kategori')->fetchAll();
        json_response(['providers' => $providers, 'categories' => $categories, 'count' => count($providers)]);
    }

    if (!in_array($method, ['POST', 'PUT', 'DELETE'], true)) {
        header('Allow: GET, POST, PUT, DELETE');
        json_response(['error' => 'Metode tidak didukung.'], 405);
    }
    require_admin();
    $input = request_json();
    require_csrf($input);

    if ($method === 'DELETE') {
        $id = filter_var($_GET['id'] ?? null, FILTER_VALIDATE_INT);
        if (!$id) {
            json_response(['error' => 'ID penyedia tidak valid.'], 422);
        }
        $delete = $pdo->prepare('DELETE FROM penyedia_makanan WHERE id_penyedia=?');
        $delete->execute([$id]);
        if ($delete->rowCount() === 0) {
            json_response(['error' => 'Penyedia tidak ditemukan.'], 404);
        }
        json_response(['ok' => true]);
    }

    $provider = normalize_provider($input);
    require_category($pdo, $provider['category_id']);
    $pdo->beginTransaction();
    try {
        if ($method === 'POST') {
            $baseSlug = make_slug($provider['name']);
            $slug = $baseSlug;
            $suffix = 2;
            $findSlug = $pdo->prepare('SELECT 1 FROM penyedia_makanan WHERE slug=?');
            while (true) {
                $findSlug->execute([$slug]);
                if (!$findSlug->fetchColumn()) {
                    break;
                }
                $slug = $baseSlug . '-' . $suffix++;
            }
            $insert = $pdo->prepare('INSERT INTO penyedia_makanan (id_kategori,slug,nama_penyedia,alamat,kecamatan,latitude,longitude,jam_buka,jam_tutup,no_telepon,foto,sumber_url,catatan_sumber) VALUES (:category,:slug,:name,:address,:district,:latitude,:longitude,:open,:close,:phone,:photo,:source_url,:source_note)');
            $insert->execute([
                'category' => $provider['category_id'], 'slug' => $slug, 'name' => $provider['name'],
                'address' => $provider['address'], 'district' => $provider['district'],
                'latitude' => $provider['latitude'], 'longitude' => $provider['longitude'],
                'open' => $provider['open_time'], 'close' => $provider['close_time'],
                'phone' => $provider['phone'], 'photo' => $provider['photo_url'],
                'source_url' => null, 'source_note' => $provider['source_note'],
            ]);
            $id = (int) $pdo->lastInsertId();
        } else {
            $id = filter_var($input['id'] ?? null, FILTER_VALIDATE_INT);
            if (!$id) {
                throw new InvalidArgumentException('ID penyedia tidak valid.');
            }
            $update = $pdo->prepare('UPDATE penyedia_makanan SET id_kategori=:category,nama_penyedia=:name,alamat=:address,kecamatan=:district,latitude=:latitude,longitude=:longitude,jam_buka=:open,jam_tutup=:close,no_telepon=:phone,foto=:photo,catatan_sumber=:source_note WHERE id_penyedia=:id');
            $update->execute([
                'category' => $provider['category_id'], 'name' => $provider['name'], 'address' => $provider['address'],
                'district' => $provider['district'], 'latitude' => $provider['latitude'], 'longitude' => $provider['longitude'],
                'open' => $provider['open_time'], 'close' => $provider['close_time'], 'phone' => $provider['phone'],
                'photo' => $provider['photo_url'], 'source_note' => $provider['source_note'], 'id' => $id,
            ]);
            $exists = $pdo->prepare('SELECT 1 FROM penyedia_makanan WHERE id_penyedia=?');
            $exists->execute([$id]);
            if (!$exists->fetchColumn()) {
                throw new OutOfBoundsException('Penyedia tidak ditemukan.');
            }
            $pdo->prepare('DELETE FROM menu_makanan WHERE id_penyedia=?')->execute([$id]);
        }
        $menuInsert = $pdo->prepare('INSERT INTO menu_makanan (id_penyedia,nama_menu,harga,harga_estimasi,sumber_harga) VALUES (?,?,?,?,?)');
        foreach ($provider['menus'] as $menu) {
            $menuInsert->execute([$id, $menu['name'], $menu['price'], $menu['is_estimate'], $provider['source_note']]);
        }
        $pdo->commit();
        json_response(['ok' => true, 'id' => $id]);
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
} catch (InvalidArgumentException $error) {
    json_response(['error' => $error->getMessage()], 422);
} catch (OutOfBoundsException $error) {
    json_response(['error' => $error->getMessage()], 404);
} catch (PDOException $error) {
    error_log('FoodMap database error: ' . $error->getMessage());
    json_response(['error' => 'Database belum siap atau koneksi terputus. Jalankan tools/import_database.php dan periksa konfigurasi MySQL.'], 503);
} catch (Throwable $error) {
    error_log('FoodMap API error: ' . $error->getMessage());
    json_response(['error' => 'Terjadi kesalahan server. Periksa log PHP.'], 500);
}
