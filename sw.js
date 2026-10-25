// Offline support: try the network first so updates show up right away, and fall back to the
// cached copy when offline (or when the network takes more than 3 seconds).
// Bump CACHE when the file list changes.
const CACHE = 'recall-v3';
const SHELL = ['./', './index.html', './config.js', './manifest.webmanifest', './icon-192.png', './icon-512.png', './apple-touch-icon.png'];
const SHELL_PATHS = new Set(SHELL.map(p => new URL(p, self.registration.scope).pathname));

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request, url = new URL(req.url);
  // Only the app's own files; everything else (sync requests included) goes straight to the network.
  if (req.method !== 'GET' || url.origin !== location.origin || !(req.mode === 'navigate' || SHELL_PATHS.has(url.pathname))) return;
  e.respondWith((async () => {
    const cache = await caches.open(CACHE);
    const network = fetch(req).then(res => { if (res.ok) cache.put(req, res.clone()); return res; });
    network.catch(() => {});
    const res = await Promise.race([network, new Promise(r => setTimeout(r, 3000))]).catch(() => null);
    if (res) return res;
    const cached = await cache.match(req, { ignoreSearch: true }) || (req.mode === 'navigate' && await cache.match('./index.html'));
    return cached || network;
  })());
});
