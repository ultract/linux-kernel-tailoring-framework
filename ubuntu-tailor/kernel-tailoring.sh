#!/bin/bash

#guest_kernel_ver="guest_kernel_ver.dat"
guest_kernel_src="guest_kernel_src.dat"
org_kern_conf="org_kern_conf.dat"
vm_a_state_file="VM-A-State.dat"

undertaker_whitelist="whitelist.x86_64"
undertaker_ignore="undertaker.ignore"

lsmod_file="lsmod_result.txt"

# Write UseCase State
echo "3" > /tmp/$vm_a_state_file

# Stop Collecting Kernel Trace
echo "Stop Collecting Kernel Features Trace..."
sudo undertaker-tracecontrol stop
sudo chmod og+r /run/undertaker-trace.out

# Copy Configuration Files of undertaker
sudo cp ~/"$undertaker_whitelist" /usr/local/etc/undertaker/
#sudo cp ~/"$undertaker_ignore" /usr/local/etc/undertaker/

# Kernel Source File Patch
cd ~/linux-*
# This Patch is from Andreas Debian Kernel Patch.
#sed -i '/#define SYMBOL_NEW        0x200000/c\#define SYMBOL_NEW        0x400000' ./scripts/kconfig/expr.h

# Save to File About List of Kernel Modules
sudo lsmod > ./"$lsmod_file"

# Create .config file of Tailored Kernel
echo "Derive Tailored .config by Undertatker..."
/usr/local/bin/undertaker-tailor -a -c -d \
-k /usr/lib/debug/lib/modules/`uname -r` \
-e /usr/lib/debug/boot/vmlinux-`uname -r` \
   /run/undertaker-trace.out

# Check Kernel Tailoring Success.
if [ ! -f "./.config" ]
then
	echo "Kernel Tailoring Failed by Undertaker! :("
	echo "-1" > /tmp/$vm_a_state_file
        exit 1
fi

# Achieve Directory of Kernel Source to Tar Gzip
echo "Compress Directory of Kernel Source to Tar Gzip..."
kernel_dir_name=$(ls ~/ | grep 'linux-*' | head -1)
cd ~/
tar cvfz ./"$kernel_dir_name.tar.gz" ./$kernel_dir_name/*

# Write the Kernel Directory Name
#/bin/uname -r > "/tmp/$guest_kernel_ver"
ls ~/ | grep -E 'linux-.*tar.gz' > /tmp/"$guest_kernel_src"

# Write the File Name of Original Config file in Guest VM
ls /boot/ | grep "config-$(uname -r)" > /tmp/"$org_kern_conf"

# Change State of VM-A after Kernel Tailoring
echo "0" > /tmp/$vm_a_state_file
