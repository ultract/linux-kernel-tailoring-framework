#!/bin/bash

guser="ultract"
gpw="ultract"

vmx_guest_a="$1"
vm_a_state_file="VM-A-State.dat"

while true
do
        exit_code=$(vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_guest_a" "/tmp/$vm_a_state_file" ~/)
        vm_state=$(cat ~/$vm_a_state_file)
	echo $exit_code
        #if [ -z "$exit_code" ] && [ "$vm_state" -eq "1" ]
        if [ -z "$exit_code" ] && [ "$vm_state" == "1" ]
        #if [ "${exit_code:0:5}" != "Error" ]
        then
                break
        fi
done
