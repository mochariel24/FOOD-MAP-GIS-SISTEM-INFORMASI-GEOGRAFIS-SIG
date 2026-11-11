USE foodmap_gis;

INSERT INTO kategori_makanan (id_kategori, nama_kategori, slug, deskripsi) VALUES
(1, 'Batagor & Bakso', 'batagor-bakso', 'Batagor, cuanki, siomay, dan bakso.'),
(2, 'Rumah Makan Sunda', 'rumah-makan-sunda', 'Hidangan Sunda dan nasi dengan lauk.'),
(3, 'Sate & Grill', 'sate-grill', 'Sate dan hidangan panggang.'),
(4, 'Restoran', 'restoran', 'Restoran keluarga dan hidangan beragam.'),
(5, 'Mie & Bakmi', 'mie-bakmi', 'Mie, bakmi, yamin, dan lomie.'),
(6, 'Kafe & Bakery', 'kafe-bakery', 'Kafe, kopi, roti, dan makanan ringan.'),
(7, 'Warung Makan', 'warung-makan', 'Warung makan dan hidangan rumahan.')
ON DUPLICATE KEY UPDATE nama_kategori=VALUES(nama_kategori), deskripsi=VALUES(deskripsi);

INSERT INTO penyedia_makanan
(id_kategori, slug, nama_penyedia, alamat, latitude, longitude, jam_buka, jam_tutup, no_telepon, foto, sumber_url, catatan_sumber)
VALUES
(1,'batagor-kingsley','Batagor Kingsley','Jl. Veteran No. 25, Kebon Pisang, Kota Bandung',-6.9190972,107.6153692,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9190972&mlon=107.6153692#map=18/-6.9190972/107.6153692','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(1,'batagor-riri','Batagor Riri','Jl. Kebon Kawung, Pasir Kaliki, Kota Bandung',-6.9122914,107.5999970,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9122914&mlon=107.5999970#map=18/-6.9122914/107.5999970','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(2,'warung-nasi-ibu-imas','Warung Nasi Ibu Imas','Jl. Balonggede, Balong Gede, Kota Bandung',-6.9273473,107.6071745,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9273473&mlon=107.6071745#map=18/-6.9273473/107.6071745','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(1,'cuanki-serayu','Baso Cuanki & Batagor Serayu','Jl. Serayu, Cihapit, Kota Bandung',-6.9090714,107.6257541,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9090714&mlon=107.6257541#map=18/-6.9090714/107.6257541','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(3,'sate-hadori','Sate Hadori','Jl. Stasiun Selatan, Kebon Jeruk, Kota Bandung',-6.9154742,107.6028366,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9154742&mlon=107.6028366#map=18/-6.9154742/107.6028366','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(4,'braga-permai','Braga Permai','Jl. Braga No. 58, Braga, Kota Bandung',-6.9173557,107.6095198,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9173557&mlon=107.6095198#map=18/-6.9173557/107.6095198','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(5,'mie-baso-akung','Mie Baso Akung','Jl. Lodaya No. 123, Lingkar Selatan, Kota Bandung',-6.9320455,107.6252304,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9320455&mlon=107.6252304#map=18/-6.9320455/107.6252304','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(5,'lomie-karuhun','Lomie Karuhun','Jl. HOS. Tjokroaminoto No. 70, Pasir Kaliki, Kota Bandung',-6.9106044,107.5979615,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9106044&mlon=107.5979615#map=18/-6.9106044/107.5979615','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(3,'sate-maulana-yusuf','Sate Maulana Yusuf','Jl. Maulana Yusup, Citarum, Kota Bandung',-6.9009918,107.6134343,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9009918&mlon=107.6134343#map=18/-6.9009918/107.6134343','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(5,'mie-naripan','Mie Naripan','Jl. Naripan No. 108, Kebon Pisang, Kota Bandung',-6.9214810,107.6178498,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9214810&mlon=107.6178498#map=18/-6.9214810/107.6178498','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(6,'seroja-bake','Seroja Bake','Jl. Cihapit No. 21, Cihapit, Kota Bandung',-6.9078275,107.6219699,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9078275&mlon=107.6219699#map=18/-6.9078275/107.6219699','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(2,'dapur-dahapati','Dapur Dahapati','Jl. Raden Adipati Aria Wiranatakusumah, Cipaganti, Kota Bandung',-6.8873777,107.6023400,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.8873777&mlon=107.6023400#map=18/-6.8873777/107.6023400','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(2,'raja-sunda','Raja Sunda','Jl. Cipedes Hilir, Kota Bandung',-6.8969429,107.5907416,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.8969429&mlon=107.5907416#map=18/-6.8969429/107.5907416','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(6,'kopi-toko-djawa','Kopi Toko Djawa','Gang Cikapundung, Braga, Kota Bandung',-6.9172487,107.6083790,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9172487&mlon=107.6083790#map=18/-6.9172487/107.6083790','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(7,'bubur-ayam-mang-h-oyo','Bubur Ayam Mang H. Oyo','Jl. Sulanjana No. 30, Tamansari, Kota Bandung',-6.8994560,107.6106804,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.8994560&mlon=107.6106804#map=18/-6.8994560/107.6106804','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(2,'rm-ampera','RM Ampera','Gang Bongkaran, Tamansari, Kota Bandung',-6.8989615,107.6050417,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.8989615&mlon=107.6050417#map=18/-6.8989615/107.6050417','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(5,'mie-gacoan-sumatra','Mie Gacoan Bandung Sumatra','Jl. Sumatra, Braga, Kota Bandung',-6.9175849,107.6129784,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9175849&mlon=107.6129784#map=18/-6.9175849/107.6129784','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh untuk demonstrasi; verifikasi ke penyedia.'),
(4,'dapur-solo-maleer','Dapur Solo Bandung','Maleer Indah III, Maleer, Kota Bandung',-6.9252979,107.6368815,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.9252979&mlon=107.6368815#map=18/-6.9252979/107.6368815','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh; cabang/jam operasional perlu dikonfirmasi.'),
(5,'bakmi-gm-bandung','Bakmi GM Bandung','Jarrdin, Cipaganti, Kota Bandung',-6.8931720,107.6051965,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://www.openstreetmap.org/?mlat=-6.8931720&mlon=107.6051965#map=18/-6.8931720/107.6051965','Koordinat dari OpenStreetMap/Photon, ditelusuri 11 November 2026. Menu dan harga contoh; verifikasi cabang dan harga.'),
(6,'six-nine-bandung','Six Nine Coffee & Dining','Jl. L.L.R.E. Martadinata No. 125, Cihapit, Kota Bandung',-6.9078484,107.6237768,NULL,NULL,NULL,'/assets/food-placeholder.svg','https://sixnine.id/coffee-dining/','Alamat dan tiga menu/harga contoh diambil dari situs resmi Six Nine. Jam dan cabang perlu dikonfirmasi.')
ON DUPLICATE KEY UPDATE id_kategori=VALUES(id_kategori), nama_penyedia=VALUES(nama_penyedia), alamat=VALUES(alamat), latitude=VALUES(latitude), longitude=VALUES(longitude), jam_buka=VALUES(jam_buka), jam_tutup=VALUES(jam_tutup), no_telepon=VALUES(no_telepon), foto=VALUES(foto), sumber_url=VALUES(sumber_url), catatan_sumber=VALUES(catatan_sumber);

DELETE m FROM menu_makanan AS m
JOIN penyedia_makanan AS p ON p.id_penyedia=m.id_penyedia
WHERE p.slug IN ('batagor-kingsley','batagor-riri','warung-nasi-ibu-imas','cuanki-serayu','sate-hadori','braga-permai','mie-baso-akung','lomie-karuhun','sate-maulana-yusuf','mie-naripan','seroja-bake','dapur-dahapati','raja-sunda','kopi-toko-djawa','bubur-ayam-mang-h-oyo','rm-ampera','mie-gacoan-sumatra','dapur-solo-maleer','bakmi-gm-bandung','six-nine-bandung');

INSERT INTO menu_makanan (id_penyedia,nama_menu,harga,harga_estimasi,sumber_harga)
SELECT p.id_penyedia, m.nama_menu, m.harga, m.estimasi, m.sumber FROM penyedia_makanan p
JOIN (
    SELECT 'batagor-kingsley' slug, 'Batagor original (estimasi)' nama_menu, 25000 harga, 1 estimasi, 'Contoh harga tugas; cek ke penyedia.' sumber UNION ALL
    SELECT 'batagor-kingsley','Batagor kuah (estimasi)',30000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'batagor-kingsley','Batagor campur (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'batagor-riri','Batagor original (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'batagor-riri','Batagor kuah (estimasi)',30000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'batagor-riri','Siomay (estimasi)',20000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'warung-nasi-ibu-imas','Nasi ayam goreng (estimasi)',28000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'warung-nasi-ibu-imas','Nasi ayam bakar (estimasi)',30000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'warung-nasi-ibu-imas','Nasi empal (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'cuanki-serayu','Cuanki komplit (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'cuanki-serayu','Batagor (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'cuanki-serayu','Siomay (estimasi)',20000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'sate-hadori','Sate kambing (estimasi)',50000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'sate-hadori','Sop kambing (estimasi)',45000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'sate-hadori','Nasi putih (estimasi)',8000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'braga-permai','Nasi goreng (estimasi)',45000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'braga-permai','Steak (estimasi)',95000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'braga-permai','Roti bakar (estimasi)',30000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-baso-akung','Yamin manis (estimasi)',38000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-baso-akung','Yamin asin (estimasi)',38000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-baso-akung','Bakso campur (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'lomie-karuhun','Lomie (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'lomie-karuhun','Mie bakso (estimasi)',30000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'lomie-karuhun','Pangsit (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'sate-maulana-yusuf','Sate ayam (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'sate-maulana-yusuf','Sate kambing (estimasi)',50000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'sate-maulana-yusuf','Lontong (estimasi)',8000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-naripan','Mie babat (estimasi)',40000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-naripan','Mie bakso (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-naripan','Pangsit (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'seroja-bake','Roti sourdough (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'seroja-bake','Croissant (estimasi)',28000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'seroja-bake','Kopi susu (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'dapur-dahapati','Sop buntut (estimasi)',75000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'dapur-dahapati','Nasi goreng (estimasi)',38000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'dapur-dahapati','Ayam goreng (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'raja-sunda','Gurame goreng (estimasi)',85000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'raja-sunda','Ayam bakar (estimasi)',45000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'raja-sunda','Nasi timbel (estimasi)',30000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'kopi-toko-djawa','Espresso (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'kopi-toko-djawa','Kopi susu (estimasi)',28000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'kopi-toko-djawa','Roti bakar (estimasi)',22000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'bubur-ayam-mang-h-oyo','Bubur ayam (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'bubur-ayam-mang-h-oyo','Bubur komplit (estimasi)',32000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'bubur-ayam-mang-h-oyo','Sate usus (estimasi)',8000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'rm-ampera','Ayam goreng (estimasi)',28000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'rm-ampera','Ikan goreng (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'rm-ampera','Sayur asem (estimasi)',15000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-gacoan-sumatra','Mie Gacoan (estimasi)',12000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-gacoan-sumatra','Siomay (estimasi)',10000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'mie-gacoan-sumatra','Es Gobak Sodor (estimasi)',10000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'dapur-solo-maleer','Nasi liwet ayam (estimasi)',35000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'dapur-solo-maleer','Selat Solo (estimasi)',38000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'dapur-solo-maleer','Wedang (estimasi)',18000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'bakmi-gm-bandung','Bakmi spesial (estimasi)',45000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'bakmi-gm-bandung','Pangsit goreng (estimasi)',25000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'bakmi-gm-bandung','Nasi ayam (estimasi)',38000,1,'Contoh harga tugas; cek ke penyedia.' UNION ALL
    SELECT 'six-nine-bandung','Kopi Susu SixNine',27000,0,'Situs resmi Six Nine: https://sixnine.id/coffee-dining/.' UNION ALL
    SELECT 'six-nine-bandung','Cappuccino',39000,0,'Situs resmi Six Nine: https://sixnine.id/coffee-dining/.' UNION ALL
    SELECT 'six-nine-bandung','Margherita sourdough pizza',85000,0,'Situs resmi Six Nine: https://sixnine.id/coffee-dining/.'
) AS m ON p.slug=m.slug
ON DUPLICATE KEY UPDATE harga=VALUES(harga), harga_estimasi=VALUES(harga_estimasi), sumber_harga=VALUES(sumber_harga);
