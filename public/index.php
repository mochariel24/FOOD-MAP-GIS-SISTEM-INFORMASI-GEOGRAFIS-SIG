<?php
declare(strict_types=1);
$maps = require __DIR__ . '/../config/maps.php';
$mapKey = trim((string) ($maps['api_key'] ?? ''));
?><!doctype html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="theme-color" content="#f7f7f4">
  <title>FoodMap GIS — Kuliner Bandung</title>
  <meta name="description" content="Peta pencarian penyedia makanan di Kota Bandung dengan menu, kisaran harga, lokasi pengguna, dan petunjuk rute Google Maps.">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Manrope:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="/assets/app.css?v=<?= rawurlencode((string) filemtime(__DIR__ . '/assets/app.css')) ?>">
  <script>window.FoodMapConfig = <?= json_encode(['hasMapsKey' => $mapKey !== ''], JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;</script>
</head>
<body>
  <header class="topbar">
    <a class="brand" href="/" aria-label="FoodMap GIS beranda">
      <span class="brand-mark" aria-hidden="true"><svg viewBox="0 0 32 32"><path d="M16 2.8c-6.3 0-11.4 5-11.4 11.2 0 8 11.4 15.3 11.4 15.3S27.4 22 27.4 14C27.4 7.8 22.3 2.8 16 2.8Z"/><circle cx="16" cy="14" r="4.2"/></svg></span>
      <span><strong>FoodMap</strong><small>SIG kuliner Bandung</small></span>
    </a>
    <nav class="top-actions" aria-label="Navigasi utama">
      <span class="city-chip"><span class="live-dot"></span> Kota Bandung</span>
      <button class="button button-quiet" id="adminButton" type="button">Masuk admin</button>
      <button class="button button-admin hidden" id="logoutButton" type="button">Keluar <span id="adminName"></span></button>
    </nav>
  </header>

  <main>
    <section class="hero">
      <div class="hero-copy">
        <div class="eyebrow"><span></span> JELAJAHI KULINER KOTA BANDUNG</div>
        <h1>Temukan tempat makan<br><em>di sekitar Bandung.</em></h1>
        <p>Cari penyedia makanan, lihat menu dan kisaran harga, lalu buka rute perjalanan di Google Maps.</p>
      </div>
      <div class="hero-note"><span class="note-icon">✳</span><div><strong><span id="heroProviderCount">—</span> tempat kuliner</strong><small>Lokasi awal di Kota Bandung</small></div></div>
    </section>

    <section class="metric-row" aria-label="Ringkasan data">
      <article class="metric-card"><span class="metric-icon mint">⌖</span><div><strong id="providerCount">—</strong><small>penyedia terdata</small></div></article>
      <article class="metric-card"><span class="metric-icon coral">▤</span><div><strong id="menuCount">—</strong><small>pilihan menu</small></div></article>
      <article class="metric-card"><span class="metric-icon lilac">₨</span><div><strong>Rp</strong><small>filter kisaran harga</small></div></article>
      <article class="metric-card"><span class="metric-icon amber">↗</span><div><strong>Google Maps</strong><small>petunjuk rute</small></div></article>
    </section>

    <section class="workspace">
      <aside class="directory panel">
        <div class="panel-heading">
          <div><div class="eyebrow eyebrow-small">DIREKTORI</div><h2>Tempat makan</h2></div>
          <button class="button button-primary button-small hidden" id="addProviderButton" type="button"><span>＋</span> Tambah</button>
        </div>
        <label class="searchbox" for="searchInput"><span class="search-icon">⌕</span><input id="searchInput" type="search" placeholder="Cari nama, alamat, menu…" autocomplete="off"><kbd>Ctrl K</kbd></label>
        <div class="filter-grid">
          <label><span>Kategori</span><select id="categoryFilter"><option value="">Semua kategori</option></select></label>
          <label><span>Kisaran harga</span><select id="pricePreset"><option value="">Semua harga</option><option value="0-25000">Hingga Rp25 ribu</option><option value="25000-50000">Rp25–50 ribu</option><option value="50000-100000">Rp50–100 ribu</option><option value="100000-9999999">Di atas Rp100 ribu</option></select></label>
        </div>
        <div class="geo-filters">
          <button class="button button-outline button-small" id="locateButton" type="button"><span>◎</span> Lokasi saya</button>
          <label class="radius-select"><span>Radius</span><select id="radiusFilter" disabled><option value="1">1 km</option><option value="3" selected>3 km</option><option value="5">5 km</option></select></label>
          <label class="nearest-toggle"><input type="checkbox" id="nearestOnly" disabled><span>5 terdekat</span></label>
        </div>
        <div class="list-meta"><span id="resultCount">Memuat penyedia…</span><button class="text-button" id="resetFilters" type="button">Reset</button></div>
        <div class="estimate-notice"><span>i</span><p>Harga menu bertanda <b>contoh</b> adalah estimasi untuk demo tugas. Konfirmasi harga langsung ke penyedia.</p></div>
        <div class="provider-list" id="providerList" aria-live="polite"></div>
        <div class="directory-footer"><span>Data usaha: OpenStreetMap</span><a href="https://www.openstreetmap.org/copyright" target="_blank" rel="noopener">Atribusi</a></div>
      </aside>

      <section class="map-column" aria-label="Peta penyedia makanan">
        <div class="map-panel panel">
          <div class="map-heading">
            <div><div class="eyebrow eyebrow-small">PETA PERSEBARAN</div><h2 id="selectedTitle">Penyedia makanan di Bandung</h2><p id="selectedSubtitle">Pilih marker atau nama tempat untuk melihat detail.</p></div>
            <div class="map-actions"><button class="button button-outline button-small" id="showAllButton" type="button">Lihat semua</button></div>
          </div>
          <div class="map-wrap" id="mapWrap">
            <div id="map" aria-label="Peta Google Maps dengan marker kuliner"></div>
            <div id="mapFallback" class="map-fallback hidden"><div class="map-fallback-card"><span class="fallback-pin">⌖</span><h3>Peta Google Maps</h3><p>Tambahkan API key Google Maps ke <code>config/maps.local.php</code> untuk memuat peta dan marker interaktif.</p><a href="https://developers.google.com/maps/documentation/javascript/get-api-key" target="_blank" rel="noopener">Cara mendapatkan API key ↗</a></div></div>
            <div class="map-toolbar"><button class="map-tool" id="mapLocateButton" type="button" title="Tampilkan lokasi saya">◎</button><button class="map-tool" id="zoomInButton" type="button" title="Perbesar">＋</button><button class="map-tool" id="zoomOutButton" type="button" title="Perkecil">−</button></div>
          </div>
          <div class="map-legend"><span><i class="legend-pin"></i> Penyedia makanan</span><span><i class="legend-user"></i> Lokasi saya</span><strong id="markerCount">— marker</strong></div>
        </div>
        <article class="detail-card panel" id="detailCard">
          <div class="detail-empty"><span>⌖</span><div><strong>Pilih tempat makan</strong><small>Detail menu, alamat, dan rute akan tampil di sini.</small></div></div>
        </article>
      </section>
    </section>
    <footer class="site-footer"><span>FoodMap GIS · Proyek Sistem Informasi Geografis</span><span>Wilayah kajian: Kota Bandung, Jawa Barat</span></footer>
  </main>

  <dialog class="dialog" id="loginDialog" aria-labelledby="loginTitle">
    <form class="dialog-card login-card" id="loginForm">
      <button class="dialog-close" type="button" data-close="loginDialog" aria-label="Tutup">×</button>
      <div class="eyebrow eyebrow-small">AKSES PENGELOLA</div><h2 id="loginTitle">Masuk admin</h2><p class="dialog-intro">Masuk untuk mengelola daftar penyedia dan menu makanan.</p>
      <label class="field"><span>Nama pengguna</span><input name="username" required maxlength="60" autocomplete="username"></label>
      <label class="field"><span>Kata sandi</span><input name="password" type="password" required maxlength="200" autocomplete="current-password"></label>
      <div class="form-error" id="loginError" role="alert"></div>
      <button class="button button-primary button-full" type="submit">Masuk ke dashboard</button>
      <small class="form-footnote">Akun dibuat melalui <code>php tools/create_admin.php</code>.</small>
    </form>
  </dialog>

  <dialog class="dialog dialog-wide" id="providerDialog" aria-labelledby="providerDialogTitle">
    <form class="dialog-card provider-form" id="providerForm">
      <button class="dialog-close" type="button" data-close="providerDialog" aria-label="Tutup">×</button>
      <div class="eyebrow eyebrow-small">PENGELOLAAN DATA</div><h2 id="providerDialogTitle">Tambah penyedia makanan</h2>
      <input type="hidden" name="id" id="providerId">
      <div class="form-grid">
        <label class="field"><span>Nama penyedia *</span><input name="name" id="providerName" required maxlength="120"></label>
        <label class="field"><span>Kategori *</span><select name="category_id" id="providerCategory" required></select></label>
        <label class="field full"><span>Alamat *</span><textarea name="address" id="providerAddress" required maxlength="500" rows="2"></textarea></label>
        <label class="field"><span>Latitude *</span><input name="latitude" id="providerLat" required inputmode="decimal" placeholder="-6.91"></label>
        <label class="field"><span>Longitude *</span><input name="longitude" id="providerLng" required inputmode="decimal" placeholder="107.61"></label>
        <div class="field full map-pick-row"><span>Titik pada peta</span><button class="button button-outline button-small" id="pickLocationButton" type="button">Pilih titik di peta</button><small>Kecamatan diisi oleh server dari batas administrasi Kota Bandung.</small></div>
        <label class="field"><span>Jam buka</span><input name="open_time" id="providerOpen" type="time"></label>
        <label class="field"><span>Jam tutup</span><input name="close_time" id="providerClose" type="time"></label>
        <label class="field"><span>Nomor telepon</span><input name="phone" id="providerPhone" maxlength="30" placeholder="Opsional"></label>
        <label class="field"><span>URL foto (HTTPS)</span><input name="photo_url" id="providerPhoto" maxlength="500" placeholder="Kosongkan untuk ilustrasi demo"></label>
        <label class="field full"><span>Sumber atau catatan verifikasi</span><textarea name="source_note" id="providerSource" rows="2" maxlength="500" placeholder="Contoh: menu diperiksa di situs resmi pada tanggal…"></textarea></label>
      </div>
      <div class="menu-editor-head"><div><h3>Menu dan harga</h3><p>Minimal 3 menu. Tandai “estimasi” bila harga belum diverifikasi.</p></div><button class="button button-outline button-small" id="addMenuRow" type="button">＋ Menu</button></div>
      <div class="menu-editor" id="menuEditor"></div>
      <div class="form-error" id="providerError" role="alert"></div>
      <div class="form-actions"><span>* Wajib diisi</span><button class="button button-quiet" type="button" data-close="providerDialog">Batal</button><button class="button button-primary" type="submit">Simpan data</button></div>
    </form>
  </dialog>

  <div class="toast" id="toast" role="status" aria-live="polite"></div>
  <script src="/assets/app.js?v=<?= rawurlencode((string) filemtime(__DIR__ . '/assets/app.js')) ?>"></script>
  <?php if ($mapKey !== ''): ?>
  <script async defer src="https://maps.googleapis.com/maps/api/js?key=<?= htmlspecialchars($mapKey, ENT_QUOTES, 'UTF-8') ?>&callback=initFoodMap"></script>
  <?php endif; ?>
</body>
</html>
