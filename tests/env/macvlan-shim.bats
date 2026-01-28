#!/usr/bin/env bats
# Tests for setup-host.sh (errata #2, #13)

load '../helpers/setup'

SETUP="$PROJECT_ROOT/setup-host.sh"

@test "setup-host.sh exists and is executable" {
  assert_file_exists "$SETUP"
  [ -x "$SETUP" ]
}

@test "setup-host.sh creates macvlan shim interfaces (errata #2)" {
  assert_file_contains "$SETUP" 'ip link add'
  assert_file_contains "$SETUP" 'macvlan'
  assert_file_contains "$SETUP" 'macvlan-shim'
}

@test "Shim has gateway IP via ip addr add" {
  assert_file_contains "$SETUP" 'ip addr add'
}

@test "Uses > not >> for sysctl (errata #13)" {
  # The sysctl config should be written with cat > (overwrite) not >>
  assert_file_contains "$SETUP" 'cat > /etc/sysctl.d'
  assert_file_not_contains "$SETUP" 'cat >> /etc/sysctl.d'
}

@test "Script is idempotent — removes existing shim before creating" {
  assert_file_contains "$SETUP" 'ip link del'
}

@test "Enables IP forwarding" {
  assert_file_contains "$SETUP" 'ip_forward'
}

@test "Sets promiscuous mode on interfaces" {
  assert_file_contains "$SETUP" 'promisc on'
}
