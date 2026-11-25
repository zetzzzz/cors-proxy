# cors-proxy

Tiny CORS proxy (nginx) for the ONLYOFFICE AI plugin to reach an
OpenAI-compatible API whose gateway does not answer CORS preflights.

## Why

The ONLYOFFICE AI plugin fetches the model list straight from the browser
(`GET <provider>/v1/models` with an `Authorization` header). The browser
first sends a CORS preflight (`OPTIONS`); if the provider answers it with
anything but 2xx + `Access-Control-Allow-Origin`, the browser blocks the
request and the plugin shows "Models not found" / "NetworkError when
attempting to fetch resource".

Arsant (`https://arsant.my.id`) answers the preflight with 401 and no
`Access-Control-Allow-Origin`, so the plugin cannot talk to it directly.
This proxy answers the preflight itself and forwards the real requests,
adding the CORS headers the browser needs.

## Image

- `ghcr.io/zetzzzz/cors-proxy:1.0.0`
- `ghcr.io/zetzzzz/cors-proxy:latest` (currently 1.0.0)

Built automatically by GitHub Actions on every push to `main`.

## Use

```yaml
services:
  ai-proxy:
    image: ghcr.io/zetzzzz/cors-proxy:1.0.0
    container_name: ai-proxy
    restart: unless-stopped
    ports:
      - "30135:80"
    environment:
      - ALLOWED_ORIGIN=https://office.zetz.my.id
```

Point the ONLYOFFICE AI plugin at the proxy URL instead of the provider
directly (e.g. provider URL `https://ai-proxy.zetz.my.id/v1`).

## Safety

- The upstream is fixed to `https://arsant.my.id` in the nginx config —
  this is not an open proxy; no other target can be reached through it.
- CORS headers are only added for the origin in `ALLOWED_ORIGIN`.
- The `Authorization` header is forwarded as-is; the proxy stores no keys.

## Verify

The workflow runs the built image and checks the CORS behaviour:
preflight from the allowed origin gets 204 + `Access-Control-Allow-Origin`,
a foreign origin gets no CORS header, and `/healthz` answers 200.
