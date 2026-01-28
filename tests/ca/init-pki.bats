#!/usr/bin/env bats
# Tests for CA PKI initialization (errata #7, #8)

load '../helpers/setup'

INIT_PKI="$DOCKER_DIR/ca/init-pki.sh"

@test "init-pki.sh exists and is executable" {
  assert_file_exists "$INIT_PKI"
  [ -x "$INIT_PKI" ]
}

@test "Creates root CA key at CA_DIR/private/root.key.pem" {
  assert_file_contains "$INIT_PKI" 'private/root.key.pem'
}

@test "Creates root CA cert at CA_DIR/certs/root.crt.pem" {
  assert_file_contains "$INIT_PKI" 'certs/root.crt.pem'
}

@test "Creates intermediate CA cert with CA_DOMAIN variable" {
  # Exact path: /root/ca/intermediate/certs/int.${CA_DOMAIN}.crt.pem
  assert_file_contains "$INIT_PKI" 'intermediate/certs/int.${CA_DOMAIN}'
}

@test "Exact path /root/ca/intermediate/certs/ preserved (errata #7)" {
  # This matches buildredteam.sh CAcrtpath="/root/ca/intermediate/certs"
  assert_file_contains "$INIT_PKI" '/root/ca/intermediate/certs/'
}

@test "Skips init if PKI already exists" {
  assert_file_contains "$INIT_PKI" 'already initialized'
}

@test "Does NOT contain 'date -s' (errata #8)" {
  ! grep -q 'date -s' "$INIT_PKI"
}

@test "Uses faketime for backdating (errata #8)" {
  assert_file_contains "$INIT_PKI" 'faketime'
}

@test "Creates chain file" {
  assert_file_contains "$INIT_PKI" 'chain.${CA_DOMAIN}.crt.pem'
}

@test "Sets restrictive permissions on private keys" {
  assert_file_contains "$INIT_PKI" 'chmod 400'
}
