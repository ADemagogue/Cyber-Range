#!/usr/bin/env bats
# Tests for NRTS entrypoint (errata #11)

load '../helpers/setup'

ENTRYPOINT="$DOCKER_DIR/nrts/entrypoint.sh"

@test "nrts entrypoint.sh exists and is executable" {
  assert_file_exists "$ENTRYPOINT"
  [ -x "$ENTRYPOINT" ]
}

@test "Entrypoint seds all 10 variables into buildredteam.sh" {
  # Count sed -i lines that replace buildredteam variables
  count=$(grep -c 'sed -i.*BUILDSCRIPT' "$ENTRYPOINT")
  [ "$count" -ge 10 ]
}

@test "intname set from NRTS_IFACE" {
  assert_file_contains "$ENTRYPOINT" 'NRTS_IFACE'
  grep -q 'intname=.*NRTS_IFACE' "$ENTRYPOINT"
}

@test "recursDNS set from RECURSIVE_DNS_IP" {
  assert_file_contains "$ENTRYPOINT" 'RECURSIVE_DNS_IP'
  grep -q 'recursDNS=.*RECURSIVE_DNS_IP' "$ENTRYPOINT"
}

@test "defaultdecoysite set from DEFAULT_DECOY_SITE" {
  assert_file_contains "$ENTRYPOINT" 'DEFAULT_DECOY_SITE'
  grep -q 'defaultdecoysite=.*DEFAULT_DECOY_SITE' "$ENTRYPOINT"
}

@test "SSH key generation uses flock (errata #11)" {
  assert_file_contains "$ENTRYPOINT" 'flock'
}

@test "Scripts copied to writable location /root/scripts/" {
  assert_file_contains "$ENTRYPOINT" '/root/scripts'
  assert_file_contains "$ENTRYPOINT" 'mkdir -p /root/scripts'
}
