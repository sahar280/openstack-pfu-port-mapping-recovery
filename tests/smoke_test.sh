#!/bin/bash
set -e

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

cp "$ROOT_DIR/openstack" "$TEST_DIR/openstack"
chmod +x "$TEST_DIR/openstack"

PATH="$TEST_DIR:$PATH" bash "$ROOT_DIR/pfu_port_mapping_helper.sh" pfu-demo > "$TEST_DIR/output.txt"

[ "$(grep -c '^Processing TRUNK:' "$TEST_DIR/output.txt")" -eq 2 ]
[ "$(grep -c '^Sub-port:' "$TEST_DIR/output.txt")" -eq 16 ]
[ "$(grep -c '^UNSET CMD:$' "$TEST_DIR/output.txt")" -eq 16 ]
[ "$(grep -c '^SET CMD:$' "$TEST_DIR/output.txt")" -eq 16 ]
[ "$(grep -c '^--- UNSET COMMANDS ---$' "$TEST_DIR/output.txt")" -eq 2 ]
[ "$(grep -c '^--- SET COMMANDS ---$' "$TEST_DIR/output.txt")" -eq 2 ]

grep -q 'Processing TRUNK: pfu-demo-trunk-01' "$TEST_DIR/output.txt"
grep -q 'Processing TRUNK: pfu-demo-trunk-02' "$TEST_DIR/output.txt"
grep -q 'Sub-port: 21000000-0000-4000-8000-000000000001  | VLAN: 101' "$TEST_DIR/output.txt"
grep -q 'Sub-port: 22000000-0000-4000-8000-000000000008  | VLAN: 208' "$TEST_DIR/output.txt"
grep -q 'openstack network trunk unset --subport 21000000-0000-4000-8000-000000000001 pfu-demo-trunk-01' "$TEST_DIR/output.txt"
grep -q 'openstack network trunk set --subport port=22000000-0000-4000-8000-000000000008,segmentation-type=vlan,segmentation-id=208 pfu-demo-trunk-02' "$TEST_DIR/output.txt"

printf 'Synthetic PFU mapping smoke test passed: 2 trunks and 16 subports verified.\n'
