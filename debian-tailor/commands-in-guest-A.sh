#!/bin/bash

usecase_script="use-case.sh"
autostart_file="Use-Case-Script.desktop"
initrd_install="undertaker-tracecontrol-prepare-debian"
vm_a_state_file="VM-A-State.dat"

#undertaker_whitelist="whitelist.x86_64"
#undertaker_ignore="undertaker.ignore"

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
# Download undertaker tool
#
echo "Download undertaker tool..."
cd ~/
# From erlangen.de(Mainstream)
#git clone https://i4gerrit.informatik.uni-erlangen.de/undertaker ~/undertaker

# From bitbucket of ultract(Customized Version)
#git clone https://ultract@bitbucket.org/ultract/undertaker.git ~/undertaker
git clone https://github.com/ultract/previous-undertaker-tailor.git ~/undertaker

#
# Install dependency packages of undertaker
#
echo "Install dependency packages of undertaker..."
sudo apt-get install python-pip -y
sudo pip install whatthepatch
sudo apt-get install libboost1.62-dev -y
sudo apt-get install libboost-filesystem1.62-dev -y
sudo apt-get install libboost-regex1.62-dev -y
sudo apt-get install libboost-thread1.62-dev -y
sudo apt-get install libboost-wave1.62-dev -y
sudo apt-get install libpuma-dev -y
sudo apt-get install libpstreams-dev -y
sudo apt-get install check -y
sudo apt-get install python-unittest2 -y
sudo apt-get install clang -y
sudo apt-get install flex -y
sudo apt-get install libsubunit-dev -y
sudo apt-get install sparse -y
sudo apt-get install pylint -y
sudo apt-get install bison -y

#
# Build undertaker & Install
#
echo "Build undertaker & Install..."
cd ~/undertaker
#make -j10
#sudo make install
# Enable Debug Mode of undertaker
make clean && make DEBUG="-g3 -DDEBUG" && sudo make install
#make clean && STATIC=1 make DEBUG="-g3 -DDEBUG" && sudo make install

# Copy Configuration Files of undertaker
#sudo cp ~/"$undertaker_whitelist" /usr/local/etc/undertaker/
#sudo cp ~/"$undertaker_ignore" /usr/local/etc/undertaker/

# Install Debug Symbol of Kernel
#echo "Install Debug Symbol of Kernel..."
sudo apt-get install linux-image-`uname -r`-dbg -y

# Install dpkg-dev
#echo "Install dpkg-dev Package"
sudo  apt-get install dpkg-dev -y

##############################################################################
# Download linux kernel source
#
echo "Download linux kernel source..."
cd ~/

#
# Download Linux Kernel Source from Debian Repository
# if Debian Kernel Tailoring
#
apt-get source linux-image-$(uname -r)
#apt-get source linux-source-4.7

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
undertaker-kconfigdump -i x86

#
# Install initrd.ftrace file
#
echo "Execute initrd.ftrace file..."
#sudo cp ~/"$initrd_install" /usr/local/bin/"$initrd_install" 
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
if [ ! -f "/boot/$initrd_str.ftrace" ]	# LVM
#if [ ! -f "$initrd_str.ftrace" ] # Not Using LVM
then
	echo "Not Exist initrd.ftrace file"
	exit -1
fi
sudo sed -i "s@$initrd_str@$initrd_str\.ftrace@" /boot/grub/grub.cfg

# Reboot Guest-A Machine
echo "Reboot After 3-Seconds..."
sleep 3
sudo reboot
