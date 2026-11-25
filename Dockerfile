# CORS proxy for the ONLYOFFICE AI plugin -> Arsant (https://arsant.my.id).
# The plugin fetches the model list straight from the browser, and Arsant
# answers the CORS preflight with 401 and no Access-Control-Allow-Origin,
# so the browser blocks every request. This proxy answers the preflight
# itself and forwards the real requests, adding the CORS headers the
# browser needs.
#
# Fixed target: only https://arsant.my.id is ever proxied (no open proxy).
# Only the origin in ALLOWED_ORIGIN gets CORS headers.
FROM nginx:1.27-alpine

ENV ALLOWED_ORIGIN=https://office.zetz.my.id

# The official nginx image runs envsubst on *.template files in
# /etc/nginx/templates/ at container start, substituting only variables
# that exist in the environment, so nginx's own $variables survive.
COPY default.conf.template /etc/nginx/templates/default.conf.template

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/healthz || exit 1
