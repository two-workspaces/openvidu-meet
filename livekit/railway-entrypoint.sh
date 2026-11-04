#!/bin/sh
# LiveKit media server for OpenVidu Meet on Railway.
#
# Railway routes no inbound UDP, so media uses ICE over one TCP proxy. The server
# advertises the port it binds, while the proxy maps a random public port onto
# container port 7881. So bind the public port number, advertise the proxy's IP, and
# bridge 7881 onto it. The bridge dials the container's own address, not 127.0.0.1:
# pion's TCP mux looks connections up by local IP and would drop a loopback one.
set -eu
# Named MEDIA_REDIS_*: LiveKit reads REDIS_HOST as a flag that overrides this config and drops the port.

: "${LIVEKIT_API_KEY:?}" "${LIVEKIT_API_SECRET:?}" "${MEDIA_REDIS_HOST:?}" "${MEDIA_REDIS_PASSWORD:?}" "${MEET_WEBHOOK_URL:?}"
if [ -z "${RAILWAY_TCP_PROXY_DOMAIN:-}" ] || [ -z "${RAILWAY_TCP_PROXY_PORT:-}" ]; then
  echo "FATAL: no TCP proxy on this service. Calls would connect and carry no media." >&2
  echo "Add one on port 7881 in Settings > Networking, then redeploy." >&2
  exit 1
fi

NODE_IP=$(dig +short +timeout=3 A "$RAILWAY_TCP_PROXY_DOMAIN" | grep -E '^[0-9.]+$' | head -n 1)
SELF_IP=$(ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n 1)
[ -n "$NODE_IP" ] || { echo "FATAL: cannot resolve $RAILWAY_TCP_PROXY_DOMAIN" >&2; exit 1; }
[ -n "$SELF_IP" ] || { echo "FATAL: no IPv4 address on this container" >&2; exit 1; }

umask 077
cat > /tmp/livekit.yaml <<YAML
port: ${PORT:-7880}
bind_addresses:
  - ""
rtc:
  tcp_port: ${RAILWAY_TCP_PROXY_PORT}
  force_tcp: true
  use_external_ip: false
  node_ip: "${NODE_IP}"
turn:
  enabled: false
redis:
  address: "${MEDIA_REDIS_HOST}:${MEDIA_REDIS_PORT:-6379}"
  password: "${MEDIA_REDIS_PASSWORD}"
keys:
  "${LIVEKIT_API_KEY}": "${LIVEKIT_API_SECRET}"
webhook:
  api_key: "${LIVEKIT_API_KEY}"
  urls:
    - "${MEET_WEBHOOK_URL}"
logging:
  level: info
YAML

echo "media over ICE/TCP: advertising ${NODE_IP}:${RAILWAY_TCP_PROXY_PORT}, bridge 7881 -> ${SELF_IP}"
socat TCP-LISTEN:7881,fork,reuseaddr TCP:"${SELF_IP}":"${RAILWAY_TCP_PROXY_PORT}" &
exec /livekit-server --config /tmp/livekit.yaml
