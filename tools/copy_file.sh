#!/bin/bash

id="ultract2"
pw="ultract2"

vmx_file_path="/mnt/RAM_disk/vmware/Tester_1/Tester_1.vmx"
#vmx_file_path="/home/ultract/vmware/Debian_Tester_1/Debian_Tester_1.vmx"
#vmx_file_path="/home/ultract/vmware/Ubuntu_Tester_1/Ubuntu_Tester_1.vmx"
#vmx_file_path="/home/ultract/vmware/Ubuntu_Tester_1_18.04/Ubuntu_Tester_1.vmx"
#vmx_file_path="/mnt/RAM_disk/vmware/Tester_2/Tester_2.vmx"

if [[ $# -le 2 ]];then
	echo "[CAUTION] Check VMX File Path & Login ID/PW"
	echo "Usage: $0 <0:Guest To Host or 1:Host To Guest> <Absolute or Relative Path of Source File> <Absolute or Relative Path of Destination File>"
	exit 1
fi

if [[ "$1" -eq "0" ]];then
	vmrun -T ws -gu "$id" -gp "$pw" copyFileFromGuestToHost "$vmx_file_path" "$2" "$3"
elif [[ "$1" -eq "1" ]];then
	vmrun -T ws -gu "$id" -gp "$pw" copyFileFromHostToGuest "$vmx_file_path" "$2" "$3"
fi
