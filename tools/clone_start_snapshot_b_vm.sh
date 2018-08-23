#!/bin/bash

#
# After Power OFF Source VM, Execute This Script
#

# VMX File of Source VM
org_vmx_path="/mnt/RAM_disk/vmware/Tester_1/Tester_1.vmx"

# Clone
for i in $(seq 2 8)
do
	echo "Clone VM-$i..."
	vmrun -T ws clone "$org_vmx_path" /mnt/RAM_disk/vmware/Tester_$i/Tester_$i.vmx full -cloneName=Tester_$i
done

# Start
for i in $(seq 2 8)
do
	echo "Start VM-$i..."
	vmrun -T ws start /mnt/RAM_disk/vmware/Tester_$i/Tester_$i.vmx
	sleep 5
done

# Wait VMs
sleep 180

# Snapshot
for i in $(seq 2 8)
do
	echo "Snapshot VM-$i..."
	vmrun -T ws snapshot /mnt/RAM_disk/vmware/Tester_$i/Tester_$i.vmx "Snapshot 1" &
	sleep 2
done

