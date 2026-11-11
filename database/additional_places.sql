USE foodmap_gis;

-- Five additional Bandung food providers. Addresses and menu items are taken
-- from each provider's own website/menu; coordinates are checked against the
-- provider's Google Maps location or Maps search for the published address.
INSERT INTO penyedia_makanan
(id_kategori, slug, nama_penyedia, alamat, latitude, longitude, jam_buka, jam_tutup, no_telepon, foto, sumber_url, catatan_sumber)
VALUES
(6,'penka-1967','PENKA 1967','Jl. Laswi No. 26, Kacapiring, Kec. Batununggal, Kota Bandung, Jawa Barat 40271',-6.9178474,107.6307873,'10:00:00','02:00:00',NULL,'/assets/food-placeholder.svg','https://www.penka1967.com/','Alamat dan titik diperiksa pada Google Maps dari alamat resmi PENKA 1967. Menu dan harga mengikuti situs resmi yang ditinjau 11 November 2026; pajak dan layanan dapat berlaku. Jam tutup akhir pekan tercantum sampai 03.00.'),
(4,'orlin-dining','Orlin Dining','Jl. Lodaya No. 42, Turangga, Kec. Lengkong, Kota Bandung, Jawa Barat 40264',-6.9322152,107.6246996,'10:00:00','21:30:00','(022) 7316146','/assets/food-placeholder.svg','https://orlinbandung.com/menu/','Alamat, jam, telepon, menu dan harga paket diambil dari situs resmi Orlin; titik mengikuti tautan Google Maps resmi. Harga yang ditampilkan adalah harga paket prasmanan, bukan harga satuan menu.'),
(4,'padma-the-restaurant','The Restaurant - Padma Hotel Bandung','Jl. Ranca Bentang No. 56-58, Ciumbuleuit, Kec. Cidadap, Kota Bandung, Jawa Barat 40142',-6.8647340,107.6093880,'12:00:00','22:00:00','(022) 2030333','/assets/food-placeholder.svg','https://www.padmahotelbandung.com/dining/the-restaurant.php','Alamat dan nomor telepon dari situs resmi Padma; titik mengikuti peta resmi halaman kontak. Jam all-day dining 12.00-22.00; sarapan 06.30-10.30. Menu dan harga dari PDF resmi; harga dapat berubah dan dapat dikenai pajak/layanan.'),
(4,'semeja-asian-kitchen','Semeja Asian Kitchen - The Gaia Hotel Bandung','Jl. Dr. Setiabudi No. 430, Ledeng, Kec. Cidadap, Kota Bandung, Jawa Barat 40143',-6.8439761,107.6006596,'11:00:00','22:00:00','(022) 20280780','/assets/food-placeholder.svg','https://www.thegaiabandung.com/dining/semeja-asian-kitchen','Alamat dan kontak dari situs resmi The Gaia; koordinat dicocokkan melalui Google Maps. Jam yang disimpan adalah lunch-dinner 11.00-22.00; sarapan weekday 06.00-10.30 dan weekend sampai 11.00. PDF menu resmi menyebut harga nett dalam ribuan rupiah.'),
(4,'sadrasa-kitchen-bar','Sadrasa Kitchen & Bar - Pullman Bandung','Jl. Diponegoro No. 27, Citarum, Kec. Bandung Wetan, Kota Bandung, Jawa Barat 40115',-6.8997795,107.6175052,'12:00:00','22:00:00','(022) 86038888','/assets/food-placeholder.svg','https://www.pullman-bandung-grandcentral.com/dining/pullman-dining/sadrasa-kitchen-bar/','Alamat dan kontak dari situs resmi Pullman; koordinat dicocokkan melalui Google Maps. Jam makan siang 12.00-15.00 dan malam 18.00-22.00 (Jumat-Sabtu sampai 22.30); sarapan 06.30-10.30. PDF menu resmi 2026; harga sebelum pajak/layanan 21%.')
ON DUPLICATE KEY UPDATE
    id_kategori=VALUES(id_kategori),
    nama_penyedia=VALUES(nama_penyedia),
    alamat=VALUES(alamat),
    latitude=VALUES(latitude),
    longitude=VALUES(longitude),
    jam_buka=VALUES(jam_buka),
    jam_tutup=VALUES(jam_tutup),
    no_telepon=VALUES(no_telepon),
    foto=VALUES(foto),
    sumber_url=VALUES(sumber_url),
    catatan_sumber=VALUES(catatan_sumber);

