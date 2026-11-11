CREATE DATABASE IF NOT EXISTS foodmap_gis CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE foodmap_gis;

CREATE TABLE IF NOT EXISTS kategori_makanan (
    id_kategori INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(80) NOT NULL,
    slug VARCHAR(90) NOT NULL UNIQUE,
    deskripsi VARCHAR(255) NULL,
    dibuat_pada TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS penyedia_makanan (
    id_penyedia INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_kategori INT UNSIGNED NOT NULL,
    slug VARCHAR(140) NOT NULL UNIQUE,
    nama_penyedia VARCHAR(120) NOT NULL,
    alamat TEXT NOT NULL,
    kecamatan VARCHAR(80) NULL,
    latitude DECIMAL(10,7) NOT NULL,
    longitude DECIMAL(11,7) NOT NULL,
    jam_buka TIME NULL,
    jam_tutup TIME NULL,
    no_telepon VARCHAR(30) NULL,
    foto VARCHAR(500) NOT NULL DEFAULT '/assets/food-placeholder.svg',
    sumber_url VARCHAR(500) NULL,
    catatan_sumber VARCHAR(500) NOT NULL DEFAULT 'Informasi perlu diverifikasi.',
    aktif TINYINT(1) NOT NULL DEFAULT 1,
    dibuat_pada TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_penyedia_kategori FOREIGN KEY (id_kategori)
        REFERENCES kategori_makanan(id_kategori) ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_penyedia_nama (nama_penyedia),
    INDEX idx_penyedia_kategori (id_kategori),
    INDEX idx_penyedia_koordinat (latitude, longitude)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS menu_makanan (
    id_menu INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_penyedia INT UNSIGNED NOT NULL,
    nama_menu VARCHAR(120) NOT NULL,
    harga DECIMAL(12,2) UNSIGNED NOT NULL,
    harga_estimasi TINYINT(1) NOT NULL DEFAULT 1,
    sumber_harga VARCHAR(500) NULL,
    dibuat_pada TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_menu_penyedia FOREIGN KEY (id_penyedia)
        REFERENCES penyedia_makanan(id_penyedia) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE KEY uq_menu_per_penyedia (id_penyedia, nama_menu),
    INDEX idx_menu_harga (harga)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS admins (
    id_admin INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_pengguna VARCHAR(60) NOT NULL UNIQUE,
    hash_kata_sandi VARCHAR(255) NOT NULL,
    dibuat_pada TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    login_terakhir TIMESTAMP NULL
) ENGINE=InnoDB;
