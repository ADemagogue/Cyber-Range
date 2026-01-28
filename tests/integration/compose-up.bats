#!/usr/bin/env bats
# Integration test: full stack boot

load '../helpers/setup'

@test "docker compose config is valid" {
  require_docker_compose
  run docker compose -f "$PROJECT_ROOT/docker-compose.yml" config --quiet
  [ "$status" -eq 0 ]
}

@test "All services start without error" {
  require_docker_compose
  skip "Integration test: requires host setup and docker build"
  run docker compose -f "$PROJECT_ROOT/docker-compose.yml" up -d
  [ "$status" -eq 0 ]
}

@test "All healthchecks pass within 120s" {
  require_docker_compose
  skip "Integration test: requires running stack"
  # Poll docker compose ps until all services are healthy
  local timeout=120
  local elapsed=0
  while [ "$elapsed" -lt "$timeout" ]; do
    unhealthy=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" ps --format json | \
      jq -r 'select(.Health != "healthy" and .Health != "" and .Health != null) | .Name' | wc -l)
    [ "$unhealthy" -eq 0 ] && return 0
    sleep 5
    elapsed=$((elapsed + 5))
  done
  return 1
}
