#!/bin/bash

# Debug Mode
#set -x

vm_b_state_file="VM-B-State.dat"
usecase_state_file="Usecase-State.dat"
usecase_log_file="usecase-log.dat"

auto_event_file="cnee_events.tar.gz"
default_event="default_event.xnr"
browser_event="browser_event.xnr"
benchmark_event="benchmark_event.xnr"


usecase_log(){
	echo "$1"
	echo "$1" >> ~/$usecase_log_file
	cp ~/"$usecase_log_file" /tmp/"$usecase_log_file"
}

watch_dog_lmbench(){
	sleep 300
	killall vi	# Kill vi for Filling System Info of Lmbench
}

watch_dog_process(){
	# Waiting
	echo "0" > ~/wdp_ret.txt         
	sleep 20
        
	if [ -n "$(ps aux | grep "$1$" | grep -v 'grep')" ];
        then
                pkill "$1"
                echo "-1" > ~/wdp_ret.txt
        fi
}

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
# Initialize Usecase Log
#
#rm -rf /tmp/"$usecase_log_file"


#
# Update Packages
#
#sudo apt update && sudo apt upgrade -y


#
# Install ping
#
#sudo apt install iputils-ping -y

#
# Install ssh server
#
sudo apt install openssh-server -y

#
# Check Usecase State
#
if [ ! -s ~/"$usecase_state_file" ];
then

	# Check ipv6 module From dmesg #
	if sudo dmesg | grep "systemd" | grep -q "Failed to insert module 'ipv6'";
	then
        	echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "ipv6 Module Loading Failed!!"
		usecase_log "ipv6 Module Loading Failed!!"
	fi

	# Check lsmod State #
	#elif lsmod | awk '{print $3}' | grep -q "-2";
	if [ "$(lsmod | awk '{print $3}' | sed '2q;d')" == "-2" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "Kernel Module Loading Failed!!"
		usecase_log "Kernel Module Loading Failed!!"
	fi

	# Check Kernel Module Status #
	if [ -n "$(sudo dmesg | grep 'Failed to start Load Kernel Modules')" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "Failed to start Load Kernel Modules"
		usecase_log "Failed to start Load Kernel Modules"
	fi
	
	# Check Keyboard Device #
	kb_check="0"
	while read line;
	do
        	#temp=$(grep "ID_INPUT_KEYBOARD=1" "$line")
	        #echo "$line"
        	if udevadm info "$line" | grep -q "ID_INPUT_KEYBOARD=1";
	        then
        	        #echo "$line"
                	kb_check=$(($kb_check+1))
	        fi
	done <<< "$(find /dev/input -type c 2>/dev/null)"

	if [ "$kb_check" -lt 1 ]
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "Keyboard Device Not Found!!"
		usecase_log "Keyboard Device Not Found!!"
	fi

	# Check Mouse Device #
	mouse_check="0"
	while read line;
	do
        	#temp=$(grep "ID_INPUT_KEYBOARD=1" "$line")
	        #echo "$line"
        	if udevadm info "$line" | grep -q "ID_INPUT_MOUSE=1";
	        then
        	        #echo "$line"
                	mouse_check=$(($mouse_check+1))
	        fi
	done <<< "$(find /dev/input -type c 2>/dev/null)"

	if [ "$mouse_check" -lt 1 ]
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "Mouse Device Not Found!!"
		usecase_log "Mouse Device Not Found!!"
	fi

	#elif [ -z "$(ls -al /dev/input/by-path | grep 'platform' | grep 'kbd')" ];
	# Modified for Gooroom 1.0 Beta 20171117
<<'COMMENT'
	# Speaker
	elif [ -z "$(ls -al /dev/input/by-path | grep 'platform' | grep 'spkr')" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
        	cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
		#echo "Keyboard Device Not Found!!"
		usecase_log "Keyboard Device Not Found!!"
		#sleep 2
		#exit

COMMENT
	if [ -z "$(ls -al /dev/input/by-path | grep 'mouse')" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "Mouse Device Not Found!!"
		usecase_log "Mouse Device Not Found!!"
	fi
	
	if [ -z "$(lsmod | awk '{print $1}' | grep 'psmouse')" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "Mouse Device Not Found!!"
		usecase_log "Mouse Device Not Found!!"
	fi

<<'COMMENT'
	# Check IPv4 Address Setting
	if [ -z "$(/sbin/ifconfig | grep '192.168.')" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "None Ethernet Device"
		usecase_log "IPv4 Address Not Set(ifconfig)"
	fi
COMMENT

	# Check IPv4 Address Setting #
	cn=0
	for i in $(seq 5)
	do
		if [ -z "$(/bin/ip a | grep '192.168.')" ];
		#if ! ping -c 1 192.168.2.1 >> /dev/null;
        	then
			cn=$((cn+1))
		fi
		sleep 5
	done
	if [ "$cn" -ge "5" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "IPv4 Address Not Set(ip)"
	fi

<<'COMMENT'
	# Check IPv6 Address Setting
	if [ -z "$(/sbin/ifconfig | grep "inet6 [a-z0-9]\+::")" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "None Ethernet Device"
		usecase_log "IPv6 Address Not Set(ifconfig)"
	fi
COMMENT

	# Check IPv6 Address Setting #
	cn=0
	for i in $(seq 5)
	do
		if [ -z "$(/bin/ip a | grep "inet6 [a-z0-9]\+::[a-z0-9:]\+")" ];
		#if ! ping -c 1 192.168.2.1 >> /dev/null;
        	then
			cn=$((cn+1))
		fi
		sleep 5
	done
	if [ "$cn" -ge "5" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "IPv6 Address Not Set(ip)"
	fi

	# Check Ping to Localhost #
	if ! ping -c 1 127.0.0.1 >> /dev/null;
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "Not Connected Internet!"
		usecase_log "Ping to Localhost(127.0.0.1) Failed"
	fi

	# Check Ping to Gateway #
<<'COMMENT'
	if ! ping -c 1 192.168.2.1 >> /dev/null;
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
        	#cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
		#echo "Not Connected Internet!"
		usecase_log "Ping to Gateway(192.168.2.1) Failed"
		#sleep 2
		#exit
	fi
COMMENT
	# Check Ping to Gateway #
	cn=0
	for i in $(seq 5)
	do
		if [ -z "$(ping -c 1 192.168.2.1 | grep '64 bytes from 192.168.2.1')" ];
		#if ! ping -c 1 192.168.2.1 >> /dev/null;
        	then
			cn=$((cn+1))
		fi
		sleep 5
	done
	if [ "$cn" -ge "5" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "Ping to Gateway(192.168.2.1) Failed"
	fi

<<'COMMENT'
	# Check Security Auditing Service
	elif sudo cat /var/log/syslog | grep -q "Failed to start Security Auditing Service";
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
        	cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
		echo "Failed to start Security Auditing Service!"
		#sleep 2
		#exit

COMMENT
	# Check Security Hardening Kernel #
	# Needed to Internet Connection
	#
	sudo apt install git -y
	sudo apt install binutils elfutils -y
	#git clone https://github.com/slimm609/checksec.sh

	# Compare checksec --kernel Result
	sudo ~/checksec.sh/checksec --kernel > after_checksec.txt
	comp_checksec_info="$(diff ~/before_checksec.txt ~/after_checksec.txt | grep -v "config-")"
	if [ -n "$(echo "$comp_checksec_info" | grep "> ")" ];then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		checksec_log_r="$(echo "$comp_checksec_info" | grep "> ")"
		checksec_log_l="$(echo "$comp_checksec_info" | grep "< ")"
		checksec_log="Before: $checksec_log_l After: $checksec_log_r"
		usecase_log "checksec kernel - $checksec_log"
	fi

	# Check checksec file
	if [[ ! -f ~/checksec.sh/checksec ]];then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "checksec Not Installed"
	fi

	if [[ -z $(sudo ~/checksec.sh/checksec --kernel | grep "Address space layout randomization:" | grep "Enabled" 2>/dev/null) ]];
	then
        	#echo "Address space layout randomization Disabled"
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "checksec - Kernel Address space layout randomization Disabled"
	fi

	# Check /dev/mem access #
	if [[ -z $(sudo ~/checksec.sh/checksec --kernel | grep "Restrict /dev/mem access:" | grep "Enabled" 2>/dev/null) ]];
	then
        	#echo "Restrict /dev/mem access Disabled"
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "checksec - Restrict /dev/mem access Disabled"
	fi

	# Check dmesg read kernel buffer Error for Not Root 
	if dmesg >>/dev/null 2>&1;
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#echo "dmesg read kernel buffer allowed!"
		usecase_log "dmesg read kernel buffer allowed!"
	fi

<<'COMMENT'
	# Check vmtools Daemon 
	if [ -n "$(sudo dmesg | grep 'vmtoolsd Not tainted')" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
       		#cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
		#echo "vmtoolsd Module Error"
		usecase_log "vmtoolsd Module Error"
		#sleep 2
		#exit
	fi
COMMENT

	# phoronix-test-suite system-info
	#wget http://phoronix-test-suite.com/releases/phoronix-test-suite-8.0.0.tar.gz
	#tar xvfz phoronix-test-suite-8.0.0.tar.gz
	#sudo apt install php-cli php-xml -y
	
	# Check phoronix-test-suite
	if [[ ! -f ~/phoronix-test-suite/phoronix-test-suite  ]];then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "phoronix-test-suite Not Installed :("
		exit
	fi
	
	#
	
	# No Colorful Output Issue by vmrun
	# On gnome-terminal of Ubuntu 18.04
	temp="$LS_COLORS"
	LS_COLORS=""
	~/phoronix-test-suite/phoronix-test-suite system-info > ~/after_system_info.txt
	LS_COLORS="$temp"
	comp_phoronix_info="$(diff ~/before_system_info.txt ~/after_system_info.txt | grep -v "Kernel:\|Microcode:")"
	if [ -n "$(echo "$comp_phoronix_info" | grep "> ")" ];then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		#phoronix_log_r="$(echo "$comp_phoronix_info" | grep "> " | awk '{print $2 $3}')"
        phoronix_log_r="$(echo "$comp_phoronix_info" | grep "> ")"
		#phoronix_log_l="$(echo "$comp_phoronix_info" | grep "< " | awk '{print $2 $3}')"
		phoronix_log_l="$(echo "$comp_phoronix_info" | grep "< ")"
		phoronix_log="Before: $phoronix_log_l After: $phoronix_log_r"
		usecase_log "phoronix-test-suite system-info - $phoronix_log"
	fi

	# Check mounted fs
	#mount | awk '{print $5}' | sort | uniq > ~/before_mount_fs.txt
	mount | awk '{print $5}' | sort | uniq > ~/after_mount_fs.txt
	comp_fs="$(diff -i ~/before_mount_fs.txt ~/after_mount_fs.txt | grep "< " | grep -v "binfmt_misc\|iso9660\|fusectl")"
	if [[ -n "$comp_fs" ]]; then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		comp_fs_log="$(echo $comp_fs | grep "< ")"
        	usecase_log "Mounted File System - $comp_fs_log"
	fi	

	# Check Pulse Audio System
	watch_dog_process pulseaudio &
	pulseaudio &> pulseaudio.log
	return_val=$(cat ~/wdp_ret.txt)
	if [ "$return_val" == "-1" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "Pulse Audio Hanging"
	fi

	if [ -n "$(grep 'Aborting' ./pulseaudio.log)" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
        	#cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
		#echo "Failed to Check Pulse Audio"
		usecase_log "Failed to Check Pulse Audio"
		#sleep 2
		#exit
	fi

	# Check sysctl variables
<<'COMMENT'
	sudo sysctl -a &> ~/after_sysctl.txt
	diff_sysctl_num=$(diff -i <(awk '{print $1}' ~/before_sysctl.txt | sort) <(awk '{print $1}' ~/after_sysctl.txt | sort) | grep -v "net." | grep "< " | uniq | wc -l)
	if [ "$diff_sysctl_num" -ge "1" ];
	then
		diff_sysctl_vars=$(diff -i <(awk '{print $1}' ~/before_sysctl.txt | sort) <(awk '{print $1}' ~/after_sysctl.txt | sort) | grep -v "net." | grep "< " | uniq)
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "$diff_sysctl_vars"
		
	fi
COMMENT

	#
	# Check Power State(Suspend, Hibernation...)
	#
	if [ "$(grep "suspend" /sys/power/disk 2>/dev/null | wc -l)" -eq "0" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "Power Management - Disk(Suspend)"
	fi

	if [ "$(grep "disk" /sys/power/state 2>/dev/null | wc -l)" -eq "0" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "Power Management - State(disk)"
	fi

<<'COMMENT'
	if [ "$(grep "test_resume" /sys/power/disk 2>/dev/null | wc -l)" -eq "0" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "Power State - Test Resume"
	fi
	
	if [ ! -f "/sys/power/pm_test" ];
	then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "Power State - pm_test file"
	fi
COMMENT

	# Check systemd units loaded 
<<'COMMENT'
	systemd-analyze blame &> ~/after_systemd-analyze.txt
	#diff_systemd_num=$(diff -i <(cat ~/before_systemd-analyze.txt | awk '{print $2}' | sort) <(cat ~/after_systemd-analyze.txt | awk '{print $2}' | sort) | grep "< " | wc -l)
	diff_systemd_num=$(diff -i <(cat ~/before_systemd-analyze.txt | awk '{print $2}' | sort) <(cat ~/after_systemd-analyze.txt | awk '{print $2}' | sort) | grep "< " | grep -v "NetworkManager-wait-online\|apt-daily\|phpsessionclean\|systemd-networkd\|packagekit" | wc -l)

	if [ "$diff_systemd_num" -ge "1" ];
	then
		diff_systemd_services=$(diff -i <(cat ~/before_systemd-analyze.txt | awk '{print $2}' | sort) <(cat ~/after_systemd-analyze.txt | awk '{print $2}' | sort) | grep "< " | grep -v "NetworkManager-wait-online\|apt-daily\|phpsessionclean\|systemd-networkd\|packagekit")
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "$diff_systemd_services"
		
	fi
COMMENT
	#
	# Check Jounalctl Log
	#
<<'COMMENT'
	jounalctl_log=$(sudo journalctl -p3 | grep "Failed to find module\|Failed to apply ACL on\|bad device \"/dev/ttyS0\" given" | awk '{$1=$2=$3=$4="";print $0;}' | sort)

	if [[ -n "$jounalctl_log" ]]; then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "journalctl log - $jounalctl_log"
	fi
COMMENT
	sudo journalctl -p3 -o verbose | grep "MESSAGE=" | awk -F'=' '{print $2}' | sed 's/\[[0-9]\+\]: //g' | sort -u &> ~/after_journalctl_log.txt
	#sudo journalctl -p3 | sed 's/^[A-Za-z]\+ [0-9]\+ [0-9]\+:[0-9]\+:[0-9]\+ [a-zA-Z]\+ [a-zA-Z0-9]\+\[[0-9]\+\]: //g' | sed 's/^[A-Za-z]\+ [0-9]\+ [0-9]\+:[0-9]\+:[0-9]\+ [a-zA-Z0-9]\+ //g' | sed 's/\[[0-9]\+\]//g' | sort -u | grep -v "^--" &> ~/after_journalctl_log.txt
	filter="\[alsa-sink-ES1371/1\] alsa-util.c:\|alsa-source-ES1371\|Assuming drive cache: write through\|bluez5-util.c: GetManagedObjects() failed:\|Failed to mount Mount unit for gnome\|GLib-GObject: g_object_ref: assertion\|chroot.c: open() failed: No such file or directory\|Detected Tx Unit Hang\|Reset adapter\|Failed to mount Mount unit for core"
	diff_journalctl_log=$(diff ~/before_journalctl_log.txt ~/after_journalctl_log.txt | grep "^> " | grep -v "$filter")
	if [ -n "$diff_journalctl_log" ];then
		echo "-1" > ~/$usecase_state_file      # Write Start State
		usecase_log "journalctl log - $diff_journalctl_log"
	fi

	# Application Program Execution
		
	#
	# Check Test Results
	#
	if [ "$(cat ~/$usecase_state_file 2>/dev/null)" == "-1" ];
	then
        	cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
		sleep 2
		exit
	fi

	echo "2.0" > ~/$usecase_state_file      # Write Start State

	# Write UseCase State
	#echo "2" > /tmp/$vm_b_state_file
	cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
	sleep 3

	# Install Xnee & Extract Event Files
	sudo apt-get install xnee -y
	tar xvfz $auto_event_file

	#
	# [Temp] As Every Test Passed For Test
	#
	echo "0" > /tmp/$vm_b_state_file
	#
	#
fi

usecase_state=$(cat ~/$usecase_state_file)

if [ "$usecase_state" == "2.0" ]
then
        # #-0 No Cnee Replay Test
        # GtkPerf
        sudo apt-get install gtkperf -y && /usr/bin/gtkperf -a
        echo "2.1" > ~/$usecase_state_file      # Write Next Usecase State
        cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
        sudo /etc/init.d/lightdm restart

elif [ "$usecase_state" == "2.1" ]
then
        # #-1 Default Test - Default Application, Control Panel, Etc...
        # Replay Default Event
        cnee --replay --no-synchronise --force-core-replay -f ./$default_event
        echo "2.2" > ~/$usecase_state_file      # Write Next Usecase State
        cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
        sudo /etc/init.d/lightdm restart

elif [ "$usecase_state" == "2.2" ]
then
        # Application Program Test
        cnee --replay --no-synchronise --force-core-replay -f ./$browser_event
        echo "2.3" > ~/$usecase_state_file      # Write Next Usecase State
        cp ~/"$usecase_state_file" /tmp/"$vm_b_state_file"
        sudo /etc/init.d/lightdm restart

<<'COMMENT'
# Waiting Browser Ends
while true
do
        browser_state=$(ps aux | grep "$browser_name" | wc -l)
        if [ "$browser_state" == "1" ]

                echo "Finish Browser Test..."
                break
        fi

done
COMMENT

elif [ "$usecase_state" == "2.3" ]
then
	# #-3 System Test by Benchmark Tools
	# Lmbench Install
	wget -O ~/lmbench-3.0-a9.tgz https://sourceforge.net/projects/lmbench/files/latest/download?source=files
	tar xvfz ~/lmbench-3.0-a9.tgz
	sudo apt install make -y
	sudo apt install gcc -y
	cd ~/lmbench-3.0-a9/
	
	#watch_dog_lmbench &
	# Execute lmbench
	#echo -e "\n\n\n\n" | make results
<<'COMMENT'
	for i in $(seq 7);
	do
		make rerun
	done
COMMENT
	#make rerun && make rerun && make rerun && make rerun && make rerun && make rerun && make rerun && make rerun && make rerun
	#make see
#cd ~/
        # Replay Benchmark Event
        #cnee --replay --no-synchronise --force-core-replay -f ./$benchmark_event

<<'COMMENT'
        # Waiting Lmbench Ends
        while true
        do
                lmbench_state=$(ps aux | grep "make results" | wc -l)
                if [ "$lmbench_state" == "1" ]
                then
                        echo "Finish Lmbench Test..."
                        break
                fi
                sleep 10
        done
COMMENT

<<'COMMENT'
        # #-4 Sysbench Install
        sudo apt-get install sysbench -y
        # CPU Test
        sysbench --test=cpu --cpu-max-prime=20000 run

        # Memory Read Test
        sysbench --test=memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=read run

        # Memory Write Test
        sysbench --test=memory --memory-block-size=1K --memory-scope=global --memory-total-size=100G --memory-oper=write run

        # Disk Test
        sysbench --test=fileio --file-total-size=8G prepare
        sysbench --test=fileio --file-total-size=8G --file-test-mode=rndrw --init-rng=on --max-time=300 --max-requests=0 run
        sysbench --test=fileio --file-total-size=8G cleanup
COMMENT

        echo "2.9" > ~/$usecase_state_file      # Write Next Usecase State
        sudo /etc/init.d/lightdm restart

fi

# Finish Testing Use-Case
echo "0" > /tmp/$vm_b_state_file
