#!/bin/bash

usecase_script="use-case.sh"
autostart_file="Use-Case-Script.desktop"
vm_b_state_file="VM-B-State.dat"

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
# Write UseCase State
#
echo "1" > /tmp/$vm_b_state_file

#
# Kill Processes belonging apt or dpkg lock
#
kill_apt_dpkg_lock_pid

#
# Upgrade Packages
#
#sudo apt update && sudo apt upgrade -y

#
# Stop Packagekit Service
#
#sudo systemctl stop packagekit
#sudo pkill -9 packagekitd

#
# Edit PackageKit Systemd Unit
#
sudo sed -i 's/ExecStart/#ExecStart/g' /lib/systemd/system/packagekit.service

#
# Save checksec Kernel Analysis
#
sudo ~/checksec.sh/checksec --kernel > ~/before_checksec.txt

#
# Save sysctl info file
#
sudo sysctl -a &> ~/before_sysctl.txt

#
# Save Phoronix System Info
#
sudo apt install php-cli php-xml -y
#wget http://phoronix-test-suite.com/releases/phoronix-test-suite-8.0.0.tar.gz -P ~/
#tar xvfz ~/phoronix-test-suite-8.0.0.tar.gz --directory ~/
echo -e "y\ny\ny\n" | ~/phoronix-test-suite/phoronix-test-suite system-info
temp="$LS_COLORS"
LS_COLORS=""
~/phoronix-test-suite/phoronix-test-suite system-info > ~/before_system_info.txt
LS_COLORS="$temp"

#
# Save systemd services
#
#systemd-analyze blame &> ~/before_systemd-analyze.txt
systemctl --all | grep "  loaded  " | awk '{print $1}' &> ~/before_systemd_units.txt

#
# Save journalctl Log(emerg" (0), "alert" (1), "crit" (2), "err" (3))
#
#sudo journalctl -p3 | sed 's/^[A-Za-z]\+ [0-9]\+ [0-9]\+:[0-9]\+:[0-9]\+ [a-zA-Z]\+ [a-zA-Z0-9]\+\[[0-9]\+\]: //g' | sed 's/^[A-Za-z]\+ [0-9]\+ [0-9]\+:[0-9]\+:[0-9]\+ [a-zA-Z0-9]\+ //g' | sed 's/\[[0-9]\+\]//g' | sort -u | grep -v "^--" &> ~/before_journalctl_log.txt
#sudo journalctl -p3 | sed 's/^ [0-9]\+월 [0-9]\+ [0-9]\+:[0-9]\+:[0-9]\+ [a-zA-Z0-9]\+ [a-zA-Z0-9\-]\+\[[0-9]\+\]: //g' | sed 's/^ [0-9]\+월 [0-9]\+ [0-9]\+:[0-9]\+:[0-9]\+ [a-zA-Z0-9]\+ [a-zA-Z0-9\-]\+: //g' | sort -u | grep -v "^--" &> ~/before_journalctl_log.txt
sudo journalctl -p3 -o verbose | grep "MESSAGE=" | awk -F'=' '{print $2}' | sed 's/\[[0-9]\+\]: //g' | sort -u &> ~/before_journalctl_log.txt

#
# Save mounted file systems
#
mount | awk '{print $5}' | sort | uniq > ~/before_mount_fs.txt

#
# Stop Packagekit Service
#
#sudo systemctl stop packagekit
#sudo pkill -9 packagekitd

#
# Install Tailored Kernel & Reboot
#
kernel_image_deb=$(ls ~/ | grep -E '^linux-image-.*deb$')
sudo dpkg -i ~/$kernel_image_deb

# Add Autostart For Executing Usecase
echo "Added AutoStart File..."
sudo cp ~/"$autostart_file" /etc/xdg/autostart/

# Reboot Guest-A Machine
echo "Reboot After 3-Seconds..."
sleep 3
sudo reboot
