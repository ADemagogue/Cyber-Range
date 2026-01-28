#!/usr/bin/env bats
# Tests for all 10 buildredteam.sh env variable mappings (errata #6)

load '../helpers/setup'

ENTRYPOINT="$DOCKER_DIR/nrts/entrypoint.sh"

@test "All 10 buildredteam.sh vars have sed mappings in entrypoint" {
  # The 10 variables: intname, CAserver, capass, CAcrtpath, CAcert,
  # rootDNS, rootpass, recursDNS, defaultdecoysite, CSTSproxy1, CSTSproxy2
  # Actually 11 sed lines (CSTSproxy1 + CSTSproxy2 = 2)
  count=$(grep -c '^  sed -i' "$ENTRYPOINT")
  [ "$count" -ge 10 ]
}

@test "intname is mapped" {
  grep -q 'sed.*intname=' "$ENTRYPOINT"
}

@test "CAserver is mapped" {
  grep -q 'sed.*CAserver=' "$ENTRYPOINT"
}

@test "capass is mapped" {
  grep -q 'sed.*capass=' "$ENTRYPOINT"
}

@test "CAcrtpath is mapped" {
  grep -q 'sed.*CAcrtpath=' "$ENTRYPOINT"
}

@test "CAcert is mapped" {
  grep -q 'sed.*CAcert=' "$ENTRYPOINT"
}

@test "rootDNS is mapped" {
  grep -q 'sed.*rootDNS=' "$ENTRYPOINT"
}

@test "rootpass is mapped" {
  grep -q 'sed.*rootpass=' "$ENTRYPOINT"
}

@test "recursDNS is mapped" {
  grep -q 'sed.*recursDNS=' "$ENTRYPOINT"
}

@test "defaultdecoysite is mapped" {
  grep -q 'sed.*defaultdecoysite=' "$ENTRYPOINT"
}

@test "CSTSproxy1 is mapped" {
  grep -q 'sed.*CSTSproxy1=' "$ENTRYPOINT"
}

@test "CSTSproxy2 is mapped" {
  grep -q 'sed.*CSTSproxy2=' "$ENTRYPOINT"
}
