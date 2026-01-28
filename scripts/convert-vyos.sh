#!/usr/bin/env bash
# Convert VyOS "set interfaces ethernet ethN address X.X.X.X/NN" commands
# into a plain CIDR list (one per line).
#
# Usage: convert-vyos.sh <vyos-config-file>

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <vyos-config-file>" >&2
  exit 1
fi

input_file="$1"

if [[ ! -f "$input_file" ]]; then
  echo "Error: file not found: $input_file" >&2
  exit 1
fi

# Extract the last field (IP/CIDR) from "set interfaces ethernet ethN address X.X.X.X/NN"
# Skip blank lines, comments, and non-address lines
while IFS= read -r line; do
  # Skip blank lines and comments
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue

  # Only process lines containing "set interfaces ethernet"
  if [[ "$line" =~ set[[:space:]]+interfaces[[:space:]]+ethernet[[:space:]]+[a-zA-Z0-9]+[[:space:]]+address[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  fi
done < "$input_file"
