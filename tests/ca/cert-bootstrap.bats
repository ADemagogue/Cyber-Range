#!/usr/bin/env bats
# Tests for cert-bootstrap (errata #9)

load '../helpers/setup'

GEN_CERTS="$DOCKER_DIR/cert-bootstrap/generate-certs.sh"

@test "generate-certs.sh exists and is executable" {
  assert_file_exists "$GEN_CERTS"
  [ -x "$GEN_CERTS" ]
}

@test "Generates cert for dropbox.com" {
  assert_file_contains "$GEN_CERTS" 'dropbox.com'
}

@test "Generates cert for pastebin.com" {
  assert_file_contains "$GEN_CERTS" 'pastebin.com'
}

@test "Generates cert for redbook.com" {
  assert_file_contains "$GEN_CERTS" 'redbook.com'
}

@test "Generates cert for diagrams.net" {
  assert_file_contains "$GEN_CERTS" 'diagrams.net'
}

@test "Generates cert for msftconnecttest.com" {
  assert_file_contains "$GEN_CERTS" 'msftconnecttest.com'
}

@test "Copies chain.pem to output directory" {
  assert_file_contains "$GEN_CERTS" 'chain.pem'
}

@test "Waits for CA PKI to be ready before generating" {
  assert_file_contains "$GEN_CERTS" 'Waiting for CA PKI'
  assert_file_contains "$GEN_CERTS" 'MAX_WAIT'
}

@test "CA Dockerfile has healthcheck verifying cert files exist" {
  assert_file_contains "$DOCKER_DIR/ca/Dockerfile" 'HEALTHCHECK'
  assert_file_contains "$DOCKER_DIR/ca/Dockerfile" 'root.crt.pem'
}

@test "Output includes .crt and .key for each domain" {
  assert_file_contains "$GEN_CERTS" '${OUTPUT_DIR}/${domain}.crt'
  assert_file_contains "$GEN_CERTS" '${OUTPUT_DIR}/${domain}.key'
}
