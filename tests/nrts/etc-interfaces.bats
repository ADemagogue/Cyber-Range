#!/usr/bin/env bats
# Tests for IP restoration (errata #3)

load '../helpers/setup'

ENTRYPOINT="$DOCKER_DIR/nrts/entrypoint.sh"

@test "NRTS entrypoint has IP restoration step" {
  assert_file_contains "$ENTRYPOINT" 'restore_ips'
}

@test "Reads from /root/services/*/IPList.txt" {
  assert_file_contains "$ENTRYPOINT" 'IPList.txt'
  assert_file_contains "$ENTRYPOINT" '/root/services'
}
