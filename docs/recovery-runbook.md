# PFU Port Mapping Recovery Runbook

This runbook documents the human-controlled workflow around the original
read-only helper. It is not a substitute for an approved production MOP.

## Before VM removal

1. Confirm the correct OpenStack project and affected PFU workload.
2. Run the helper with a sufficiently specific trunk-name pattern.
3. Save the complete output in the approved operational record.
4. Verify trunk ID, trunk name, subport IDs, VLAN segmentation IDs, and port details.
5. Review the grouped `UNSET COMMANDS`; do not execute unintended matches.
6. Follow the approved process to unbind or remove only the required resources.
7. Confirm infrastructure/controller state before asking the VNF team to proceed.

## VM recreation and network restoration

1. Ask the VNF team to recreate the VM on a healthy compute node.
2. Confirm the new VM and its required parent/trunk port are available.
3. Review the saved `SET COMMANDS` against the recorded mapping.
4. Execute approved commands individually while checking for errors.
5. Re-run trunk and port show commands to confirm the restored relationships.
6. Validate VM connectivity and service health with the VNF team.
7. Attach sanitized evidence to the incident/change record.

## Rollback principle

Stop on an unexpected port, VLAN, project, or command error. Preserve the
current state and follow the approved escalation or rollback procedure rather
than continuing with the remaining generated commands.
