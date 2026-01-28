#!/usr/bin/env bash
# DNS (BIND9) entrypoint: wait for IPs to become available, then start named.
set -euo pipefail

BIND_IP="${BIND_IP:-198.41.0.4}"
MAX_WAIT="${MAX_WAIT:-120}"

echo "[dns] Waiting for IP $BIND_IP to be available on this host..."

elapsed=0
while ! ip addr show | grep -q "$BIND_IP"; do
  if [ "$elapsed" -ge "$MAX_WAIT" ]; then
    echo "[dns] ERROR: Timed out waiting for $BIND_IP after ${MAX_WAIT}s" >&2
    exit 1
  fi
  sleep 2
  elapsed=$((elapsed + 2))
done

echo "[dns] IP $BIND_IP is available. Starting BIND9..."

# Ensure log directory exists
mkdir -p /var/log/named/data

# Validate configuration before starting
echo "[dns] Checking named configuration..."
named-checkconf /etc/bind/named.conf

echo "[dns] Configuration valid. Launching named in foreground..."
exec named -g -c /etc/bind/named.conf -u bind
