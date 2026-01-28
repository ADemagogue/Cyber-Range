#!/usr/bin/env bash
# Router entrypoint: read data files and add IP addresses to interfaces.
# Uses host networking mode so addresses appear on real host interfaces.
set -euo pipefail

DATA_DIR="${DATA_DIR:-/data/networks}"

# Interface env vars with defaults
ADMIN_DEV="${ADMIN_DEV:-eth0}"
SERVICES_DEV="${SERVICES_DEV:-eth1}"
GRAYSPACE_DEV="${GRAYSPACE_DEV:-eth2}"
WAN_DEV="${WAN_DEV:-eth3}"

# Apply all addresses from a data file to an interface
apply_addresses() {
  local data_file="$1"
  local device="$2"

  if [[ ! -f "$data_file" ]]; then
    echo "[router] WARNING: data file not found: $data_file" >&2
    return 0
  fi

  echo "[router] Applying addresses from $data_file to $device"
  while IFS= read -r line; do
    # Skip blank lines
    [[ -z "$line" ]] && continue
    # Skip comments
    [[ "$line" =~ ^[[:space:]]*# ]] && continue

    # Add address; tolerate already-existing addresses
    ip addr add "$line" dev "$device" 2>/dev/null || true
  done < "$data_file"
}

echo "[router] Starting address assignment..."
apply_addresses "${DATA_DIR}/admin.txt"     "$ADMIN_DEV"
apply_addresses "${DATA_DIR}/services.txt"  "$SERVICES_DEV"
apply_addresses "${DATA_DIR}/grayspace.txt" "$GRAYSPACE_DEV"
apply_addresses "${DATA_DIR}/wan.txt"       "$WAN_DEV"
echo "[router] Address assignment complete."

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward 2>/dev/null || true

echo "[router] Running. Sleeping forever..."
exec sleep infinity
