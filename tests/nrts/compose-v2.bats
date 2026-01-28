#!/usr/bin/env bats
# Tests for docker compose V2 fix (errata #17)

load '../helpers/setup'

ENTRYPOINT="$DOCKER_DIR/nrts/entrypoint.sh"

@test "Entrypoint replaces docker-compose with docker compose" {
  assert_file_contains "$ENTRYPOINT" "sed.*docker-compose.*docker compose"
}
