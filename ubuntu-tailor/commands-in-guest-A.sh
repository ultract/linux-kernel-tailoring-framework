#!/bin/bash

usecase_script="use-case.sh"
autostart_file="Use-Case-Script.desktop"
initrd_install="undertaker-tracecontrol-prepare-ubuntu"
vm_a_state_file="VM-A-State.dat"

kill_apt_dpkg_lock_pid(){
        sudo lsof /var/lib/apt/lists/lock 2>/dev/null | awk '{print $2}' | grep "^[0-9]\+" | while read line;   
        do      
		sudo kill -9 $line
		echo "Killed Processes Having apt Lock"
        done
        
        sudo lsof /var/lib/dpkg/lock 2>/dev/null | awk '{print $2}' | grep "^[0-9]\+" | while read line;
        do      
                sudo kill -9 $line
		echo "Killed Processes Having dpkg Lock"
        done
}

#
# Kill Processes belonging apt or dpkg lock
#
kill_apt_dpkg_lock_pid

#
# Write UseCase State
#
echo "1" > /tmp/$vm_a_state_file

#undertaker_dir="~/undertaker"
# Set Environment Variables
#echo -e "\033[0;32mSet Environment Variables..."
echo "Set Environment Variables..."
export PATH=$PATH:/usr/local/bin:

#
# Update of Guest VM Linux
#
echo "Update of Guest State..." 
#sudo apt-get update && sudo apt-get upgrade -y
sudo apt update && sudo apt upgrade -y
sudo apt-get install git -y

#
# Install Ubuntu Drivers
#
echo "Install Ubuntu Drivers"
sudo ubuntu-drivers autoinstall

#
# Download undertaker tool
#
echo "Download undertaker tool..."
cd ~/
# From erlangen.de(Mainstream)
#git clone https://i4gerrit.informatik.uni-erlangen.de/undertaker ~/undertaker

# From bitbucket of ultract(Customized Version)
#git clone https://ultract@bitbucket.org/ultract/undertaker.git ~/undertaker

# From bitbucket of Original Undertaker(Latest Version)
#git clone https://ultract@bitbucket.org/ultract/undertaker-original.git ~/undertaker

# From github of Original Undertaker(Latest Version)
git clone https://github.com/ultract/original-undertaker-tailor.git ~/undertaker

#
# Install dependency packages of undertaker
#
echo "Install dependency packages of undertaker..."
<<'UBUNTU_16.04'
sudo apt install libboost1.58-dev -y
sudo apt install libboost-filesystem1.58-dev -y
sudo apt install libboost-regex1.58-dev -y
sudo apt install libboost-thread1.58-dev -y
sudo apt install libboost-wave1.58-dev -y
UBUNTU_16.04

#<<'UBUNTU_18.04'
sudo apt install libboost1.65-dev -y
sudo apt install libboost-filesystem1.65-dev -y
sudo apt install libboost-regex1.65-dev -y
sudo apt install libboost-thread1.65-dev -y
sudo apt install libboost-wave1.65-dev -y
#UBUNTU_18.04

sudo apt install libpuma-dev -y
sudo apt install libpstreams-dev -y 
sudo apt install check -y
sudo apt install python-unittest2 -y
sudo apt install clang -y
sudo apt install sparse -y
sudo apt install pylint -y
sudo apt install bison -y
sudo apt install flex -y

#
# Build undertaker & Install
#
echo "Build undertaker & Install..."
cd ~/undertaker
#make -j10
#sudo make install

<<'UBUNTU_18.04'
# Apply Patch For Inline Function Bug of GCC-7
echo "Apply Undertaker Patch"
git apply 0001-Patch-GCC-7-Inline-Function-Bug-From-Mainstream.patch
UBUNTU_18.04

# Enable Debug Mode of undertaker
make clean && make DEBUG="-g3 -DDEBUG" && sudo make install
#make clean && STATIC=1 make DEBUG="-g3 -DDEBUG" && sudo make install

# Install Debug Symbol of Kernel
echo "Install Debug Symbol of Kernel..."
<<'DEBUG_SYMBOL'
# Add Developer Repository
echo "deb http://ddebs.ubuntu.com $(lsb_release -cs) main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-updates main restricted universe multiverse
deb http://ddebs.ubuntu.com $(lsb_release -cs)-proposed main restricted universe multiverse" | \
sudo tee -a /etc/apt/sources.list.d/ddebs.list

