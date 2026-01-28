#!/usr/bin/env bash
# Shared test helpers for bats tests

# Project root directory
export PROJECT_ROOT
PROJECT_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"

# Common paths
export SCRIPTS_DIR="${PROJECT_ROOT}/scripts"
export DOCKER_DIR="${PROJECT_ROOT}/docker"
export DATA_DIR="${PROJECT_ROOT}/data"
export VYOS_DIR="${PROJECT_ROOT}/SI-Router/Scripts"
export RTS_DIR="${PROJECT_ROOT}/rts"
export WEBSERVICES_DIR="${PROJECT_ROOT}/webservices"

# Create a temporary directory for test artifacts
setup_tempdir() {
  export TEST_TMPDIR
  TEST_TMPDIR="$(mktemp -d)"
}

# Clean up temporary directory
teardown_tempdir() {
  if [[ -n "${TEST_TMPDIR:-}" && -d "${TEST_TMPDIR}" ]]; then
    rm -rf "${TEST_TMPDIR}"
  fi
}

# Assert file exists
assert_file_exists() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Expected file to exist: $file" >&2
    return 1
  fi
}

# Assert file contains pattern
assert_file_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -q "$pattern" "$file"; then
    echo "Expected '$file' to contain pattern: $pattern" >&2
    return 1
  fi
}

# Assert file does NOT contain pattern
assert_file_not_contains() {
  local file="$1"
  local pattern="$2"
  if grep -q "$pattern" "$file"; then
    echo "Expected '$file' NOT to contain pattern: $pattern" >&2
    return 1
  fi
}

# Assert output line count
assert_line_count() {
  local file="$1"
  local expected="$2"
  local actual
  actual="$(wc -l < "$file" | tr -d ' ')"
  if [[ "$actual" -ne "$expected" ]]; then
    echo "Expected $expected lines in $file, got $actual" >&2
    return 1
  fi
}

# Assert line count is greater than threshold
assert_line_count_gt() {
  local file="$1"
  local threshold="$2"
  local actual
  actual="$(wc -l < "$file" | tr -d ' ')"
  if [[ "$actual" -le "$threshold" ]]; then
    echo "Expected more than $threshold lines in $file, got $actual" >&2
    return 1
  fi
}

# Validate CIDR format (e.g. 10.0.0.1/24)
is_valid_cidr() {
  local line="$1"
  [[ "$line" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]
}

# Assert all lines in file are valid CIDR
assert_all_valid_cidr() {
  local file="$1"
  local line_num=0
  while IFS= read -r line; do
    line_num=$((line_num + 1))
    if [[ -z "$line" ]] || [[ "$line" =~ ^# ]]; then
      continue
    fi
    if ! is_valid_cidr "$line"; then
      echo "Line $line_num is not valid CIDR: '$line'" >&2
      return 1
    fi
  done < "$file"
}

# Check if docker compose is available (for integration tests)
require_docker_compose() {
  if ! command -v docker &>/dev/null; then
    skip "docker not available"
  fi
  if ! docker compose version &>/dev/null; then
    skip "docker compose not available"
  fi
}

# Check if yq is available
require_yq() {
  if ! command -v yq &>/dev/null; then
    skip "yq not available"
  fi
}

# Mock SSH keygen (no-op for testing)
mock_ssh_keygen() {
  export PATH="${TEST_TMPDIR}/bin:${PATH}"
  mkdir -p "${TEST_TMPDIR}/bin"
  cat > "${TEST_TMPDIR}/bin/ssh-keygen" <<'MOCK'
#!/bin/bash
# Mock ssh-keygen for testing
touch "${4:-/dev/null}" 2>/dev/null || true
MOCK
  chmod +x "${TEST_TMPDIR}/bin/ssh-keygen"
}
