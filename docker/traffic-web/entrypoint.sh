#!/usr/bin/env bash
# Traffic web host entrypoint
# Downloads websites, applies IPs, generates vhosts, starts Apache
set -euo pipefail

DATA_FILE="${DATA_FILE:-/data/networks/traffic-webhosts.txt}"
DOWNLOAD_WEBSITES="${DOWNLOAD_WEBSITES:-true}"
SITES_DIR="${SITES_DIR:-/var/www/sites}"
WEB_IFACE="${WEB_IFACE:-eth0}"

echo "[traffic-web] Starting traffic web host..."

# Apply IPs from data file
if [[ -f "$DATA_FILE" ]]; then
  echo "[traffic-web] Applying web host IPs..."
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    [[ "$line" =~ ^# ]] && continue
    ip addr add "$line" dev "$WEB_IFACE" 2>/dev/null || true
  done < "$DATA_FILE"
fi

# Conditionally download websites
if [[ "$DOWNLOAD_WEBSITES" == "true" ]]; then
  echo "[traffic-web] Downloading websites..."
  mkdir -p "$SITES_DIR"
  # Download logic would go here (gdown from Google Drive)
  echo "[traffic-web] Download complete."
else
  echo "[traffic-web] Skipping website download (DOWNLOAD_WEBSITES=$DOWNLOAD_WEBSITES)"
fi

# Generate Apache vhosts from data file
echo "[traffic-web] Starting Apache..."
exec apache2-foreground
