(() => {
  'use strict';
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
  const state = {
    providers: [], categories: [], csrf: '', admin: false, username: '', map: null,
    markers: new Map(), userMarker: null, userLocation: null, selected: null,
    mapClickListener: null, toastTimer: null, filters: { query: '', category: '', min: null, max: null },
  };

  const esc = value => String(value ?? '').replace(/[&<>"']/g, ch => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[ch]));
  const money = value => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(Number(value) || 0);
  const formatTime = value => value ? String(value).slice(0, 5) : 'Belum diverifikasi';
  const placeholder = '/assets/food-placeholder.svg';

  async function request(url, options = {}) {
    const response = await fetch(url, { credentials: 'same-origin', ...options, headers: { 'Content-Type': 'application/json', ...(options.headers || {}) } });
    let result;
    try { result = await response.json(); } catch { result = {}; }
    if (!response.ok) throw new Error(result.error || `Permintaan gagal (${response.status}).`);
    return result;
  }

  async function loadData() {
    const data = await request('/api/providers.php');
    state.providers = data.providers || [];
    state.categories = data.categories || [];
    fillCategories();
    $('#providerCount').textContent = data.count ?? state.providers.length;
    $('#heroProviderCount').textContent = data.count ?? state.providers.length;
    $('#menuCount').textContent = state.providers.reduce((sum, p) => sum + p.menus.length, 0);
    renderList();
    if (state.selected) {
      const refreshed = state.providers.find(p => p.id === state.selected.id);
      if (refreshed) selectProvider(refreshed, false);
      else clearDetail();
    }
    if (state.map) renderMarkers();
  }

  async function loadSession() {
    const session = await request('/api/auth.php');
    state.csrf = session.csrf_token || '';
    state.admin = Boolean(session.authenticated);
    state.username = session.username || '';
    updateAdminControls();
  }

  function fillCategories() {
    const options = state.categories.map(c => `<option value="${c.id}">${esc(c.name)}</option>`).join('');
    $('#categoryFilter').innerHTML = '<option value="">Semua kategori</option>' + options;
    $('#providerCategory').innerHTML = options;
  }

  function updateAdminControls() {
    $('#adminButton').classList.toggle('hidden', state.admin);
    $('#logoutButton').classList.toggle('hidden', !state.admin);
    $('#adminName').textContent = state.admin ? esc(state.username) : '';
    $('#addProviderButton').classList.toggle('hidden', !state.admin);
    renderList();
  }

  function distanceKm(provider) {
    if (!state.userLocation) return null;
    const rad = deg => deg * Math.PI / 180;
    const dLat = rad(provider.latitude - state.userLocation.lat);
    const dLng = rad(provider.longitude - state.userLocation.lng);
    const a = Math.sin(dLat / 2) ** 2 + Math.cos(rad(state.userLocation.lat)) * Math.cos(rad(provider.latitude)) * Math.sin(dLng / 2) ** 2;
    return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }

  function visibleProviders() {
    let rows = state.providers.filter(provider => {
      const q = state.filters.query.toLocaleLowerCase('id-ID');
      const text = [provider.nama_penyedia, provider.alamat, provider.nama_kategori, provider.district, ...provider.menus.map(menu => menu.name)].join(' ').toLocaleLowerCase('id-ID');
      if (q && !text.includes(q)) return false;
      if (state.filters.category && String(provider.category_id) !== state.filters.category) return false;
      const min = state.filters.min;
      const max = state.filters.max;
      if ((min !== null || max !== null) && !provider.menus.some(menu => (min === null || menu.price >= min) && (max === null || menu.price <= max))) return false;
      if (state.userLocation) {
        const radius = Number($('#radiusFilter').value || 3);
        if (distanceKm(provider) > radius) return false;
      }
      return true;
    });
    if (state.userLocation) rows.sort((a, b) => distanceKm(a) - distanceKm(b));
    if ($('#nearestOnly').checked) rows = rows.slice(0, 5);
    return rows;
  }

  function renderList() {
    const rows = visibleProviders();
    $('#resultCount').textContent = `Menampilkan ${rows.length} dari ${state.providers.length} tempat`;
    $('#markerCount').textContent = `${rows.length} marker`;
    if (!rows.length) {
      $('#providerList').innerHTML = '<div class="empty-state"><span>⌕</span><strong>Tempat tidak ditemukan</strong><small>Coba ubah kata kunci atau filter.</small></div>';
    } else {
      $('#providerList').innerHTML = rows.map((provider, index) => {
        const active = state.selected?.id === provider.id ? ' is-selected' : '';
        const km = distanceKm(provider);
        const menuPrice = provider.min_price && provider.max_price ? `${money(provider.min_price)} – ${money(provider.max_price)}` : 'Harga belum tersedia';
        return `<article class="provider-row${active}" data-provider-id="${provider.id}" tabindex="0" role="button" aria-label="Lihat ${esc(provider.nama_penyedia)}">
          <span class="provider-rank">${String(index + 1).padStart(2, '0')}</span>
          <span class="provider-copy"><strong>${esc(provider.nama_penyedia)}</strong><small>${esc(provider.nama_kategori)} · ${esc(provider.district || 'Bandung')}</small><small class="provider-price">${menuPrice}</small></span>
          ${km !== null ? `<span class="distance-pill">${km.toFixed(1)} km</span>` : ''}
          ${state.admin ? `<span class="row-admin"><button class="icon-button edit-provider" type="button" data-id="${provider.id}" aria-label="Ubah ${esc(provider.nama_penyedia)}">✎</button><button class="icon-button delete-provider" type="button" data-id="${provider.id}" aria-label="Hapus ${esc(provider.nama_penyedia)}">×</button></span>` : '<span class="row-arrow">↗</span>'}
        </article>`;
      }).join('');
    }
    $$('.provider-row').forEach(row => {
      row.addEventListener('click', event => {
        if (event.target.closest('button')) return;
        const provider = state.providers.find(p => p.id === Number(row.dataset.providerId));
        if (provider) selectProvider(provider);
      });
      row.addEventListener('keydown', event => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault();
          const provider = state.providers.find(p => p.id === Number(row.dataset.providerId));
          if (provider) selectProvider(provider);
        }
      });
    });
    $$('.edit-provider').forEach(button => button.addEventListener('click', event => { event.stopPropagation(); const p = state.providers.find(x => x.id === Number(button.dataset.id)); if (p) openProviderDialog(p); }));
    $$('.delete-provider').forEach(button => button.addEventListener('click', event => { event.stopPropagation(); deleteProvider(Number(button.dataset.id)); }));
    if (state.map) renderMarkers(rows);
  }

  function providerDetailMarkup(provider, compact = false) {
    const image = provider.foto && (/^https:\/\//i.test(provider.foto) || provider.foto.startsWith('/assets/')) ? provider.foto : placeholder;
    const menuRows = provider.menus.map(menu => `<li><span>${esc(menu.name)}${menu.is_estimate ? ' <em>contoh</em>' : ''}</span><strong>${money(menu.price)}</strong></li>`).join('');
    const hours = provider.jam_buka && provider.jam_tutup ? `${formatTime(provider.jam_buka)}–${formatTime(provider.jam_tutup)}` : 'Belum diverifikasi';
    const route = googleDirectionsUrl(provider);
    return `<div class="detail-content${compact ? ' detail-compact' : ''}">
      <div class="detail-image-wrap"><img src="${esc(image)}" alt="Ilustrasi ${esc(provider.nama_penyedia)}" onerror="this.src='${placeholder}'"><span class="detail-category">${esc(provider.nama_kategori)}</span></div>
      <div class="detail-main"><div class="detail-title-line"><div><div class="eyebrow eyebrow-small">DETAIL PENYEDIA</div><h3>${esc(provider.nama_penyedia)}</h3><p>${esc(provider.alamat)}</p></div>${state.admin ? `<button class="button button-outline button-small detail-edit" data-id="${provider.id}" type="button">Ubah data</button>` : ''}</div>
        <div class="detail-facts"><span><small>KECAMATAN</small><b>${esc(provider.district || 'Bandung')}</b></span><span><small>OPERASIONAL</small><b>${hours}</b></span><span><small>TELEPON</small><b>${provider.no_telepon ? esc(provider.no_telepon) : 'Belum dicantumkan'}</b></span><span><small>KOORDINAT WGS 84</small><b>${Number(provider.latitude).toFixed(6)}, ${Number(provider.longitude).toFixed(6)}</b></span></div>
        <div class="menu-list-head"><h4>Menu pilihan</h4><span>${provider.menus.length} menu</span></div><ul class="menu-list">${menuRows}</ul>
        <div class="source-note"><span>i</span><span>${esc(provider.catatan_sumber || 'Data perlu dikonfirmasi kepada penyedia.')}</span></div>
        <div class="detail-actions"><a class="button button-primary" href="${esc(route)}" target="_blank" rel="noopener">Buka rute Google Maps <span>↗</span></a><a class="button button-outline" href="https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${provider.latitude},${provider.longitude}`)}" target="_blank" rel="noopener">Lihat di Google Maps</a></div>
      </div></div>`;
  }

  function selectProvider(provider, moveMap = true) {
    state.selected = provider;
    $('#selectedTitle').textContent = provider.nama_penyedia;
    $('#selectedSubtitle').textContent = `${provider.nama_kategori} · ${provider.district || 'Kota Bandung'}`;
    $('#detailCard').innerHTML = providerDetailMarkup(provider);
    const edit = $('.detail-edit');
    if (edit) edit.addEventListener('click', () => openProviderDialog(provider));
    if (moveMap && state.map) {
      state.map.panTo({ lat: provider.latitude, lng: provider.longitude });
      if (state.map.getZoom() < 15) state.map.setZoom(15);
    }
    const marker = state.markers.get(provider.id);
    if (marker && state.map) {
      if (state.infoWindow) state.infoWindow.close();
      state.infoWindow = new google.maps.InfoWindow({ content: `<div class="map-info"><strong>${esc(provider.nama_penyedia)}</strong><span>${esc(provider.nama_kategori)} · ${esc(provider.district || 'Bandung')}</span><small>${money(provider.min_price)}–${money(provider.max_price)}</small></div>` });
      state.infoWindow.open({ map: state.map, anchor: marker });
    }
    $$('.provider-row').forEach(row => row.classList.toggle('is-selected', Number(row.dataset.providerId) === provider.id));
  }

  function clearDetail() {
    state.selected = null;
    $('#selectedTitle').textContent = 'Penyedia makanan di Bandung';
    $('#selectedSubtitle').textContent = 'Pilih marker atau nama tempat untuk melihat detail.';
    $('#detailCard').innerHTML = '<div class="detail-empty"><span>⌖</span><div><strong>Pilih tempat makan</strong><small>Detail menu, alamat, dan rute akan tampil di sini.</small></div></div>';
    if (state.infoWindow) state.infoWindow.close();
  }

  function googleDirectionsUrl(provider) {
    const params = new URLSearchParams({ api: '1', destination: `${provider.latitude},${provider.longitude}`, travelmode: 'driving' });
    if (state.userLocation) params.set('origin', `${state.userLocation.lat},${state.userLocation.lng}`);
    return `https://www.google.com/maps/dir/?${params.toString()}`;
  }

  function renderMarkers(rows = visibleProviders()) {
    if (!state.map) return;
    const ids = new Set(rows.map(p => p.id));
    for (const [id, marker] of state.markers.entries()) {
      if (!ids.has(id)) { marker.setMap(null); state.markers.delete(id); }
    }
    rows.forEach(provider => {
      let marker = state.markers.get(provider.id);
      if (!marker) {
        marker = new google.maps.Marker({
          map: state.map,
          position: { lat: provider.latitude, lng: provider.longitude },
          title: provider.nama_penyedia,
          label: { text: '•', color: '#ffffff', fontSize: '22px', fontWeight: '700' },
          icon: { path: google.maps.SymbolPath.CIRCLE, scale: 15, fillColor: '#c14b33', fillOpacity: 1, strokeColor: '#ffffff', strokeWeight: 3 },
          optimized: true,
        });
        marker.addListener('click', () => selectProvider(provider, false));
        state.markers.set(provider.id, marker);
      } else {
        marker.setPosition({ lat: provider.latitude, lng: provider.longitude });
        marker.setMap(state.map);
      }
    });
    $('#markerCount').textContent = `${rows.length} marker`;
  }

  window.initFoodMap = function initFoodMap() {
    const mapElement = $('#map');
    if (!mapElement || !window.google?.maps) return;
    state.map = new google.maps.Map(mapElement, {
      center: { lat: -6.9147, lng: 107.6098 }, zoom: 13,
      mapTypeControl: false, streetViewControl: false, fullscreenControl: true,
      clickableIcons: false, gestureHandling: 'greedy',
      styles: [
        { featureType: 'poi.business', elementType: 'labels', stylers: [{ visibility: 'simplified' }] },
        { featureType: 'transit', elementType: 'labels.icon', stylers: [{ saturation: -55 }] },
        { featureType: 'water', elementType: 'geometry', stylers: [{ color: '#cfe3e5' }] },
        { featureType: 'landscape', elementType: 'geometry', stylers: [{ color: '#f3f1eb' }] },
        { featureType: 'road', elementType: 'geometry', stylers: [{ color: '#ffffff' }] },
      ],
    });
    state.map.addListener('click', event => {
      if (!state.mapClickListener) return;
      $('#providerLat').value = event.latLng.lat().toFixed(7);
      $('#providerLng').value = event.latLng.lng().toFixed(7);
      state.mapClickListener = false;
      $('#providerDialog').showModal();
      toast('Koordinat dipilih. Server akan memeriksa batas Kota Bandung.');
    });
    renderMarkers();
    if (state.userLocation) addUserMarker();
  };

  function mapFallback(message) {
    const fallback = $('#mapFallback');
    fallback.classList.remove('hidden');
    if (message) $('.map-fallback-card p', fallback).textContent = message;
  }

  function locateUser() {
    if (!navigator.geolocation) { toast('Browser ini tidak mendukung geolokasi.'); return; }
    $('#locateButton').disabled = true;
    navigator.geolocation.getCurrentPosition(position => {
      state.userLocation = { lat: position.coords.latitude, lng: position.coords.longitude };
      $('#radiusFilter').disabled = false;
      $('#nearestOnly').disabled = false;
      $('#locateButton').disabled = false;
      $('#locateButton').innerHTML = '<span>✓</span> Lokasi ditemukan';
      if (state.map) addUserMarker();
      renderList();
      toast('Lokasi Anda digunakan untuk jarak dan rute.');
    }, error => {
      $('#locateButton').disabled = false;
      const messages = { 1: 'Izin lokasi ditolak. Aktifkan izin lokasi di browser.', 2: 'Lokasi tidak berhasil ditemukan.', 3: 'Permintaan lokasi melewati batas waktu.' };
      toast(messages[error.code] || 'Lokasi pengguna tidak tersedia.');
    }, { enableHighAccuracy: true, timeout: 12000, maximumAge: 60000 });
  }

  function addUserMarker() {
    if (!state.map || !state.userLocation) return;
    if (state.userMarker) state.userMarker.setMap(null);
    state.userMarker = new google.maps.Marker({
      map: state.map, position: state.userLocation, title: 'Lokasi saya',
      icon: { path: google.maps.SymbolPath.CIRCLE, scale: 9, fillColor: '#3c9279', fillOpacity: 1, strokeColor: '#ffffff', strokeWeight: 3 },
      zIndex: 999,
    });
    state.map.panTo(state.userLocation);
    if (state.map.getZoom() < 14) state.map.setZoom(14);
  }

  function setPriceFilter() {
    const value = $('#pricePreset').value;
    if (!value) { state.filters.min = null; state.filters.max = null; }
    else {
      const [min, max] = value.split('-').map(Number);
      state.filters.min = min; state.filters.max = max;
    }
    renderList();
  }

  function openLogin() {
    $('#loginError').textContent = '';
    $('#loginDialog').showModal();
    setTimeout(() => $('input[name="username"]', $('#loginForm')).focus(), 50);
  }

  function resetProviderForm(provider = null) {
    $('#providerForm').reset();
    $('#providerError').textContent = '';
    $('#providerId').value = provider?.id || '';
    $('#providerDialogTitle').textContent = provider ? 'Ubah data penyedia' : 'Tambah penyedia makanan';
    $('#providerName').value = provider?.nama_penyedia || '';
    $('#providerCategory').value = provider?.category_id || state.categories[0]?.id || '';
    $('#providerAddress').value = provider?.alamat || '';
    $('#providerLat').value = provider?.latitude ?? '';
    $('#providerLng').value = provider?.longitude ?? '';
    $('#providerOpen').value = provider?.jam_buka ? String(provider.jam_buka).slice(0, 5) : '';
    $('#providerClose').value = provider?.jam_tutup ? String(provider.jam_tutup).slice(0, 5) : '';
    $('#providerPhone').value = provider?.no_telepon || '';
    $('#providerPhoto').value = provider?.foto && provider.foto !== placeholder ? provider.foto : '';
    $('#providerSource').value = provider?.catatan_sumber || '';
    $('#menuEditor').innerHTML = '';
    const menus = provider?.menus?.length ? provider.menus : [{ name: '', price: '', is_estimate: true }, { name: '', price: '', is_estimate: true }, { name: '', price: '', is_estimate: true }];
    menus.forEach(menu => addMenuRow(menu));
  }

  function addMenuRow(menu = { name: '', price: '', is_estimate: true }) {
    const row = document.createElement('div');
    row.className = 'menu-edit-row';
    row.innerHTML = `<label class="field"><span>Nama menu</span><input class="menu-name" maxlength="120" value="${esc(menu.name || '')}" placeholder="Contoh: Nasi goreng"></label><label class="field"><span>Harga (Rp)</span><input class="menu-price" type="number" min="1000" max="5000000" step="500" value="${menu.price ?? ''}" placeholder="25000"></label><label class="estimate-check"><input class="menu-estimate" type="checkbox" ${menu.is_estimate !== false ? 'checked' : ''}><span>Estimasi</span></label><button class="icon-button remove-menu" type="button" aria-label="Hapus menu">×</button>`;
    $('.remove-menu', row).addEventListener('click', () => row.remove());
    $('#menuEditor').append(row);
  }

  function openProviderDialog(provider = null) {
    if (!state.admin) { openLogin(); return; }
    resetProviderForm(provider);
    $('#providerDialog').showModal();
  }

  async function deleteProvider(id) {
    const provider = state.providers.find(p => p.id === id);
    if (!provider || !confirm(`Hapus ${provider.nama_penyedia} beserta menu terkait?`)) return;
    try {
      await request(`/api/providers.php?id=${id}`, { method: 'DELETE', headers: { 'X-CSRF-Token': state.csrf } });
      if (state.selected?.id === id) clearDetail();
      await loadData();
      toast('Data penyedia berhasil dihapus.');
    } catch (error) { toast(error.message); }
  }

  function toast(message) {
    const element = $('#toast');
    element.textContent = message;
    element.classList.add('toast-visible');
    clearTimeout(state.toastTimer);
    state.toastTimer = setTimeout(() => element.classList.remove('toast-visible'), 3400);
  }

  function bindEvents() {
    $('#searchInput').addEventListener('input', event => { state.filters.query = event.target.value.trim(); renderList(); });
    $('#categoryFilter').addEventListener('change', event => { state.filters.category = event.target.value; renderList(); });
    $('#pricePreset').addEventListener('change', setPriceFilter);
    $('#radiusFilter').addEventListener('change', renderList);
    $('#nearestOnly').addEventListener('change', renderList);
    $('#resetFilters').addEventListener('click', () => {
      $('#searchInput').value = ''; $('#categoryFilter').value = ''; $('#pricePreset').value = '';
      state.filters = { query: '', category: '', min: null, max: null };
      $('#nearestOnly').checked = false; renderList();
    });
    $('#adminButton').addEventListener('click', openLogin);
    $('#logoutButton').addEventListener('click', async () => {
      try { await request('/api/auth.php', { method: 'POST', headers: { 'X-CSRF-Token': state.csrf }, body: JSON.stringify({ action: 'logout' }) }); state.admin = false; state.username = ''; await loadSession(); toast('Anda sudah keluar dari akun admin.'); }
      catch (error) { toast(error.message); }
    });
    $('#loginForm').addEventListener('submit', async event => {
      event.preventDefault(); $('#loginError').textContent = '';
      // Capture the form before awaiting fetch: event.currentTarget is cleared
      // after the submit event dispatch completes.
      const loginForm = event.currentTarget;
      const form = new FormData(loginForm);
      try {
        const result = await request('/api/auth.php', { method: 'POST', headers: { 'X-CSRF-Token': state.csrf }, body: JSON.stringify({ action: 'login', username: form.get('username'), password: form.get('password') }) });
        state.csrf = result.csrf_token; state.admin = true; state.username = result.username;
        $('#loginDialog').close(); loginForm.reset(); updateAdminControls(); toast('Berhasil masuk sebagai admin.');
      } catch (error) { $('#loginError').textContent = error.message; }
    });
    $('#addProviderButton').addEventListener('click', () => openProviderDialog());
    $('#addMenuRow').addEventListener('click', () => addMenuRow());
    $('#providerForm').addEventListener('submit', async event => {
      event.preventDefault(); $('#providerError').textContent = '';
      const menus = $$('.menu-edit-row', $('#menuEditor')).map(row => ({ name: $('.menu-name', row).value.trim(), price: $('.menu-price', row).value, is_estimate: $('.menu-estimate', row).checked })).filter(menu => menu.name || menu.price);
      const payload = {
        id: $('#providerId').value || undefined,
        name: $('#providerName').value.trim(), category_id: $('#providerCategory').value,
        address: $('#providerAddress').value.trim(), latitude: $('#providerLat').value.trim(), longitude: $('#providerLng').value.trim(),
        open_time: $('#providerOpen').value, close_time: $('#providerClose').value, phone: $('#providerPhone').value.trim(),
        photo_url: $('#providerPhoto').value.trim(), source_note: $('#providerSource').value.trim(), menus,
      };
      try {
        await request('/api/providers.php', { method: payload.id ? 'PUT' : 'POST', headers: { 'X-CSRF-Token': state.csrf }, body: JSON.stringify(payload) });
        $('#providerDialog').close(); await loadData(); toast('Data penyedia dan menunya tersimpan.');
      } catch (error) { $('#providerError').textContent = error.message; }
    });
    $('#locateButton').addEventListener('click', locateUser);
    $('#mapLocateButton').addEventListener('click', locateUser);
    $('#showAllButton').addEventListener('click', () => { clearDetail(); if (state.map) { state.map.panTo({ lat: -6.9147, lng: 107.6098 }); state.map.setZoom(13); } });
    $('#zoomInButton').addEventListener('click', () => { if (state.map) state.map.setZoom(state.map.getZoom() + 1); });
    $('#zoomOutButton').addEventListener('click', () => { if (state.map) state.map.setZoom(state.map.getZoom() - 1); });
    $('#pickLocationButton').addEventListener('click', () => {
      if (!state.map) { toast('Peta belum aktif. Isi latitude dan longitude manual atau tambahkan API key.'); return; }
      state.mapClickListener = true; $('#providerDialog').close(); toast('Klik lokasi usaha pada peta.');
    });
    $$('[data-close]').forEach(button => button.addEventListener('click', () => $(`#${button.dataset.close}`).close()));
    $$('.dialog').forEach(dialog => dialog.addEventListener('click', event => { if (event.target === dialog) dialog.close(); }));
    document.addEventListener('keydown', event => {
      if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === 'k') { event.preventDefault(); $('#searchInput').focus(); }
      if (event.key === 'Escape' && state.mapClickListener) { state.mapClickListener = false; }
    });
  }

  async function init() {
    bindEvents();
    if (!window.FoodMapConfig?.hasMapsKey) mapFallback('Peta dan marker Google akan muncul setelah API key Google Maps ditambahkan di config/maps.local.php. Fitur direktori dan rute tetap tersedia.');
    else setTimeout(() => { if (!state.map) mapFallback('Peta belum berhasil dimuat. Periksa API key, izin HTTP referrer, dan pengaturan proyek Google Maps.'); }, 9000);
    try { await Promise.all([loadSession(), loadData()]); }
    catch (error) {
      $('#resultCount').textContent = 'Database belum terhubung';
      $('#providerList').innerHTML = `<div class="empty-state"><strong>Aplikasi belum tersambung ke database</strong><small>${esc(error.message)} Jalankan tools/import_database.php lalu muat ulang.</small></div>`;
      mapFallback('Database belum siap. Jalankan tools/import_database.php untuk membuat tabel dan mengisi data demo.');
    }
  }
  document.addEventListener('DOMContentLoaded', init);
})();
