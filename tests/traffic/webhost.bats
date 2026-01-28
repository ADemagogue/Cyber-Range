#!/usr/bin/env bats
# Tests for traffic web host

load '../helpers/setup'

@test "data/networks/traffic-webhosts.txt exists" {
  assert_file_exists "$DATA_DIR/networks/traffic-webhosts.txt"
}

@test "Each line in traffic-webhosts.txt is a valid IP/CIDR" {
  assert_all_valid_cidr "$DATA_DIR/networks/traffic-webhosts.txt"
}

@test "traffic-web entrypoint.sh exists" {
  assert_file_exists "$DOCKER_DIR/traffic-web/entrypoint.sh"
  [ -x "$DOCKER_DIR/traffic-web/entrypoint.sh" ]
}

@test "Entrypoint downloads sites conditionally via DOWNLOAD_WEBSITES" {
  assert_file_contains "$DOCKER_DIR/traffic-web/entrypoint.sh" 'DOWNLOAD_WEBSITES'
}
