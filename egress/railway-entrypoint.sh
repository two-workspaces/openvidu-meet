#!/bin/bash
# Records rooms to the bucket. Egress takes one YAML document, built here from variables.
set -euo pipefail
: "${LIVEKIT_API_KEY:?}" "${LIVEKIT_API_SECRET:?}" "${LIVEKIT_WS_URL:?}" "${REDIS_HOST:?}" "${REDIS_PASSWORD:?}"
: "${S3_ENDPOINT:?}" "${S3_REGION:?}" "${S3_BUCKET:?}" "${S3_ACCESS_KEY:?}" "${S3_SECRET_KEY:?}"

# The killer and global monitoring read the host's CPUs, not this service's limit,
# so they would stop recordings for what other tenants do.
export EGRESS_CONFIG_BODY="redis:
  address: \"${REDIS_HOST}:${REDIS_PORT:-6379}\"
  password: \"${REDIS_PASSWORD}\"
api_key: \"${LIVEKIT_API_KEY}\"
api_secret: \"${LIVEKIT_API_SECRET}\"
ws_url: \"${LIVEKIT_WS_URL}\"
health_port: 9091
backup:
  prefix: /home/egress/backup_storage
storage:
  s3:
    access_key: \"${S3_ACCESS_KEY}\"
    secret: \"${S3_SECRET_KEY}\"
    region: \"${S3_REGION}\"
    endpoint: \"${S3_ENDPOINT}\"
    bucket: \"${S3_BUCKET}\"
    force_path_style: true
cpu_cost:
  max_cpu_utilization: 0.95
  room_composite_cpu_cost: 0.01
  audio_room_composite_cpu_cost: 0.01
  web_cpu_cost: 0.01
  audio_web_cpu_cost: 0.01
  participant_cpu_cost: 0.01
  track_composite_cpu_cost: 0.01
  track_cpu_cost: 0.01
openvidu:
  allocation_strategy: cpuload
  use_global_cpu_monitoring: false
  disable_cpu_overload_killer: true
"
exec /entrypoint.sh
