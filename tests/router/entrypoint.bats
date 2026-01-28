#!/usr/bin/env bats

load '../helpers/setup'

setup() {
  setup_tempdir
  export ENTRYPOINT="$DOCKER_DIR/router/entrypoint.sh"
}

teardown() {
  teardown_tempdir
}

@test "entrypoint.sh exists and is executable" {
  assert_file_exists "$ENTRYPOINT"
  [ -x "$ENTRYPOINT" ]
}

@test "apply_addresses function is defined" {
  assert_file_contains "$ENTRYPOINT" "apply_addresses()"
}

@test "Skips comments in data files" {
  grep -q 'space.*#' "$ENTRYPOINT"
}

@test "Skips blank lines" {
  grep -qF -- '-z "$line"' "$ENTRYPOINT"
}

@test "Tolerates already-existing addresses with || true" {
  assert_file_contains "$ENTRYPOINT" '|| true'
}

@test "Reads ADMIN_DEV env var with default eth0" {
  assert_file_contains "$ENTRYPOINT" 'ADMIN_DEV="${ADMIN_DEV:-eth0}"'
}

@test "Reads SERVICES_DEV env var with default eth1" {
  assert_file_contains "$ENTRYPOINT" 'SERVICES_DEV="${SERVICES_DEV:-eth1}"'
}

@test "Reads GRAYSPACE_DEV env var with default eth2" {
  assert_file_contains "$ENTRYPOINT" 'GRAYSPACE_DEV="${GRAYSPACE_DEV:-eth2}"'
}

@test "Reads WAN_DEV env var with default eth3" {
  assert_file_contains "$ENTRYPOINT" 'WAN_DEV="${WAN_DEV:-eth3}"'
}

@test "Enables IP forwarding" {
  assert_file_contains "$ENTRYPOINT" 'ip_forward'
}

@test "Sleeps forever at end" {
  assert_file_contains "$ENTRYPOINT" 'sleep infinity'
}
