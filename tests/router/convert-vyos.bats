#!/usr/bin/env bats

load '../helpers/setup'

setup() {
  setup_tempdir
}

teardown() {
  teardown_tempdir
}

@test "Parses Eth0AdminConfig.sh" {
  run bash "$SCRIPTS_DIR/convert-vyos.sh" "$VYOS_DIR/Eth0AdminConfig.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"172.30.7.254/21"* ]]
}

@test "Parses Eth1ServicesConfig.sh — first line is 8.8.8.1/24" {
  run bash "$SCRIPTS_DIR/convert-vyos.sh" "$VYOS_DIR/Eth1ServicesConfig.sh"
  [ "$status" -eq 0 ]
  first_line="$(echo "$output" | head -1)"
  [ "$first_line" = "8.8.8.1/24" ]
}

@test "Parses Eth1ServicesConfig.sh — output has exactly 20 lines" {
  bash "$SCRIPTS_DIR/convert-vyos.sh" "$VYOS_DIR/Eth1ServicesConfig.sh" > "$TEST_TMPDIR/services.txt"
  assert_line_count "$TEST_TMPDIR/services.txt" 20
}

@test "Parses Eth2GrayConfig.sh — output has >1400 lines, all valid CIDR" {
  bash "$SCRIPTS_DIR/convert-vyos.sh" "$VYOS_DIR/Eth2GrayConfig.sh" > "$TEST_TMPDIR/gray.txt"
  assert_line_count_gt "$TEST_TMPDIR/gray.txt" 1400
  assert_all_valid_cidr "$TEST_TMPDIR/gray.txt"
}

@test "Parses Eth3RangeWAN.sh" {
  run bash "$SCRIPTS_DIR/convert-vyos.sh" "$VYOS_DIR/Eth3RangeWAN.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"1.1.1.1/29"* ]]
}

@test "Skips comments and blank lines" {
  cat > "$TEST_TMPDIR/test.sh" <<'EOF'
#!/bin/vbash
# This is a comment

source /opt/vyatta/etc/functions/script-template

configure
# Another comment
set interfaces ethernet eth0 address 10.0.0.1/24

commit
save
exit
EOF
  run bash "$SCRIPTS_DIR/convert-vyos.sh" "$TEST_TMPDIR/test.sh"
  [ "$status" -eq 0 ]
  # Should have exactly one line
  [ "$(echo "$output" | wc -l)" -eq 1 ]
  # No lines starting with #
  ! echo "$output" | grep -q '^#'
  # No empty lines in output
  ! echo "$output" | grep -q '^$'
}

@test "Each output line is valid CIDR" {
  bash "$SCRIPTS_DIR/convert-vyos.sh" "$VYOS_DIR/Eth1ServicesConfig.sh" > "$TEST_TMPDIR/out.txt"
  assert_all_valid_cidr "$TEST_TMPDIR/out.txt"
}
