#!/usr/bin/env bats
# Integration test: service health checks

load '../helpers/setup'

setup() {
  require_docker_compose
  skip "Integration test: requires running stack"
}

@test "CA server is healthy" {
  result=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" ps ca-server --format '{{.Health}}')
  [ "$result" = "healthy" ]
}

@test "Router is running" {
  result=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" ps router --format '{{.State}}')
  [ "$result" = "running" ]
}

@test "DNS is running" {
  result=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" ps rootdns --format '{{.State}}')
  [ "$result" = "running" ]
}

@test "Cert-bootstrap completed successfully" {
  result=$(docker compose -f "$PROJECT_ROOT/docker-compose.yml" ps cert-bootstrap --format '{{.State}}')
  [ "$result" = "exited" ]
}
