#!/usr/bin/env bats
# Integration test: SSL certificate validation

load '../helpers/setup'

setup() {
  require_docker_compose
  skip "Integration test: requires running stack with certs"
}

@test "openssl s_client to owncloud IP succeeds" {
  run bash -c "echo | openssl s_client -connect ${OWNCLOUD_IP:-180.1.1.100}:443 -servername dropbox.com 2>/dev/null | openssl x509 -noout -subject"
  [ "$status" -eq 0 ]
  [[ "$output" == *"dropbox.com"* ]]
}

@test "Cert is signed by range CA" {
  issuer=$(echo | openssl s_client -connect ${OWNCLOUD_IP:-180.1.1.100}:443 -servername dropbox.com 2>/dev/null | openssl x509 -noout -issuer)
  [[ "$issuer" == *"${CA_ORG:-Global Certificate Authority}"* ]]
}
