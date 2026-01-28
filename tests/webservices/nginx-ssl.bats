#!/usr/bin/env bats
# Tests for nginx SSL configuration

load '../helpers/setup'

@test "Owncloud nginx references certs from /SSL/ volume" {
  assert_file_contains "$WEBSERVICES_DIR/owncloud/config/nginx.conf" 'ssl_certificate /SSL/'
}

@test "Pastebin nginx references certs from /SSL/ volume" {
  assert_file_contains "$WEBSERVICES_DIR/pastebin/config/nginx.conf" 'ssl_certificate /SSL/'
}

@test "Redbook nginx references certs from /SSL/ volume" {
  assert_file_contains "$WEBSERVICES_DIR/redbook/config/nginx.conf" 'ssl_certificate /SSL/'
}

@test "Drawio nginx references certs from /SSL/ volume" {
  assert_file_contains "$WEBSERVICES_DIR/drawio/config/nginx.conf" 'ssl_certificate /SSL/'
}

@test "MS Sites nginx references certs from /SSL/ volume" {
  assert_file_contains "$WEBSERVICES_DIR/ms_sites/config/nginx.conf" 'ssl_certificate /SSL/'
}

@test "No hardcoded cert paths like /root/owncloud/SSL" {
  for dir in owncloud pastebin redbook drawio ms_sites; do
    assert_file_not_contains "$WEBSERVICES_DIR/$dir/config/nginx.conf" '/root/'
  done
}
