#!/usr/bin/env bats
# Tests for iptables scoping (errata #5)
# buildredteam.sh must NOT use blanket iptables -F OUTPUT/PREROUTING

load '../helpers/setup'

BUILDSCRIPT="$RTS_DIR/scripts/buildredteam.sh"

@test "No blanket iptables -F OUTPUT -t nat in buildredteam.sh (errata #5)" {
  ! grep -q 'iptables -F OUTPUT -t nat' "$BUILDSCRIPT"
}

@test "No blanket iptables -F PREROUTING -t nat in buildredteam.sh" {
  ! grep -q 'iptables -F PREROUTING -t nat' "$BUILDSCRIPT"
}

@test "Uses scoped NRTS_NAT custom chain instead" {
  assert_file_contains "$BUILDSCRIPT" 'NRTS_NAT'
}
