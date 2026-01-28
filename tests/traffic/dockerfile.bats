#!/usr/bin/env bats
# Tests for trafficgen Dockerfile proxy parameterization

load '../helpers/setup'

DOCKERFILE="$PROJECT_ROOT/trafficgen/Dockerfile"

@test "trafficgen Dockerfile exists" {
  assert_file_exists "$DOCKERFILE"
}

@test "trafficgen Dockerfile uses ARG HTTP_PROXY" {
  assert_file_contains "$DOCKERFILE" 'ARG HTTP_PROXY'
}

@test "Proxy is parameterized via build arg (not hardcoded)" {
  assert_file_not_contains "$DOCKERFILE" '172.30.0.2'
}

@test "ARG and ENV use same HTTP_PROXY variable" {
  assert_file_contains "$DOCKERFILE" 'ARG HTTP_PROXY'
  assert_file_contains "$DOCKERFILE" '${HTTP_PROXY}'
}
