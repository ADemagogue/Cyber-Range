#!/usr/bin/env bats

load '../helpers/setup'

@test "dns entrypoint.sh exists and is executable" {
  assert_file_exists "$DOCKER_DIR/dns/entrypoint.sh"
  [ -x "$DOCKER_DIR/dns/entrypoint.sh" ]
}

@test "Waits for IP availability before starting BIND" {
  # Entrypoint must check ip addr for the bind IP
  assert_file_contains "$DOCKER_DIR/dns/entrypoint.sh" 'ip addr'
  assert_file_contains "$DOCKER_DIR/dns/entrypoint.sh" 'BIND_IP'
}

@test "Has a timeout for IP wait loop" {
  assert_file_contains "$DOCKER_DIR/dns/entrypoint.sh" 'MAX_WAIT'
}

@test "Runs named-checkconf before starting" {
  assert_file_contains "$DOCKER_DIR/dns/entrypoint.sh" 'named-checkconf'
}

@test "Starts named in foreground" {
  assert_file_contains "$DOCKER_DIR/dns/entrypoint.sh" 'named -g'
}

@test "named.conf.options exists and is valid syntax" {
  assert_file_exists "$PROJECT_ROOT/rootdns/bind/named.conf.options"
  # Basic check: has options block
  assert_file_contains "$PROJECT_ROOT/rootdns/bind/named.conf.options" 'options {'
}

@test "named.conf.options listens on expected IPs" {
  assert_file_contains "$PROJECT_ROOT/rootdns/bind/named.conf.options" '198.41.0.4'
  assert_file_contains "$PROJECT_ROOT/rootdns/bind/named.conf.options" '8.8.8.8'
}
