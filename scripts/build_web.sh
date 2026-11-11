#!/bin/bash
set -e

echo "=== Building Godot 4 Web (HTML5) ==="
mkdir -p build/web

# Godot Web 내보내기 실행
godot --headless --export-release "Web" build/web/index.html

# Service Worker 스크립트 주입
if [ ! -f "build/web/coop-coep-service-worker.js" ]; then
cat << 'EOF' > build/web/coop-coep-service-worker.js
self.addEventListener("install", function () { self.skipWaiting(); });
self.addEventListener("activate", function (event) { event.waitUntil(self.clients.claim()); });
self.addEventListener("fetch", function (event) {
    if (event.request.cache === "only-if-cached" && event.request.mode !== "same-origin") return;
    event.respondWith(fetch(event.request).then(function (response) {
        if (response.status === 0) return response;
        const newHeaders = new Headers(response.headers);
        newHeaders.set("Cross-Origin-Embedder-Policy", "require-corp");
        newHeaders.set("Cross-Origin-Opener-Policy", "same-origin");
        return new Response(response.body, { status: response.status, statusText: response.statusText, headers: newHeaders });
    }));
});
EOF
fi

# index.html에 Service worker 등록 코드 주입
if ! grep -q "coop-coep-service-worker.js" build/web/index.html; then
    sed -i '' 's|<head>|<head><script>if("serviceWorker" in navigator){navigator.serviceWorker.register("coop-coep-service-worker.js");}</script>|g' build/web/index.html
fi

echo "=== Web Build Complete ==="
ls -lh build/web/
