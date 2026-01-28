#!/usr/bin/env bats
# Integration test: DNS resolution

load '../helpers/setup'

setup() {
  require_docker_compose
  skip "Integration test: requires running stack with DNS"
}

@test "dig @198.41.0.4 dropbox.com returns IP" {
  result=$(dig @198.41.0.4 dropbox.com +short)
  [ -n "$result" ]
}

@test "dig @8.8.8.8 gmail.com returns IP" {
  result=$(dig @8.8.8.8 gmail.com +short)
  [ -n "$result" ]
}

@test "OPFOR zones resolve" {
  result=$(dig @198.41.0.4 example.com +short)
  [ -n "$result" ]
}
