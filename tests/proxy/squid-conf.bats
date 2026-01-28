#!/usr/bin/env bats

load '../helpers/setup'

SQUID_CONF="$DOCKER_DIR/proxy/squid.conf"

@test "squid.conf exists" {
  assert_file_exists "$DOCKER_DIR/proxy/squid.conf"
}

@test "Template uses ADMIN_SUBNET variable" {
  assert_file_contains "$DOCKER_DIR/proxy/squid.conf" '${ADMIN_SUBNET}'
}

@test "Template uses PROXY_PORT variable" {
  assert_file_contains "$DOCKER_DIR/proxy/squid.conf" '${PROXY_PORT}'
}

@test "No hardcoded 172.30. IPs remain" {
  assert_file_not_contains "$DOCKER_DIR/proxy/squid.conf" '172\.30\.'
}

@test "No hardcoded port 9999" {
  # Port should come from variable, not hardcoded
  run grep -c 'http_port 9999' "$DOCKER_DIR/proxy/squid.conf"
  [ "$output" = "0" ]
}

@test "Uses RECURSIVE_DNS_IP for DNS" {
  assert_file_contains "$DOCKER_DIR/proxy/squid.conf" '${RECURSIVE_DNS_IP}'
}
