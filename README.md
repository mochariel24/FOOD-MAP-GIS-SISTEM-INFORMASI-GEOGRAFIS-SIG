# FoodMap GIS Bandung

Aplikasi Web GIS untuk mencari penyedia makanan di Kota Bandung berdasarkan nama, kategori, menu, dan kisaran harga. Lokasi ditampilkan sebagai marker Google Maps dan dapat dibuka sebagai rute.

## Fitur

- Peta Google Maps dengan marker lokasi dari database.
- Direktori dan pencarian penyedia berdasarkan nama, alamat, atau menu.
- Filter kategori, kisaran harga, radius dari lokasi pengguna, dan lima lokasi terdekat.
- Detail alamat, kecamatan, koordinat, jam/telepon jika tersedia, menu, serta tautan rute.
- Login admin dan CRUD penyedia beserta menu.
- Validasi koordinat terhadap poligon kecamatan Kota Bandung.

## Teknologi

PHP 8.1+, MySQL/MariaDB, HTML, CSS, JavaScript, Google Maps JavaScript API, dan GeoJSON batas kecamatan.

## Isi data

Paket data awal berisi 25 penyedia dan 75 menu. Dua puluh lokasi berasal dari pencarian Photon/OpenStreetMap; lima lokasi tambahan memakai informasi usaha dan menu yang dirujuk pada sumber resmi di berkas SQL. Menu/harga pada 19 lokasi awal berstatus **estimasi** untuk demonstrasi dan bukan daftar harga resmi. Periksa kembali lokasi, jam buka, telepon, dan harga sebelum memakai aplikasi sebagai direktori publik.

Peta batas kecamatan disimpan di `data/kecamatan_bandung.geojson`. Atribusi OpenStreetMap tersedia pada aplikasi. Catatan sumber dan batasan data lebih lengkap ada di [`docs/AUDIT_DAN_KESESUAIAN.md`](docs/AUDIT_DAN_KESESUAIAN.md).

## Persyaratan

- PHP 8.1 atau lebih baru dengan ekstensi `pdo_mysql` dan `mbstring`.
- MySQL 8+ atau MariaDB 10.4+.
- Google Maps JavaScript API key untuk menampilkan peta interaktif.
- Koneksi internet untuk Google Maps dan Google Fonts.

## Menjalankan di Windows/XAMPP

Jalankan MySQL melalui XAMPP Control Panel, lalu buka PowerShell di folder proyek ini.

1. Konfigurasi database. Nilai bawaan adalah `127.0.0.1:3306`, database `foodmap_gis`, pengguna `root`, dan kata sandi kosong. Jika pengaturan Anda berbeda, salin contoh konfigurasi lokal:

   ```powershell
   Copy-Item config/database.local.example.php config/database.local.php
   ```

   Edit `config/database.local.php` sesuai pengaturan MySQL Anda. Berkas lokal ini tidak untuk diunggah.

2. Buat tabel dan masukkan data awal:

   ```powershell
   php tools/import_database.php
   ```

   Jika database sudah tersedia dan hanya ingin memperbarui lima lokasi tambahan, gunakan:

   ```powershell
   php tools/import_database.php --additional-only
   ```

   Impor penuh mengisi ulang nilai seed dari berkas SQL. Perubahan khusus yang dibuat lewat admin sebaiknya dicadangkan sebelum mengimpor ulang.

3. Buat akun admin:

   ```powershell
   php tools/create_admin.php ardiyanti
   ```

   Terminal menampilkan kata sandi acak satu kali. Simpan dengan aman. Menjalankan perintah ini lagi untuk nama yang sama akan mengganti kata sandinya. Database pada komputer pengembang tidak menyertakan akun admin standar.

4. Aktifkan peta. Salin konfigurasi contoh:

   ```powershell
   Copy-Item config/maps.local.example.php config/maps.local.php
   ```

   Masukkan Google Maps JavaScript API key ke `config/maps.local.php`. Aktifkan Maps JavaScript API dan batasi key dengan HTTP referrer serta API yang diperlukan. Jangan commit key tersebut. Panduan resmi: [membuat API key Google Maps](https://developers.google.com/maps/documentation/javascript/get-api-key).

5. Jalankan server PHP bawaan:

   ```powershell
   php -S 127.0.0.1:8000 -t public
   ```

6. Buka <http://127.0.0.1:8000> di browser dan masuk memakai akun admin yang dibuat pada langkah 3.

Tanpa API key, direktori dan endpoint database tetap dapat digunakan, tetapi peta interaktif tidak akan dimuat. Tautan rute Google Maps tetap tersedia.

## Struktur proyek

```text
FOODMAP GIS BANDUNG/
├── app/                 # Bootstrap, sesi, koneksi, validasi wilayah
├── config/              # Konfigurasi umum dan contoh konfigurasi lokal
├── data/                # GeoJSON batas kecamatan Kota Bandung
├── database/            # Schema dan data seed SQL
├── docs/                # Rancangan, audit data, dan panduan GitHub
├── public/              # Halaman web, API, CSS, JavaScript, aset
└── tools/               # Impor database dan pembuatan admin
```

## Endpoint API

- `GET /api/providers.php` — daftar penyedia, menu, kategori, dan koordinat.
- `POST /api/providers.php` — tambah penyedia dan menu (admin + CSRF).
- `PUT /api/providers.php` — ubah penyedia dan daftar menu (admin + CSRF).
- `DELETE /api/providers.php?id=...` — hapus penyedia (admin + CSRF).
- `GET /api/auth.php` — status sesi dan token CSRF.
- `POST /api/auth.php` — masuk atau keluar admin.

## Berkas penting

- `database/schema.sql` — skema relasional.
- `database/seed.sql` — 20 lokasi awal dan menu demonstrasi.
- `database/additional_places.sql` — lima lokasi tambahan dan menu dengan catatan sumber.
- `docs/DESAIN_APLIKASI.md` — rancangan fitur, alur, dan relasi data.
- `docs/AUDIT_DAN_KESESUAIAN.md` — audit ketentuan dan keterbatasan dataset.
- `docs/PANDUAN_GITHUB.md` — saran nama repo, deskripsi, dan langkah unggah.

## Keamanan sebelum diunggah

`.gitignore` mengecualikan konfigurasi lokal, API key, file `.env`, log, dan dump database lokal `database/foodmap_gis.sql`. Jangan memaksa menambahkan berkas tersebut dengan `git add -f`. Jangan menaruh kata sandi, hash admin, atau API key di README, source code, maupun screenshot.

GitHub Pages tidak dapat menjalankan PHP/MySQL. Untuk demonstrasi online, gunakan hosting yang mendukung PHP dan MySQL/MariaDB serta atur API key dengan pembatasan domain.
