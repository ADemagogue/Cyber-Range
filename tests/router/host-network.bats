#!/usr/bin/env bats
# Errata #1, #15: Router must use host network mode, not macvlan

load '../helpers/setup'

@test "Router compose uses network_mode: host" {
  require_yq
  local result
  result="$(yq '.services.router.network_mode' "$PROJECT_ROOT/docker-compose.yml")"
  [ "$result" = "host" ]
}

@test "No macvlan network assigned to router" {
  require_yq
  local result
  result="$(yq '.services.router.networks // "null"' "$PROJECT_ROOT/docker-compose.yml")"
  [ "$result" = "null" ]
}

@test "No unused grayspace macvlan network defined for router" {
  # The grayspace network should not be assigned to the router service
  require_yq
  local nets
  nets="$(yq '.services.router.networks // "null"' "$PROJECT_ROOT/docker-compose.yml")"
  [[ "$nets" != *"grayspace"* ]]
}
