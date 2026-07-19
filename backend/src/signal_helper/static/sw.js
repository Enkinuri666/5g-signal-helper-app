// Minimal cache-first service worker for the app shell so the compass
// keeps working when the phone bounces between Wi-Fi cells. Anything
// under /api/ is always fetched live (SSE won't cache anyway).

const CACHE = "signal-helper-v1";
const SHELL = [
  "/",
  "/index.html",
  "/styles.css",
  "/app.js",
  "/geo.js",
  "/sensors.js",
  "/signal-stream.js",
  "/compass.js",
  "/manifest.webmanifest",
  "/favicon.svg",
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))),
    ),
  );
  self.clients.claim();
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  if (url.pathname.startsWith("/api/")) return; // let it hit the network
  e.respondWith(
    caches.match(e.request).then((hit) => hit || fetch(e.request)),
  );
});
