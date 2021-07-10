self.addEventListener('fetch', async event => {
  event.respondWith(
    caches.open('dynamic-cache').then(async cache => {
      let cacheResponse = await cache.match(event.request);
      let fetchResponse = await fetch(event.request).then(async response => {
        await cache.delete(event.request);
        cache.put(event.request, response.clone());
        return response;
      }).catch(e => {
        return cacheResponse;
      });
      return fetchResponse;
    })
  );
});
