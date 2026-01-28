#!/usr/bin/env bats
# Integration test: cross-network reachability

load '../helpers/setup'

setup() {
  require_docker_compose
  skip "Integration test: requires running stack with networking"
}

@test "Admin subnet can reach services gateway" {
  run ping -c 1 -W 2 180.1.1.1
  [ "$status" -eq 0 ]
}

@test "Services subnet is reachable" {
  run ping -c 1 -W 2 180.1.1.100
  [ "$status" -eq 0 ]
}

@test "WAN interface reachable" {
  run ping -c 1 -W 2 1.1.1.1
  [ "$status" -eq 0 ]
}
