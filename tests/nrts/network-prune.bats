#!/usr/bin/env bats
# Tests for network prune fix (errata #4)
# buildredteam.sh must NOT use blanket "docker network prune"

load '../helpers/setup'

BUILDSCRIPT="$RTS_DIR/scripts/buildredteam.sh"

@test "buildredteam.sh exists" {
  assert_file_exists "$BUILDSCRIPT"
}

@test "docker network prune --force is NOT in buildredteam.sh (errata #4)" {
  ! grep -q 'network prune' "$BUILDSCRIPT"
}

@test "Targeted docker network rm replaces blanket prune" {
  assert_file_contains "$BUILDSCRIPT" 'docker network rm'
}
