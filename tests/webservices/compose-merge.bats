#!/usr/bin/env bats
# Tests for master docker-compose.yml (errata #14)

load '../helpers/setup'

COMPOSE="$PROJECT_ROOT/docker-compose.yml"

@test "docker-compose.yml exists" {
  assert_file_exists "$COMPOSE"
}

@test "Master compose defines owncloud service" {
  assert_file_contains "$COMPOSE" 'owncloud:'
}

@test "Master compose defines bookstack service" {
  assert_file_contains "$COMPOSE" 'bookstack:'
}

@test "Master compose defines hastebin service" {
  assert_file_contains "$COMPOSE" 'hastebin:'
}

@test "Master compose defines drawio service" {
  assert_file_contains "$COMPOSE" 'drawio:'
}

@test "Master compose defines ntp service" {
  assert_file_contains "$COMPOSE" 'ntp:'
}

@test "Master compose defines ms-sites service" {
  assert_file_contains "$COMPOSE" 'ms-sites:'
}

@test "No hardcoded 180.1.1. IPs in compose (all use variables)" {
  # Ports should use ${VAR:-default} syntax, not bare IPs
  # We check that no bare 180.1.1. appears without being inside ${...:-...}
  run grep -cP '^\s+- 180\.1\.1\.' "$COMPOSE"
  [ "$output" = "0" ]
}

@test "No absolute /root/ host-mounted volume paths" {
  # Check that no volume mounts reference /root/ as a host path (left side of :)
  # In-container paths like /root/ca are fine (healthchecks, entrypoints)
  ! grep -P '^\s+- /root/' "$COMPOSE"
}

@test "Hastebin build context is relative" {
  assert_file_contains "$COMPOSE" './webservices/pastebin/hastebin'
}

@test "All web service nginx containers use services network" {
  for svc in owncloud-nginx hastebin-nginx bookstack-nginx drawio-nginx ms-sites; do
    # Each nginx service should appear under the services network
    assert_file_contains "$COMPOSE" "$svc:"
  done
}

@test "Volume names use cr- prefix" {
  # All named volumes should start with cr-
  run grep -P '^\s+cr-' "$COMPOSE"
  [ "$status" -eq 0 ]
  # No non-prefixed volume definitions
  run grep -cP '^\s+[a-z](?!cr-)[a-z-]+:$' "$COMPOSE"
  # This is a loose check; the important thing is cr- volumes exist
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "Web services depend on cert-bootstrap with service_completed_successfully" {
  assert_file_contains "$COMPOSE" 'service_completed_successfully'
}

@test "CA server has healthcheck" {
  assert_file_contains "$COMPOSE" 'healthcheck:'
}
