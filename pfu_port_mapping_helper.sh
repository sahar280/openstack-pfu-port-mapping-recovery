#!/bin/bash

FILTER="$1"

if [ -z "$FILTER" ]; then
    echo "Usage: $0 <grep-pattern>"
    exit 1
fi

TRUNK_IDS=$(openstack network trunk list | grep -i "$FILTER" | awk -F'|' '{gsub(/ /,"",$2); print $2}')

for TRUNK_ID in $TRUNK_IDS
do
    TRUNK_NAME=$(openstack network trunk show "$TRUNK_ID" -f value -c name)

    echo "############################################"
    echo "Processing TRUNK: $TRUNK_NAME ($TRUNK_ID)"
    echo "############################################"

    echo
    echo "===== SUBPORT DETAILS ====="

    # Show subports + inline commands
    openstack network trunk show "$TRUNK_ID" | \
    grep "port_id='" | \
    while read line
    do
        SUBPORT_ID=$(echo "$line" | sed -n "s/.*port_id='\([^']*\)'.*/\1/p")
        VLAN_ID=$(echo "$line" | sed -n "s/.*segmentation_id='\([^']*\)'.*/\1/p")

        echo "----------------------------------------"
        echo "Sub-port: $SUBPORT_ID  | VLAN: $VLAN_ID"
        echo "----------------------------------------"

        openstack port show "$SUBPORT_ID"
        echo

        echo "UNSET CMD:"
        echo "openstack network trunk unset --subport $SUBPORT_ID $TRUNK_NAME"

        echo "SET CMD:"
        echo "openstack network trunk set --subport port=$SUBPORT_ID,segmentation-type=vlan,segmentation-id=$VLAN_ID $TRUNK_NAME"

        echo
    done

    echo "========== CLEAN COMMAND SUMMARY =========="

    # First print ALL UNSET commands
    echo "--- UNSET COMMANDS ---"
    openstack network trunk show "$TRUNK_ID" | \
    grep "port_id='" | \
    while read line
    do
        SUBPORT_ID=$(echo "$line" | sed -n "s/.*port_id='\([^']*\)'.*/\1/p")
        echo "openstack network trunk unset --subport $SUBPORT_ID $TRUNK_NAME"
    done

    echo
    echo "--- SET COMMANDS ---"

    # Then print ALL SET commands
    openstack network trunk show "$TRUNK_ID" | \
    grep "port_id='" | \
    while read line
    do
        SUBPORT_ID=$(echo "$line" | sed -n "s/.*port_id='\([^']*\)'.*/\1/p")
        VLAN_ID=$(echo "$line" | sed -n "s/.*segmentation_id='\([^']*\)'.*/\1/p")

        echo "openstack network trunk set --subport port=$SUBPORT_ID,segmentation-type=vlan,segmentation-id=$VLAN_ID $TRUNK_NAME"
    done

    echo "==========================================="
    echo

done







