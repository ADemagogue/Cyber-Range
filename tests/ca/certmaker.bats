#!/usr/bin/env bats
# Tests for certmaker.sh

load '../helpers/setup'

CERTMAKER="$PROJECT_ROOT/ca/scripts/certmaker.sh"

@test "certmaker.sh exists" {
  assert_file_exists "$CERTMAKER"
}

@test "certmaker.sh supports -d flag for domain" {
  assert_file_contains "$CERTMAKER" '\-d|--domain'
}

@test "certmaker.sh supports -r flag for random" {
  assert_file_contains "$CERTMAKER" '\-r|--random'
}

@test "certmaker.sh supports SAN extensions" {
  assert_file_contains "$CERTMAKER" 'subjectAltName'
}

@test "certmaker.sh generates .crt output" {
  assert_file_contains "$CERTMAKER" '\.crt'
}

@test "certmaker.sh generates .p12 output" {
  assert_file_contains "$CERTMAKER" '\.p12'
}

@test "certmaker.sh uses intermediate CA for signing" {
  assert_file_contains "$CERTMAKER" 'openssl_intermediate.cnf'
}
