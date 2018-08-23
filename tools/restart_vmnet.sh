#!/bin/bash

#
# Should Be Executed by Root Permission
# This File is On /etc/sudoers for NOPASSWD
# - Cmnd_Alias VMNET_RESTART = /home/ultract/auto-kernel-tailoring/tools/restart_vmnet.sh
# - ALL ALL = NOPASSWD:VMNET_RESTART

<<'COMMENT'
while true;
do
	echo "VMware vmnet service restart"
	sleep 3600
	/usr/bin/vmnet-bridge -s 12 -d /var/run/vmnet-bridge-0.pid -n 0 &
	/usr/bin/vmnet-netifup -s 12 -d /var/run/vmnet-netifup-vmnet1.pid /dev/vmnet1 vmnet1 &
	/usr/bin/vmnet-dhcpd -s 12 -cf /etc/vmware/vmnet1/dhcpd/dhcpd.conf -lf /etc/vmware/vmnet1/dhcpd/dhcpd.leases -pf /var/run/vmnet-dhcpd-vmnet1.pid vmnet1 &
	/usr/bin/vmnet-netifup -s 12 -d /var/run/vmnet-netifup-vmnet8.pid /dev/vmnet8 vmnet8 &
	/usr/bin/vmnet-dhcpd -s 12 -cf /etc/vmware/vmnet8/dhcpd/dhcpd.conf -lf /etc/vmware/vmnet8/dhcpd/dhcpd.leases -pf /var/run/vmnet-dhcpd-vmnet8.pid vmnet8 &
	/usr/bin/vmnet-natd -s 12 -m /etc/vmware/vmnet8/nat.mac -c /etc/vmware/vmnet8/nat/nat.conf &

done
COMMENT

while true;
do
	# Restart vmware-networks Every Two Hour
	sleep 7200
	echo "VMware vmnet Service Restart"
	sudo vmware-networks --stop &>/dev/null
	sudo vmware-networks --start &>/dev/null
	check_tailoring="$(ps aux | grep "commands-in-host" | grep -v "grep" | wc -l)"
	#if [ "$check_tailoring" -eq "0" ];
	if [ "$check_tailoring" -le "5" ];
	then
		echo "Exit vmnet_restarter.sh"
		break
	fi
done
