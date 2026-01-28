#!/usr/bin/env bash
# Host preparation script for Cyber-Range
# Errata #2: Creates macvlan shim interfaces for host-to-container communication
# Errata #13: Uses > (overwrite) not >> (append) for sysctl
# Idempotent: safe to run multiple times.
set -euo pipefail

echo "[setup-host] Preparing host for Cyber-Range..."

# ── Sysctl settings (errata #13: overwrite, not append) ──────
echo "[setup-host] Configuring sysctl..."
cat > /etc/sysctl.d/99-cyber-range.conf <<'EOF'
net.ipv4.ip_forward = 1
net.ipv4.conf.all.proxy_arp = 1
net.ipv4.conf.all.promiscuous = 1
EOF
sysctl --system > /dev/null 2>&1

# ── Interface configuration ───────────────────────────────────
ADMIN_DEV="${ADMIN_DEV:-eth0}"
SERVICES_DEV="${SERVICES_DEV:-eth1}"
GRAYSPACE_DEV="${GRAYSPACE_DEV:-eth2}"
WAN_DEV="${WAN_DEV:-eth3}"

echo "[setup-host] Bringing up interfaces..."
for dev in "$ADMIN_DEV" "$SERVICES_DEV" "$GRAYSPACE_DEV" "$WAN_DEV"; do
  ip link set "$dev" up 2>/dev/null || echo "[setup-host] WARNING: $dev not found"
  ip link set "$dev" promisc on 2>/dev/null || true
done

# ── Macvlan shim interfaces (errata #2) ──────────────────────
# Creates macvlan shim interfaces so the host can communicate with
# containers on macvlan networks. Without these, host and containers
# on the same macvlan are isolated at layer 2.

create_macvlan_shim() {
  local parent="$1"
  local shim_name="$2"
  local gateway_ip="$3"

  # Remove existing shim if present (idempotent)
  ip link del "$shim_name" 2>/dev/null || true

  echo "[setup-host] Creating macvlan shim: $shim_name on $parent ($gateway_ip)"
  ip link add "$shim_name" link "$parent" type macvlan mode bridge
  ip addr add "$gateway_ip" dev "$shim_name"
  ip link set "$shim_name" up
}

create_macvlan_shim "$ADMIN_DEV"    "macvlan-shim0" "${ADMIN_GW:-172.30.7.254/21}"
create_macvlan_shim "$SERVICES_DEV" "macvlan-shim1" "${SERVICES_GW:-180.1.1.1/24}"
create_macvlan_shim "$WAN_DEV"      "macvlan-shim3" "${WAN_GW:-1.1.1.1/29}"

echo "[setup-host] Host setup complete."
echo "[setup-host] You can now run: docker compose up -d"