INSERT INTO menu_makanan (id_penyedia, nama_menu, harga, harga_estimasi, sumber_harga)
SELECT p.id_penyedia, m.nama_menu, m.harga, m.estimasi, m.sumber
FROM penyedia_makanan p
JOIN (
    SELECT 'penka-1967' slug, 'Tahu Lada Garam' nama_menu, 28000 harga, 0 estimasi, 'https://www.penka1967.com/ — harga pada situs resmi, ditinjau 11 November 2026.' sumber UNION ALL
    SELECT 'penka-1967','Ayam Goreng Berempah Malaysia',62400,0,'https://www.penka1967.com/ — harga pada situs resmi, ditinjau 11 November 2026.' UNION ALL
    SELECT 'penka-1967','Bebek Penka1967',53000,0,'https://www.penka1967.com/ — harga pada situs resmi, ditinjau 11 November 2026.' UNION ALL
    SELECT 'orlin-dining','Paket Prasmanan 35K - Ayam Bumbu Merah',35000,0,'https://orlinbandung.com/ — paket dan harga tercantum pada situs resmi Orlin.' UNION ALL
    SELECT 'orlin-dining','Paket Prasmanan 55K - Ayam Kalasan/Ungkep',55000,0,'https://orlinbandung.com/ — paket dan harga tercantum pada situs resmi Orlin.' UNION ALL
    SELECT 'orlin-dining','Paket Prasmanan 65K - Gurame Asam Manis',65000,0,'https://orlinbandung.com/ — paket dan harga tercantum pada situs resmi Orlin.' UNION ALL
    SELECT 'padma-the-restaurant','Oxtail Soup (Grilled or Deep Fried)',225000,0,'https://www.padmahotelbandung.com/repository/ala-carte-menu-the-restaurant.pdf — PDF menu resmi; harga dalam ribuan rupiah, sebelum pajak/layanan.' UNION ALL
    SELECT 'padma-the-restaurant','Bebek Goreng Kecombrang',195000,0,'https://www.padmahotelbandung.com/repository/ala-carte-menu-the-restaurant.pdf — PDF menu resmi; harga dalam ribuan rupiah, sebelum pajak/layanan.' UNION ALL
    SELECT 'padma-the-restaurant','Iga Sapi Bakar',160000,0,'https://www.padmahotelbandung.com/repository/ala-carte-menu-the-restaurant.pdf — PDF menu resmi; harga dalam ribuan rupiah, sebelum pajak/layanan.' UNION ALL
    SELECT 'semeja-asian-kitchen','Mie Kocok',110000,0,'https://www.thegaiabandung.com/public/assets/images/upload/restaurant/documents/menu_restaurant_1785737454.pdf — PDF menu resmi; harga nett dalam ribuan rupiah.' UNION ALL
    SELECT 'semeja-asian-kitchen','Sate Ayam Madura',115000,0,'https://www.thegaiabandung.com/public/assets/images/upload/restaurant/documents/menu_restaurant_1785737454.pdf — PDF menu resmi; harga nett dalam ribuan rupiah.' UNION ALL
    SELECT 'semeja-asian-kitchen','Nasi Goreng Special',125000,0,'https://www.thegaiabandung.com/public/assets/images/upload/restaurant/documents/menu_restaurant_1785737454.pdf — PDF menu resmi; harga nett dalam ribuan rupiah.' UNION ALL
    SELECT 'sadrasa-kitchen-bar','Sup Buntut',160000,0,'https://d2e5ushqwiltxm.cloudfront.net/wp-content/uploads/sites/240/2026/10/16072448/SADRASA-KITCHEN-BAR_NEW-MENU-DESIGN-2026.pdf — PDF menu resmi 2026; harga dalam ribuan rupiah, sebelum pajak/layanan.' UNION ALL
    SELECT 'sadrasa-kitchen-bar','Nasi Goreng Cikur',120000,0,'https://d2e5ushqwiltxm.cloudfront.net/wp-content/uploads/sites/240/2026/10/16072448/SADRASA-KITCHEN-BAR_NEW-MENU-DESIGN-2026.pdf — PDF menu resmi 2026; harga dalam ribuan rupiah, sebelum pajak/layanan.' UNION ALL
    SELECT 'sadrasa-kitchen-bar','Sate Diponegoro',110000,0,'https://d2e5ushqwiltxm.cloudfront.net/wp-content/uploads/sites/240/2026/10/16072448/SADRASA-KITCHEN-BAR_NEW-MENU-DESIGN-2026.pdf — PDF menu resmi 2026; harga dalam ribuan rupiah, sebelum pajak/layanan.'
) AS m ON p.slug=m.slug
ON DUPLICATE KEY UPDATE
    harga=VALUES(harga),
    harga_estimasi=VALUES(harga_estimasi),
    sumber_harga=VALUES(sumber_harga);
