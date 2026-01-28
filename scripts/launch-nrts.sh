#!/usr/bin/env bash
# Launch NRTS container with bind mounts (errata #10)
# Usage: launch-nrts.sh [instance-name]
set -euo pipefail

INSTANCE="${1:-nrts-default}"
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="${PROJECT_ROOT}/data/nrts/${INSTANCE}"

# Create local data directory
mkdir -p "${DATA_DIR}/services"

echo "[nrts] Launching NRTS instance: ${INSTANCE}"
docker compose -f "${PROJECT_ROOT}/docker-compose.yml" run \
  --name "${INSTANCE}" \
  --rm \
  -v "${DATA_DIR}/services:/root/services" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e NRTS_INSTANCE="${INSTANCE}" \
  nrts
