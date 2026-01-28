#!/usr/bin/env bats
# Tests for bind mount usage (errata #10)

load '../helpers/setup'

LAUNCH="$SCRIPTS_DIR/launch-nrts.sh"

@test "launch-nrts.sh exists and is executable" {
  assert_file_exists "$LAUNCH"
  [ -x "$LAUNCH" ]
}

@test "NRTS uses bind mount for services data" {
  # launch script should use ./data/nrts/ or similar bind mount path
  assert_file_contains "$LAUNCH" 'data/nrts'
}

@test "Launch script mounts docker socket" {
  assert_file_contains "$LAUNCH" '/var/run/docker.sock'
}
