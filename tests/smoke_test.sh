#!/bin/bash
set -e

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

cp "$ROOT_DIR/tests/mock-bin/openstack" "$TEST_DIR/openstack"
chmod +x "$TEST_DIR/openstack"

PATH="$TEST_DIR:$PATH" bash "$ROOT_DIR/pfu_port_mapping_helper.sh" pfu-demo > "$TEST_DIR/output.txt"

grep -q 'Processing TRUNK: pfu-demo-trunk-01' "$TEST_DIR/output.txt"
grep -q 'Sub-port: 22222222-2222-4222-8222-222222222222  | VLAN: 101' "$TEST_DIR/output.txt"
grep -q 'openstack network trunk unset --subport 22222222-2222-4222-8222-222222222222 pfu-demo-trunk-01' "$TEST_DIR/output.txt"
grep -q 'openstack network trunk set --subport port=33333333-3333-4333-8333-333333333333,segmentation-type=vlan,segmentation-id=102 pfu-demo-trunk-01' "$TEST_DIR/output.txt"

printf 'Synthetic PFU mapping smoke test passed.\n'
