'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'real-estate-crm-v1';

const RESOURCES = {
  "index.html": "index.html",
  "manifest.json": "manifest.json",
  "favicon.png": "favicon.png",
  "icons/icon-192.png": "icons/icon-192.png",
  "icons/icon-512.png": "icons/icon-512.png",
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return Promise.all(
        cacheName
          .filter(function (cache) {
            return cache !== CACHE_NAME;
          })
          .map(function (cache) {
            return caches.delete(cache);
          })
      );
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request).then(function (response) {
      return response || fetch(event.request);
    })
  );
});

self.addEventListener('install', function (event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function (cache) {
      return cache.addAll(Object.values(RESOURCES));
    })
  );
});