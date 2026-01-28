#!/usr/bin/env bats
# Tests for .env.example (errata #6, #16)

load '../helpers/setup'

ENV_FILE="$PROJECT_ROOT/.env.example"

@test ".env.example exists" {
  assert_file_exists "$ENV_FILE"
}

@test ".env.example defines PROXY_URL (errata #16)" {
  assert_file_contains "$ENV_FILE" 'PROXY_URL'
}

@test ".env.example has RECURSIVE_DNS_IP" {
  assert_file_contains "$ENV_FILE" 'RECURSIVE_DNS_IP'
}

@test ".env.example has DEFAULT_DECOY_SITE" {
  assert_file_contains "$ENV_FILE" 'DEFAULT_DECOY_SITE'
}

@test ".env.example has CS_SOCKS_PROXY1" {
  assert_file_contains "$ENV_FILE" 'CS_SOCKS_PROXY1'
}

@test ".env.example has CS_SOCKS_PROXY2" {
  assert_file_contains "$ENV_FILE" 'CS_SOCKS_PROXY2'
}

@test ".env.example has NRTS_IFACE" {
  assert_file_contains "$ENV_FILE" 'NRTS_IFACE'
}

@test ".env.example has PROXY_PORT" {
  assert_file_contains "$ENV_FILE" 'PROXY_PORT'
}

@test ".env.example has CA_DOMAIN" {
  assert_file_contains "$ENV_FILE" 'CA_DOMAIN'
}

@test ".env.example has DOWNLOAD_WEBSITES" {
  assert_file_contains "$ENV_FILE" 'DOWNLOAD_WEBSITES'
}