# Install Kernel Debug Symbol Package

<<'UBUNTU_18.04' 
#sudo apt install ubuntu-dbgsym-keyring
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F2EDC64DC5AEE1F6B9C621F0C8CAB6595FDFF622
UBUNTU_18.04

wget -O - http://ddebs.ubuntu.com/dbgsym-release-key.asc | sudo apt-key add -
sudo apt update
sudo apt install linux-image-`uname -r`-dbgsym
DEBUG_SYMBOL

##############################################################################
# Download linux kernel source
#
echo "Download linux kernel source..."
cd ~/

#
# Download Linux Kernel Source from Debian Repository
# if Debian Kernel Tailoring
#

# Install dpkg-dev
#echo "Install dpkg-dev Package"
sudo apt-get install dpkg-dev -y
#apt-get source linux-image-$(uname -r)

#<<'UBUNTU_18.04'
sudo apt install linux-source-4.15.0 -y
sudo mv /usr/src/linux-source-4.15.0/linux-source-4.15.0.tar.bz2 ~/
tar xvjf linux-source-4.15.0.tar.bz2
rm -rf linux-source-4.15.0.tar.bz2
sudo apt remove linux-source-4.15.0 -y
#UBUNTU_18.04

##############################################################################


cd ~/linux-*

<<"KERNEL_SRC"
# From www. kernel.org
kernel_ver=$(uname -r)
#major_ver=${kernel_ver:0:1}
if [ "${kernel_ver:0:1}" -eq "4" ]	# Major Version Of Kernel
then
	ver_url="v4.x"
else
	ver_url="v3.x"
fi

kernel_ver=${kernel_ver:0:5}
if [ "${kernel_ver:4:1}" -eq "0" ]
then
	kernel_file="linux-${kernel_ver:0:3}.tar.gz"
else
	kernel_file="linux-$kernel_ver.tar.gz"
fi

wget -O ~/$kernel_file https://www.kernel.org/pub/linux/kernel/$ver_url/$kernel_file
tar xvfz ~/$kernel_file -C ~/
cd ~/linux-*
KERNEL_SRC

#
# Kconfig Analysis of Kernel
#
echo "Kconfig Analysis of Kernel"
#undertaker-kconfigdump x86
error_msg=$(undertaker-kconfigdump x86 2>&1)

# imply to select in Kconfig File
# Bug : undertaker-kconfigdump can't handle 'imply' attribute
if [ -n "$(echo "$error_msg" | grep "unknown option \"imply\"")" ];then
	echo "$error_msg" | grep "unknown option \"imply\"" | awk -F':' '{print $1}' | sort -u | while read line;
	do
		sed '/imply [A-Za-z0-9_]\+/ { s/imply /select /g }' -i "$line"
	done

	# Rerun undertaker-kconfigdump
	undertaker-kconfigdump x86
fi

#
# Install initrd.ftrace file
#
echo "Install & Execute initrd.ftrace file..."
sudo cp ~/"$initrd_install" /usr/local/bin/"$initrd_install" 
sudo "$initrd_install"

# Create a Service For Executing Usecase 
#sudo cp ~/"$usecase_script" /etc/init.d/
#sudo chmod 755 /etc/init.d/"$usecase_script"
#sudo update-rc.d "$usecase_script" defaults

#
# Add Autostart For Executing Usecase
#
echo "Add AutoStart File..."
sudo cp ~/"$autostart_file" /etc/xdg/autostart/

#
# Replace grub.cfg for initrd.ftrace
#
echo "Replace grub.cfg for initrd.ftrace..."
#initrd_str=$(grep "/boot\/initrd\.img-" /boot/grub/grub.cfg | head -n 1)
initrd_str=$(grep "/initrd\.img-" /boot/grub/grub.cfg | head -n 1 | awk '{print $2}') # LVM
#initrd_str=$(echo $initrd_str | cut -b8-)

# Checking initrd for ftrace exist
#if [ ! -f "/boot/$initrd_str.ftrace" ]	# LVM Partition
if [ ! -f "$initrd_str.ftrace" ] # Not Using LVM
then
	echo "Not Exist initrd.ftrace file"
	exit -1
fi
sudo sed -i "s@$initrd_str@$initrd_str\.ftrace@" /boot/grub/grub.cfg

# Reboot Guest-A Machine
echo "Reboot After 3-Seconds..."
sleep 3
sudo reboot
