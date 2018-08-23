#!/bin/bash

#set -x

#
# Automate Performance Test For Tailored Kernel in Virtual Machine
#
# Usage: ./auto_performance_test_vm.sh  [Target OS Number] [Email Address]
#
# 		                                0:gooroom, 1:debian, 2:ubuntu
# E.g. ./auto_performance_test.vm.sh 0 ultractgm@gmail.com
#
#

if [ $# -le 1 ];
then
	echo "./auto_performance_test_vm.sh  [Target OS Number] [Email Address]"
	echo "                                    0:gooroom, 1:debian, 2:ubuntu"
	exit 1
fi

SECONDS=0

guser="ultract2"
gpw="ultract2"
vmx_file="/mnt/RAM_disk/vmware/Tester_1/Tester_1.vmx"

gooroom=0
debian=1
ubuntu=2
#target_os=$gooroom
target_os=$1

email_addr="$2"

vm_state_file="performance_test_state.txt"

target_os_name[0]="gooroom"
target_os_name[1]="debian"
target_os_name[2]="ubuntu"

case "${target_os}" in
	0)   
		#    
		# Gooroom
		terminal_name="/usr/bin/xfce4-terminal"
		terminal_option="-x"
		;;  

	1)   
		#    
		# Debian
		terminal_name="/usr/bin/gnome-terminal"
		terminal_option="--"
		;;   

	2)   
		#    
		# Ubuntu
		terminal_name="/usr/bin/gnome-terminal"
		terminal_option="--"
		;;   
esac 

echo "Copy Script File to Test Performance For Virtual Machine..." 
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_file" ~/auto-kernel-tailoring/tools/performance_eval.sh "/home/$guser/use-case.sh"

echo "Run Script File to Test Performance..."
vmrun -T ws -gu "$guser" -gp "$gpw" runProgramInGuest "$vmx_file" -noWait "/usr/bin/env" "DISPLAY=:0" "$terminal_name" "$terminal_option" "/home/$guser/use-case.sh"

#echo "Copy extract-vmlinux File to Virtual Machine..."
#vmrun -T ws -gu "$guser" -gp "$gpw" copyFleFromHostToGuest "$vmx_file" $(find /mnt/RAM_disk -maxdepth 1 -type d -name linux-* 2>/dev/null)/scripts/extract-vmlinux "/home/$guser/extract-vmlinux"

# Print Ending Time & Time Difference 
duration=$SECONDS
echo -e "$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed..."

#
# Check Kernel Trace VM whether Firtst Kernel Tailoring Finished by Undertaker
#
rm -rf "/tmp/$vm_state_file"

while true
do
	echo "Waiting Finish to Test Performance of VM..."

	# Get State File of VM
	exit_code=$(vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_file" "/tmp/$vm_state_file" "/tmp/$vm_state_file")

	#[ ! -f "/tmp/$vm_state_file" ] && { echo "State File does not exist"; break; }
	[ ! -f "/tmp/$vm_state_file" ] && { echo "State File does not exist"; }
	#[ ! -s "/tmp/$vm_state_file" ] && { echo "State File is Empty"; break; }
	[ ! -s "/tmp/$vm_state_file" ] && { echo "State File is Empty"; }

	vm_state=$(cat /tmp/$vm_state_file)
	
	if [ "$vm_state" == "2.0" ]
	then
		echo "Phoronix-test-Suite - Tailored Kernel..."

	elif [ "$vm_state" == "2.1" ]
	then
		echo "Phoronix-test-Suite - Original Kernel..."

	elif [ "$vm_state" == "2.2" ]
	then
		echo "Lmbench - Tailored Kernen..."

	elif [ "$vm_state" == "2.3" ]
	then
		echo "Lmbench - Tailored Kernen..."
	
	elif [ "$vm_state" == "2.4" ]
	then
		echo "Finished Performance Test..."
		echo "Archive Performance Test Results..."
	
	elif [ "$vm_state" == "2.5" ]
	then
		echo "Copy Archive File to Host..."
		vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_file" "/home/$guser/$(date '+%y%m%d')"-performance_result.tar.gz "/tmp/$(date '+%y%m%d')"-performance_result.tar.gz
		#vmrun -T ws -gu "ultract2" -gp "ultract2" copyFileFromGuestToHost "/mnt/RAM_disk/vmware/Tester_1/Tester_1.vmx" "/home/ultract2/$(date '+%y%m%d')"-performance_result.tar.gz "/tmp/$(date '+%y%m%d')"-performance_result.tar.gz

		echo "Send the Archive File by Email..."
		echo "$(date '+%Y-%m-%d %H:%M:%S') Sended a Test Result" | mutt -s "Performance Test Result - Tailored Kernel For ${target_os_name[$target_os]}" "$email_addr" -a "/tmp/$(date '+%y%m%d')-performance_result.tar.gz"
		break
	fi
	sleep 60
done

# Print Ending Time & Time Difference 
duration=$SECONDS
echo -e "$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed..."
