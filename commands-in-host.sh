#!/bin/bash


#set -x

######################################
#
# Select Guest OS of Virtual Machine
#
######################################
gooroom=0
debian=1
ubuntu=2
#
target_os=$gooroom # Gooroom
#
#target_os=$debian # Debian
#
#target_os=$ubuntu # Ubuntu

target_os_name[0]="gooroom"                                                                                                                                           
target_os_name[1]="debian"
target_os_name[2]="ubuntu"

#
# Login Account of Guest OS on Virtual Machine
#
#guser="ultract2"
guser=""
#gpw="ultract2"
gpw=""

#
# VMware's VMX File Path
#
# Trace VM & Test VM For a Verification
# VM-A Group : Trace Kernel Features
# VM-B Group : Verify Tailored Kernels
#
case "${target_os}" in
	0)
	  #
	  # Gooroom
	  #vmx_guest_a="/home/ultract/vmware/Tester_1/Tester_1.vmx"
	  vmx_guest_a=""
	  #vmx_guest_b_1="/home/ultract/vmware/Tester_1/Tester_1.vmx"
	  ;;
	
	1)
	  #
	  # Debian
	  #vmx_guest_a="/home/ultract/vmware/Debian_Tester_1/Debian_Tester_1.vmx"
	  vmx_guest_a=""
	  #vmx_guest_b_1="/home/ultract/vmware/Tester_1/Tester_1.vmx"
	  ;;

	2)
	  #
	  # Ubuntu
	  #vmx_guest_a="/home/ultract/vmware/Ubuntu_Tester_1_18.04/Ubuntu_Tester_1.vmx"
	  vmx_guest_a=""
	  #vmx_guest_b_1="/home/ultract/vmware/Tester_1/Tester_1.vmx"
	  ;;

esac

#vmx_guest_a="/home/ultract/vmware/Test-Debian 8.x 64-bit/Test-Debian 8.x 64-bit.vmx"
#vmx_guest_a="$1"
#vmx_guest_a="/home/ultract/vmware/Tester_1/Tester_1.vmx"
#vmx_guest_a="/home/ultract/vmware/Debian_Tester_1/Debian_Tester_1.vmx"
#vmx_guest_a="/home/ultract/vmware/Ubuntu_Tester_1_18.04/Ubuntu_Tester_1.vmx"
# Test VM
#vmx_guest_b="$3"
#vmx_guest_b="/home/ultract/vmware/"
#vmx_guest_b_1="/home/ultract/vmware/Tester_1/Tester_1.vmx"

#
# Snapshot Name of VM
#
# Trace VM
#snapshot_vm_a="Snapshot 1"
snapshot_vm_a=""
# Verification VM
#snapshot_vm_b="Snapshot 1"
snapshot_vm_b=""

#
# Email Address
# To Get Results about Kerel Tailoring
email_addr="your@email.com"

#
# Automated Command Scripts for VM
#
# Trace VM
script_in_guest_a="commands-in-guest-A.sh"
# Test VM
script_in_guest_b="commands-in-guest-B.sh"

#
# Etc Scripts & Files
#
# Script Name of Use Case in VM
vm_usecase_script="use-case.sh"
# Use Case Script for Trace VM
usecase_script_a="use-case-a.sh"
# Use Case Script for Test VM
usecase_script_b="use-case-b.sh"
# Auto Start Shortcut
autostart_file="Use-Case-Script.desktop"
# Use Case Files of Cnee
auto_event_file="cnee_events.tar.gz"
# Kernel Tailoring Script for Trace VM
tailor_script="kernel-tailoring.sh"
# Undertaker Whitelist File
undertaker_whitelist="whitelist.x86_64"
# Undertaker Ignore File
undertaker_ignore="undertaker.ignore"

#
# Files Saving VM State
#
# Trace VM
vm_a_state_file="VM-A-State.dat"	# -1: Tailoring Fail, 0: Tailoring Success
# Test VM
vm_b_state_file="VM-B-State.dat"	#  1: Undertaker Install & Packages About Kernel Install
					#  2: Perform Use-Case, 2.1:..., 2.2:..., 2.3:..., ...
# Log File of Test VM			#  3: Kernel Tailoring by Undertaker
vm_b_state_log="usecase-log.dat"

# File Saving All Test Log of Test VM
faillog_file="/tmp/faillog.txt"

# Save Kernel Build Failure Config
kern_build_failure="/tmp/kernel_build_error.txt"


#guest_kernel_ver="guest_kernel_ver.dat"
# Compressed Kernel File Name(*.tar.gz)
guest_kernel_src="guest_kernel_src.dat"
# Original Kernel Configuration(config-XXX)
org_kern_conf="org_kern_conf.dat"

#
# Mounted Path of Ram Disk
ram_disk_dir="/mnt/RAM_disk/"
#ram_disk_dir="/home/ultract/RAM_disk/"

#
# lsmod Result File
lsmod_file="lsmod_result.txt"
# localmodconfig Result File
localmodconfig_result="lmconfig_result.txt"
#not_have_config="not_have_config.txt"

#
# Kernel Configuration File
config_file=".config"
# Kernel Configuration File via Localmodconfig
other_config_file="original_localmodconfig"
# First Tailored Configuration File
first_tailored_config="tailored_config"

#
# Black List of Kernel Configuration
blacklist="^CHROME\|MACINTOSH"
#blacklist="^KVM\|^XEN\|^CHROME\|^APPARMOR\|^TOMOYO\|^SMACK\|^DEBUG\|^TEST\|^TRACE\|^DUMP\|^MACINTOSH"

#
# Tailored(Useless) Configurations or Groups
useless_config_group=""


#
# MTRR, NUMA -> Performance Issue, NET_FS -> DBench Tool
#

#
# For Performance
whitelist=""
whitelist="^MTRR\|^NUMA\|^NUMA_BALANCING\|^NET_NS\|^SCHED_AUTOGROUP\|^NET_SCHED\|^BLK_DEV\|^SCHED_SMT\|^SCHED_MC\|^SCHED_HRTICK\|^HUGETLB_PAGE\|^HUGETLBFS\|^CGROUP_HUGETLB\|^SYSVIPC\|^SYSVIPC_SYSCTL\|^SYSVIPC_COMPAT\|^COMPAT_BINFMT_ELF"
whitelist=$whitelist"\|^DETECT_HUNG_TASK\|^SCHED_DEBUG\|^NUMA_BALANCING\|^SCHED_AUTOGROUP\|^BPF_SYSCALL"
whitelist=$whitelist"\|^LOCKUP_DETECTOR\|^IA32_EMULATION\|^USER_NS\|^CHECKPOINT_RESTORE\|^PERSISTENT_KEYRINGS"
whitelist=$whitelist"\|^MEMORY_FAILURE\|^MAGIC_SYSRQ\|^CFS_BANDWIDTH\|^NET_NS\|^POSIX_MQUEUE"
whitelist=$whitelist"\|^X86_MCE\|^EFIVAR_FS\|^STACK_TRACER\|^PID_NS\|^KPROBES"
whitelist=$whitelist"\|^COMPACTION\|^KEXEC\|^COREDUMP\|^DNOTIFY\|^SYSVIPC\|^DMADEVICES"

#
# From faillog.txt - Not Booting up
#whitelist=$whitelist"\|^VT_CONSOLE\|^RD_GZIP\|^FILE_LOCKING\|^UNIX98_PTYS\|^BINFMT_SCRIPT\|^BINFMT_ELF"
#whitelist=$whitelist"\|^INOTIFY_USER\|^TIMERFD\|^MULTIUSER\|^SHMEM\|^VT\|^TTY\|^UNIX\|^DEVTMPFS"
#whitelist=$whitelist"\|^DEVTMPFS\|^SYSFS\|^FUTEX\|^TMPFS\|^EPOLL\|^SIGNALFD"

# From faillog.txt - Failed Use Case
#whitelist=$whitelist"\|^PAGE_TABLE_ISOLATION\|^RETPOLINE\|^RELOCATABLE\|^SECURITY_DMESG_RESTRICT\|^ADVISE_SYSCALLS"
#whitelist=$whitelist"\|^ADVISE_SYSCALLS\|^RANDOMIZE_BASE\|^STRICT_DEVMEM"
#whitelist=$whitelist"\|^HID_GENERIC\|^INPUT_KEYBOARD\|^KEYBOARD_ATKBD\|^INPUT_MOUSE\|^MOUSE_PS2"
#whitelist=$whitelist"\|^PM_DEBUG\|^SUSPEND\|^HIBERNATION\|^SWAP\|^IOSCHED_CFQ"
#whitelist=$whitelist"\|^DMIID\|^DMI\|^MEMCG\|^PACKET\|^IPV6\|^NAMESPACES\|^MODULE_UNLOAD"

#
# Tailored Configurations or Groups File
useless_config_group_file="/tmp/useless_config_group.dat"
# Essential Configuration or Grouls File
essential_config_list_file="/tmp/essential_config_list.dat"
# Not Tailored Configurations File(Because of Kconfig Dependency)
survive_config_list_file="/tmp/survive_config_list.dat"
# Testing Configurations or Group List File
test_config_group_list="test_config_group.txt"

#
# Test Virtual Machone State File
test_vm_state_file="/tmp/test_vm_state.dat"
# Number of Test VM
test_vm_num="$1"	

# Final Testing Step of Tailored Kernel
final_test_id="FINAL_TEST"

#
# Printing Color on Display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'

NC='\033[0m' # No Color
#printf "I ${RED}love${NC} Stack Overflow\n"
#echo -e "I ${RED}love${NC} Stack Overflow"

#
# Kernel Tailoring Log File
log_file="kernel_tailoring.log"
# Previous Kernel Configuration File
previous_config="previous_config"

#
# Analyze Kernel Configuration Where is included in Directories e.g. arch, driver, block...
#
analyze_config_dir(){
	# Target Kernel Configuration File
	local config_file="$1"
	local undertaker_models_file="$(find "$ram_disk_dir" -maxdepth 1 -type d -name "linux*" 2>/dev/null)/models/x86.rsf"
	# Count Each CONFIG_XX_XX Where is in Directories(arch, net, driver...)
	grep "^CONFIG_" "$config_file" | awk -F'=' '{print $1}' | sed 's/^CONFIG_//g' | while read line; 
	do 
			grep "^Definition"$'\t'"$line"$'\t' "$undertaker_models_file" | awk '{print $3}' | sed 's/"//g' | awk -F"/" '{print $1}'
	done | sort | uniq -c
}

#
# Watch Dog for vmrun command
# Not Using Now
watch_dog_vmrun(){
	local duration=$SECONDS
	local timetolive="120" # Sec
        while true; do
                sleep 5
                ps -eo pid,comm,lstart,etime | grep "vmrun" | while read line;
                do
                        local pid=$(echo "$line" | awk '{print $1}')
                        local etime=$(echo "$line" | awk '{print $8}' | awk -F: '{print ($1 * 60) + $2}')
			
			# Timeout 2 Minutes
                        if [ "$etime" -gt "120" ]
                        then
                                kill -9 "$pid" 2>/dev/null
                        fi
                done
		timeout=$((SECONDS-duration))
		if [ "$timeout" -gt "$timetolive" ]
		then
			return
		fi
        done
}


#
# Lock Function Such as Mutex
#
create_lock_or_wait () {
        local path="$1"
        #wait_time="${2:-10}"
        local wait_time="3"
        while true; do
		if mkdir "${path}.lock.d" 2>/dev/null; then
			break;
		fi
	        sleep $wait_time
        done
}

#
# Unlock Function Such as Mutex
#
remove_lock () {
        path="$1"
        rmdir "${path}.lock.d"
}


#
# Sending Email about Tailoring Results of
# - Change This Part to Your Email Address
send_email()
{
        # Write Contents
        contents="To: $email_addr\r\n"
        contents="${contents}From: $email_addr\r\n"
        contents="${contents}Subject: Kernel Tailoring Message\r\n\r\n"
        contents="${contents}$1\r\n"

        # Send Contents
        echo -e "$contents" | ssmtp "$email_addr"
}


#
# Print Simple Analysis of Kernel Configuration for Sending a Mail
# Usage : analysis_config .config
#
analysis_config()
{
	local config_file="$1"
	local config_result="[ Analysis of Kernel Configuration file ] \r\n"
	local config_result="$config_result Groups : $(grep "# " ".config" | grep -v "# CONFIG_\|# Automatically generated file" | wc -l)\r\n"
	local config_result="$config_result Enable : $(grep "^CONFIG_" "$config_file" | grep '=y' "$config_file" | wc -l)\r\n"
	local config_result="$config_result Module : $(grep "^CONFIG_" "$config_file" | grep '=m' "$config_file" | wc -l)\r\n"
	local config_result="$config_result Disable : $(grep 'not set' "$config_file" | wc -l)\r\n"
	local config_result="$config_result Etc(Str, Num) : $(grep "^CONFIG_" "$config_file" | grep -v "=y\|=m" | wc -l)\r\n"
	echo "$config_result"
}


#
# Kernel Configuration Analyzer
# Usage : analysis_config_log ConfigFileName LogMessage
#
analysis_config_log()
{
	local config_file="$1"
	local logmsg="$2"
	local test_config="$3"

	# Current Configuration File
	echo -e "$logmsg" >> ./"$log_file"
	echo "[ Current .config file ] " >> ./"$log_file"
	echo -n "Groups : " >> ./"$log_file"
	grep -v "^# CONFIG" "$config_file" | grep "# " | sort | wc -l >> ./"$log_file"
	
	echo -n "Enable : " >> ./"$log_file"
	grep -v "^# CONFIG" "$config_file" | grep '=y' "$config_file" | sort | wc -l >> ./"$log_file"

	echo -n "Module : " >> ./"$log_file"
	grep -v "^# CONFIG" "$config_file" | grep '=m' "$config_file" | sort | wc -l >> ./"$log_file"

	echo -n "Disable : " >> ./"$log_file"
	grep 'not set' "$config_file" | sort | wc -l >> ./"$log_file"

	echo -n "Etc(Str, Num) : " >> ./"$log_file"
	grep -v "^# CONFIG" "$config_file" | cut -d'=' -f2 | grep '^"\|0x[0-9a-e]*\|^[0-9]\+' | wc -l >> ./"$log_file"

	# Original Configuration File via Localmodconfig
	echo -e "\n" >> ./"$log_file"
	echo "[ Compare Original_localmodconfig ]" >> ./"$log_file"
	echo -n "> Only Enabled($other_config_file) : " >> ./"$log_file"
	diff -i <(sort "$config_file" | grep '=y\|=^"\|=[0x]*[0-9a-e]*\|^[0-9]\+') <(sort "$other_config_file" | grep '=y\|=^"\|=[0x]*[0-9a-e]*\|^[0-9]\+') | grep '> CONFIG_' | wc -l >> ./"$log_file"
	echo -n "> Only Enabled($config_file) : " >> ./"$log_file"
	diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '< CONFIG_' | wc -l >> ./"$log_file"
	echo -n "> Modules($other_config_file) : " >> ./"$log_file"
	diff -i <(sort "$config_file" | grep '=m') <(sort "$other_config_file" | grep '=m') | grep '> CONFIG_' | wc -l >> ./"$log_file"
	echo -n "> Modules($config_file) : " >> ./"$log_file"
	diff -i <(sort "$config_file" | grep '=m') <(sort "$other_config_file" | grep '=m') | grep '< CONFIG_' | wc -l >> ./"$log_file"
	echo -n "> Disabled($other_config_file) : " >> ./"$log_file"
	diff -i <(sort "$config_file" | grep 'not set') <(sort $other_config_file | grep 'not set') | grep '> ' | wc -l >> ./"$log_file"
	echo -n "> Disabled($config_file) : " >> ./"$log_file"
	diff -i <(sort "$config_file" | grep 'not set') <(sort "$other_config_file" | grep 'not set') | grep '< ' | wc -l >> ./"$log_file"

<<'COMMENT'
	if [ -f "$previous_config" ]
	then
		echo -e "\n" >> ./"$log_file"
		echo "[ Config Change Log ]----------------------------" >> ./"$log_file"
		echo "[*] Only Enabled in .config" >> ./"$log_file"
		diff -i <(sort "$config_file") <(sort "$previous_config") | grep '< CONFIG_' | sed 's/< CONFIG_/  /g' >> ./"$log_file"
		echo "-------------------------------------------------" >> ./"$log_file"
		echo "[*] Only Enabled in Previous .config" >> ./"$log_file"
		diff -i <(sort "$config_file") <(sort "$previous_config") | grep '> CONFIG_' | sed 's/> CONFIG_/  /g' >> ./"$log_file"
		echo "-------------------------------------------------" >> ./"$log_file"
	fi
	echo "=========================================================" >> ./"$log_file"
	echo -e "\n" >> ./"$log_file"
COMMENT
	echo -e "\n" >> ./"$log_file"

	# Check Testing Configuration in Configuration File whether it was removed
	if [ -n "$test_config" ]
	then
		echo "[ Check Test Config in .config ]----------------- " >> ./"$log_file"
		local temp=$(grep "^CONFIG_$test_config=" "$config_file")
		if [ -z "$temp" ]
		then
			echo "Test Config Removed!" >> ./"$log_file"
			retvalue=0
		else
			echo "Test Config Not Removed!" >> ./"$log_file"
			create_lock_or_wait "/tmp/unremoved_config"
			echo "$test_config" >> "$survive_config_list_file"
			remove_lock "/tmp/unremoved_config"
			retvalue=2
		fi
	fi
	
	echo -e "\n" >> ./"$log_file"
	echo "[ Config Change Log ]----------------------------" >> ./"$log_file"
	echo "[*] Only in Original_localmodconfig" >> ./"$log_file"
	diff -i <(sort "$config_file") <(sort "$other_config_file") | grep '> CONFIG_' | sed 's/> CONFIG_/  /g' >> ./"$log_file"
	echo "-------------------------------------------------" >> ./"$log_file"
	echo "=========================================================" >> ./"$log_file"
	echo -e "\n" >> ./"$log_file"

	return $retvalue
}

#
#
# Testing Each Configuration for Kernel Tailoring Whether It is essential
# 
# test_config [Name of Kernel Src Directory] [VMX File Path] [Configuration String]
# e.g. test_config Tester_1 /home/ultract/vmware/Tester_1/Tester_1.vmx HAS_FB
#
test_config_func()
{
	# Current Virtual Machine Name 
	local vm_name="$1"
	
	# Move to Kernel Source Directory in Ram Disk
	local kernel_src="$1"
	#cd "$ram_disk_dir/$kernel_src/"linux-*
	# Change Directory Not File 
	cd "$ram_disk_dir/$kernel_src/"
	cd "$(ls -d */)"

	# VMX File Path of Current VM
	local vmx_file="$2"
	
	# Copy String of Test Configuration(Useful or Useless??)
	local test_config="$3"

	# Save Previous .config
	cp "./$config_file" "./$previous_config"

<<'COMMENT'
	# Change .config to Tailored Configuration File(Minimum Kernel Configuration Set)
	cp ./"$first_tailored_config" "./$config_file"

	# Get a Name of Original Configuration File
	echo -e "\t\t${YELLOW}B-"$vm_name"${NC}-Adjust Localmodconfig..."
	local org_kern_conf_file=$(ls -l | awk '{print $9}' | grep '^config-[0-9]\.[0-9]\.[0-9]')

#<<'COMMENT'
	# Adjust Tailored .config by Results(Dependencies) of Localmodconfig
	# Set Config of Dependencies by Warning & Error Messages From Tailored Localmodconfig
	sed 's/\<module [a-zA-Z0-9_]* did not have configs\>//g' ./"$localmodconfig_result" | sed 's/\ /\n/g' | sort -u | grep "^CONFIG_" | sed 's/CONFIG_//g' | while read line;
	do
		local temp=$(grep "$line" "$org_kern_conf_file")
		if echo "$temp" | grep -q '=y';
		then
			#echo "./scripts/config --enable "$line""
			./scripts/config --enable "$line"
		elif echo "$temp" | grep -q '=m';
		then
			#echo "./scripts/config --module "$line""
			./scripts/config --module "$line"
		#else
			#echo "./scripts/config --disable "$line""
			#./scripts/config --disable "$line"
		fi
	done
	
	# Enable Dependency Configuration of Modules
	grep -o "dependencies ([A-Z\_\& ]*)" ./"$localmodconfig_result" | sed 's/dependencies (//g' | sed 's/)//g' | sed 's/\&\&//g' | while read dep_conf; 
	do
		for item in $dep_conf
		do
			#echo "./scripts/config --enable "$item""
			./scripts/config --enable "$item"
		done
	done
#COMMENT

	# Disable Configs Not in Original Localmodconfig
	diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '< CONFIG_' | awk '{print $2}' | sed 's/=y//g' | sed 's/CONFIG_//g' | while read line; 
	do
		#echo "./scripts/config --disable "$line""
		./scripts/config --disable "$line"
	done

	# Disable Modules Configs Not in Original Localmodconfig
	diff -i <(sort "$config_file" | grep '=m') <(sort "$other_config_file" | grep '=m') | grep '< CONFIG_' | awk '{print $2}' | sed 's/=m//g' | sed 's/CONFIG_//g' | while read line; 
	do
		#echo "./scripts/config --disable "$line""
		./scripts/config --disable "$line"
	done

	# Disable Configurations which are Disabled in Original Localmodconfig
	diff -i <(sort "$config_file" | grep 'not set') <(sort "$other_config_file" | grep 'not set') | grep '> # CONFIG_' | awk '{print $3}' | sed 's/is not set//g' | sed 's/CONFIG_//g'  | while read line; 
	do
		#echo "./scripts/config --disable "$line""
		./scripts/config --disable "$line"
	done
COMMENT

	#
	# Read Tailored Configurations until now from the File
	#
	create_lock_or_wait "/tmp/keywords"
	local useless_config_group=$(cat "$useless_config_group_file")
	remove_lock "/tmp/keywords"

	if [ ${#useless_config_group} -eq 0 ];
	then
		useless_config_group="$test_config"
	elif [ "$test_config" != "$final_test_id" ]
	then
		useless_config_group="$useless_config_group\|$test_config"
	fi

	# Supply Dependencies Configs
	#make -s olddefconfig

	# Adjusting Kernel .config in Another Config File by Keyword (like SCSI, USB...)
	#echo -e "\t\t${YELLOW}B-"$vm_name"${NC}-Testing ${BLUE}[$test_config]${NC} Config..."

<<'COMMENT'
#	tmp_baseconfig=$(diff -i <(sort "$config_file") <(sort "$other_config_file") | grep '> CONFIG_' | sed 's/> CONFIG_//g' | sort | grep -v "$useless_config_group")
#<<'COMMENT'
	diff -i <(sort "$config_file") <(sort "$other_config_file") | grep '> CONFIG_' | sed 's/> CONFIG_//g' | sort | grep -v "$useless_config_group" | while read line;
	do
		local temp=$(echo "$line" | cut -d'=' -f1)
		local option=$(echo "$line" | cut -d'=' -f2)
		if echo "$option" | grep -q 'y';
		then
			#echo -e "./scripts/config --enable "$temp""
			./scripts/config --enable "$temp"

		elif echo "$option" | grep -q 'm';
		then
			#echo -e "./scripts/config --module "$temp""
			./scripts/config --module "$temp"
#<<'COMMENT'
		# Set String Option
		elif echo "$option" | grep -q '^"';
		then
			#echo -e "./scripts/config --set-str "$temp" "$option""
			./scripts/config --set-str "$temp" $(echo "$option" | sed 's/"//g')

		# Set Value Option
		elif echo "$option" | grep -q '0x[0-9a-e]*\|^[0-9]\+';
		then
			#echo -e "./scripts/config --set-var "$temp" "$option""
			./scripts/config --set-val "$temp" "$option"
#COMMENT
		fi
	done
COMMENT
	
	# Revert .config to Original Localmodconfig
	cp "$other_config_file" "$config_file"

	#
	# Check Test Configuration Whether Exist in .config
	local temp=$(grep "$test_config=" "$config_file")
	if [ -z "$temp" ] && [ "$test_config" != "$final_test_id" ]
	then
		create_lock_or_wait "/tmp/test_vm_state"
		sed -i "s/$vm_name:1/$vm_name:0/g" "$test_vm_state_file"
		echo "$test_config" >> /tmp/already_removed_config.txt
		remove_lock "/tmp/test_vm_state"
		echo -e "\t\t$test_config test Config is Already Removed!..."
		return	# Return Config Testing
	fi

	#
	# Disable Useless(Tailored) Configurations in Localmodconfig
	#
	echo "$useless_config_group" | sed 's/\\|/\n/g' | sed 's/\^//g' | while read line;
	do
		./scripts/config --disable "$line"
	done

	#
	# Disable Configuration in Blacklist
	#
	sort "$config_file" | cut -d'=' -f1 | sed 's/CONFIG_//g' | while read line; 
	#sort "$config_file" | grep '=y' | sed 's/=y//g' | sed 's/CONFIG_//g' | while read line; 
	do
		if echo "$line" | grep -q "$blacklist";
		then
			#echo "./scripts/config --disable "$line""
			./scripts/config --disable "$line"
		fi
	done

	# Analyze .config
<<'COMMENT'
	echo -e " ${YELLOW}B-"$vm_name"${NC}-Analyze .config..."
	echo -n "> Enabled Config in $other_config_file : "
	diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '> CONFIG_' | wc -l
	echo -n "> Enabled Config in $config_file : "
	diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '< CONFIG_' | wc -l
	echo -n "> Modules in $other_config_file : "
	diff -i <(sort "$config_file" | grep '=m') <(sort "$other_config_file" | grep '=m') | grep '> CONFIG_' | wc -l
	echo -n "> Modules in $config_file : "
	diff -i <(sort "$config_file" | grep '=m') <(sort "$other_config_file" | grep '=m') | grep '< CONFIG_' | wc -l
	echo -n "> Disabled in $other_config_file : "
	diff -i <(sort "$config_file" | grep 'not set') <(sort $other_config_file | grep 'not set') | grep '> ' | wc -l
	echo -n "> Disabled in $config_file : "
	diff -i <(sort "$config_file" | grep 'not set') <(sort "$other_config_file" | grep 'not set') | grep '< ' | wc -l
COMMENT

	#
	# Build Tailored Test Kernel Image
	#
	echo -e "\t\t${YELLOW}"B-$vm_name"${NC}-Build Test Kernel Image..."
	# Cleaning Files about Kernel
	make -s clean
	cd ../
	rm -rf *.tar.gz *.deb *.dsc *.changes *.dat
	cd ./linux-*
	
	#
	# Don't Make Kernel Debug Symbol File
	#
	./scripts/config --disable DEBUG_INFO

	###############################################
	#
	# Additional Configurations For Ubuntu 18.04
	#
	###############################################
	# dmesg read kernel buffer allowed!
	./scripts/config --enable SECURITY_DMESG_RESTRICT
	
	#
	# Select Kernel Make Option
	# make -s oldconfig
	make -s olddefconfig	# Same as silentoldconfig 
							# but set new symbols to their default value
	#make -s oldnoconfig
	#make -s allyesconfig
	#make -s allnoconfig

	#
	# Save Current .config File
	config_dir="./config_files"
	if [ ! -d "$config_dir" ];
	then
		mkdir "$config_dir"
	fi
	cp .config "$config_dir/$test_config.config"
	
	#
	# Analyze .config and Original Localmodconfig File
	# - Exit or Return If Test Configuration Wasn't Removed
	
	create_lock_or_wait "/tmp/whitelist"
	local whitelist=$(cat "$essential_config_list_file")
	remove_lock "/tmp/whitelist"

	local num_remove_conf=$(echo "$useless_config_group" | sed s/\|/\\n/g | wc -l)
	local num_whitelist=$(echo "$whitelist" | sed s/\|/\\n/g | wc -l)

	analysis_config_log "$config_file" "[Test Config: $test_config]\n[$num_remove_conf][$useless_config_group]\n[$num_whitelist][$whitelist]" "$test_config"
	local retv=$?
	if (( $retv == 2 ))
	then
		# Change VM to Idle State
		create_lock_or_wait "/tmp/test_vm_state"
		sed -i "s/$vm_name:1/$vm_name:0/g" "$test_vm_state_file"
		remove_lock "/tmp/test_vm_state"
		echo -e "\t\t${BLUE}[$test_config]${NC} Config Not Removed!..."
		return	# Exit Test for Kernel Tailoring
	fi

	#
	# Build Linux Kernel Image 
	# Choose Threads Option for Building
	#make -s deb-pkg -j112
	#make -s deb-pkg -j56
	make -s deb-pkg -j28 &>> ./kernel_build_log.txt

	#
	# Check Kernel Package File Exist
	#
	if [ "$(find ../ -maxdepth 1 -type f -name linux-image-*.deb 2>/dev/null | wc -l)" == "0" ];
	then
		#
		# Add This Config in The Essential Configuration List
		#
		create_lock_or_wait "/tmp/whitelist"
		local whitelist=$(cat "$essential_config_list_file")
		if [ ${#whitelist} -eq 0 ];
		then
			whitelist="^$test_config"
			echo "$whitelist" > "$essential_config_list_file"

		else
			whitelist="$whitelist\|^$test_config"
			echo "$whitelist" > "$essential_config_list_file"

		fi
		remove_lock "/tmp/whitelist"
		
		# Change Test VM State to Idle
		create_lock_or_wait "/tmp/test_vm_state"
		sed -i "s/$vm_name:1/$vm_name:0/g" "$test_vm_state_file"
		echo "$test_config" >> "$kern_build_failure"
		remove_lock "/tmp/test_vm_state"
		echo -e "\t\t$test_config Kernel Build Error!..."

		return	# Return Config Testing
	fi
	
	#
	# Revert Virtual Machine for Test
	# Using Lock For VM Revert Fail or Bottleneck(Delay) Issue
	#
	create_lock_or_wait "/tmp/vm_revert"
	while true; do
		echo -e "\t\tRevert to the Snapshot of ${YELLOW}B-"$vm_name"${NC}-Guest Machine..."
		vmrun -T ws revertToSnapshot "$vmx_file" "$snapshot_vm_b" &> ./"vm_revert_error.log"
		vmrun -T ws start "$vmx_file" &> ./"vm_start_error.log"

		# Check VM Revert & Start Error
		if [ "$(grep "Error:" ./vm_revert_error.log | awk '{print $1}')" != "Error:" ] && [ "$(grep "Error:" ./vm_start_error.log | awk '{print $1}')" != "Error:" ]
		then
			sleep 3
			break
		fi
		sleep 2
	done
	remove_lock "/tmp/vm_revert"


	#
	# Copy Tailored Kernel Image Package, Usecase File, Autostart File to B-Guest Machine
	#
	echo -e "\t\tCopy Tailored Kernel Package to ${YELLOW}B-"$vm_name"${NC}-Guest Machine..."
	kernel_image_deb=$(ls $ram_disk_dir/$kernel_src | grep -E '^linux-image-.*deb$' | grep -v 'dbg')
	# Kernel Image
	vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_file" $ram_disk_dir/$kernel_src/$kernel_image_deb "/home/$guser/$kernel_image_deb"
	
	case "${target_os}" in
	  0)
	  	#
	  	# Gooroom
		script_path="gooroom-tailor"
		terminal_name="/usr/bin/xfce4-terminal"
		terminal_option="-x"
		;;
	
	  1)
	  	#
		# Debian
		script_path="debian-tailor"
		terminal_name="/usr/bin/gnome-terminal"
		terminal_option="--"
		;;

	  2)
	  	#
	  	# Ubuntu
		script_path="ubuntu-tailor"
		terminal_name="/usr/bin/gnome-terminal"
		terminal_option="--"
	  	;;

	esac

	# Execute the Testing Script File in B-Guest Machine
	echo -e "\t\tExecuting the Script File into ${YELLOW}B-"$vm_name"${NC}-Guest Machine..."

	# Default Script
	vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_file" ~/auto-kernel-tailoring/${script_path}/${script_in_guest_b} /home/$guser/"$script_in_guest_b"

	# Usecase Script
	vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_file" ~/auto-kernel-tailoring/${script_path}/${usecase_script_b} /home/$guser/"$vm_usecase_script"

	# Copy Auto Event File of Cnee for Use-Case
	vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_file" ~/auto-kernel-tailoring/${script_path}/${auto_event_file} /home/$guser/"$auto_event_file"

	# Copy Autostart File to Execute Use-Case into B-Guest Machine
	vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_file" ~/auto-kernel-tailoring/${script_path}/${autostart_file} /home/$guser/"$autostart_file"

	# Execute Sctipt by Terminal
	vmrun -T ws -gu "$guser" -gp "$gpw" runProgramInGuest "$vmx_file" -noWait "/usr/bin/env" "DISPLAY=:0" "$terminal_name" "$terminal_option" "/home/$guser/$script_in_guest_b"


	#
	# Record Current Time
	# SECONDS=0
	duration=$SECONDS
	#echo "$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed..."

	#
	# Check State of Tailored Kernel in Testing-VM(B-Guest Machine)
	#
	#watch_dog_vmrun &	# Run Watchdog for vmrun
	while true;
	do
		echo -e "\t\t\tWait VM-${YELLOW}B-"$vm_name"${NC}-Test Finish..."
		#watch_dog_vmrun &	# Run Watchdog for vmrun
		
		#
		# Get State File of Testing VM
		local exit_code="$(vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_file" "/tmp/$vm_b_state_file" "$ram_disk_dir/$kernel_src/")"
		#vm_state=$(cat $ram_disk_dir/$vm_b_state_file 2>/dev/null)
		vm_state="$(cat $ram_disk_dir/$kernel_src/$vm_b_state_file 2>/dev/null)"

		#watch_dog_vmrun &	# Run Watchdog for vmrun
		#local exit_log=$(vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_file" "/tmp/$vm_b_state_log" "$ram_disk_dir/$kernel_src/")
		#vm_state_log=$(cat $ram_disk_dir/$kernel_src/$vm_b_state_log 2>/dev/null)

		# Calculate Elaped Time
		time_limit=$((SECONDS-duration))	# Get Time Duration
		#echo "$time_limit"
		
		#
		# Succeed Usecase Test
		if [ -z "$exit_code" ] && [ "$vm_state" == "0" ]
		then
			rm -rf /$ram_disk_dir/$kernel_src/$vm_b_state_file
			echo -e "\t\t\t${YELLOW}VM-B-"$vm_name"-All Tests Passed! :)${NC}"
		
			#
			# Add This Config in a List of Useless Configs
			create_lock_or_wait "/tmp/keywords"
			local useless_config_group=$(cat "$useless_config_group_file")
			if [ ${#useless_config_group} -eq 0 ];
			then
				useless_config_group="^$test_config"
				echo "$useless_config_group" > $useless_config_group_file

			else
				useless_config_group="$useless_config_group\|^$test_config"
				echo "$useless_config_group" > $useless_config_group_file

			fi
			remove_lock "/tmp/keywords"

			#
			# Change Test VM State to Idle
			echo -e "\t\t\t[#]VM-${YELLOW}B-"$vm_name"${NC}-State Changing To Idle..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i "s/$vm_name:1/$vm_name:0/g" "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"

			break

		# Failed Usecase Test
		#elif [ "$time_limit" -gt 600 ] && [ -z "$vm_state" ]
		# Failed
		#elif [ "$time_limit" -gt 80 ]
		# Waiting 12 Minutes or Checking VM State
		elif [ "$time_limit" -gt 720 ] || [ "$vm_state" == "-1" ]
		then
			# If Testing-VM(B-Guest Machine) is not booted Or Current Time Duration is Over Limit Duration.
			# Retrying Kernel Tracing Usecase in A-Guest Machine
			echo -e "\t\t\t${RED}VM-B-"$vm_name"-Tailored Kernel Not Working Well! :(${NC}"
			#watch_dog_vmrun &	# Run Watchdog for vmrun

			# Get State File of Testing VM
			local exit_log=$(vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_file" "/tmp/$vm_b_state_log" "$ram_disk_dir/$kernel_src/")
			# Get Log of Testing VM
			local vm_state_log=$(cat $ram_disk_dir/$kernel_src/$vm_b_state_log 2>/dev/null)

			echo -e "\t\t\t${RED}|Failed Log|$vm_name|$test_config|: "$vm_state_log" ${NC}"
			# Remove Usecase Log File
			rm -rf $ram_disk_dir/$kernel_src/$vm_b_state_log
			#vmrun -T ws stop "$vmx_guest_b"
			
			#
			# Write Failed Log to File
			create_lock_or_wait "/tmp/faillog"
			echo -e "$test_config : $vm_state_log\n" >> $faillog_file
			remove_lock "/tmp/faillog"
			
			#
			# Add This Config in The Essential Configuration List
			#
			create_lock_or_wait "/tmp/whitelist"
			local whitelist=$(cat "$essential_config_list_file")
			if [ ${#whitelist} -eq 0 ];
			then
				whitelist="^$test_config"
				echo "$whitelist" > "$essential_config_list_file"

			else
				whitelist="$whitelist\|^$test_config"
				echo "$whitelist" > "$essential_config_list_file"

			fi
			remove_lock "/tmp/whitelist"

			#
			# Change Test VM State to Idle
			echo -e "\t\t\t[#]VM-${YELLOW}B-"$vm_name"${NC}-State Changing To Idle..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i "s/$vm_name:1/$vm_name:0/g" "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"

			break

		# Optional Condition
		elif [ -z "$exit_code" ] && [ "$vm_state" == "1" ]
		then
			echo -e "\t\t\tInstall Tailored Kernel on VM-${YELLOW}B-"$vm_name"${NC}..."

		# Optional Condition
		elif [ -z "$exit_code" ] && [ "$vm_state" == "2.0" ]
		then
			echo -e "\t\t\t[#0] VM-${YELLOW}B-"$vm_name"${NC}-Use-Case..."
			#break

		# Optional Condition
		elif [ -z "$exit_code" ] && [ "$vm_state" == "2.1" ]
		then
			echo -e "\t\t\t[#1] VM-${YELLOW}B-"$vm_name"${NC}-Use-Case..."
			#break
		fi
		sleep 3
	done

	# Print Ending Time & Time Difference 
	duration=$SECONDS
	#echo "$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed..."
	echo -e "${GREEN}$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed...${NC}"
}

#########################################################
#
# Entry Point of Main Function
#
#########################################################

<<'COMMENT'
# Check Input Arguments
if [ $# -lt 4 ]
then
	echo "Usage: commands-in-host.sh [VMX File Directory & Name Of A-VM] [The Number Of Snapshot Of A-VM] [VMX File Directory & Name Of B-VM] [The Numver Of Snapshot OF B-VM]"
	echo "Example: ./commands-in-host.sh /home/ultract/vmware/gooroom-1.0/gooroom-1.0.vmx Snapshot1 /home/ultract/vmware/Clone of gooroom-1.0/Clone of gooroom-1.0.vmx Snapshot2"
	exit 1
fi
COMMENT

#
# Usage
if [ $# -lt 1 ]
then
	echo "Usage: commands-in-host.sh [Number of Virtual Machines]"
	echo "Example: ./commands-in-host.sh 5"
	exit 1
fi

#
# Print Start Time & Reset SECOND Environment Variable
date
SECONDS=0

#
# Check whether Vmware Workstation is Executed
check_vmware=$(ps aux | grep "/usr/lib/vmware/bin/vmware$")
if [ -z "$check_vmware" ];
then
        #echo $check_vmware
	echo "Executing VMware Workstation..."
	/usr/lib/vmware/bin/vmware &
	echo "Sleep a few seconds"
	sleep 15
fi

#<<'FIRST_STAGE'

#
# Remove All Data in Ram Disk
# rm -rf $ram_disk_dir/*
rm -rf $ram_disk_dir/linux-*

#
# Revert to the Snapshot of Kernel Trace VM
#
echo "Revert To The Snapshot Of VM-A..."
vmrun -T ws revertToSnapshot "$vmx_guest_a" "$snapshot_vm_a"
vmrun -T ws start "$vmx_guest_a"

case "${target_os}" in
  0)
	#
	# Gooroom
	script_path="gooroom-tailor"
	terminal_name="/usr/bin/xfce4-terminal"
	initrd_install="undertaker-tracecontrol-prepare-debian"
	;;

  1)
	#
	# Debian
	script_path="debian-tailor"
	terminal_name="/usr/bin/gnome-terminal"
	initrd_install="undertaker-tracecontrol-prepare-debian"
	;;

  2)
	#
	# Ubuntu
	script_path="ubuntu-tailor"
	terminal_name="/usr/bin/gnome-terminal"
	initrd_install="undertaker-tracecontrol-prepare-ubuntu"
	;;
esac

#
# Copy Script File to Kernel Trace VM(A-Guest) Machine
echo "Copy Script File to A-Guest Machine..."
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_guest_a" ~/auto-kernel-tailoring/${script_path}/${script_in_guest_a} /home/"$guser"/"$script_in_guest_a"

#
# Copy Use-case script file to Kernel Trace VM(A-Guest) Machine
echo "Copy Use-Case Script File into A-Guest Machine..."
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_guest_a" ~/auto-kernel-tailoring/${script_path}/${usecase_script_a} /home/"$guser"/"$vm_usecase_script"

#
# Copy Autostart File to Execute Use-Case Script
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_guest_a" ~/auto-kernel-tailoring/${script_path}/${autostart_file} /home/"$guser"/"$autostart_file"

#
# Copy Auto Usecase(Cnee) File
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_guest_a" ~/auto-kernel-tailoring/${script_path}/${auto_event_file} /home/"$guser"/"$auto_event_file"

#
# Copy Kernel-Tailoring Script File into Kernel Trace VM(A-Guest) Machine
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_guest_a" ~/auto-kernel-tailoring/${script_path}/${tailor_script} /home/"$guser"/"$tailor_script"

#
# Copy undertaker-tracecontrol-prepare(initrd) to Kernel Trace VM(A-Guest) Machine
echo "Copy undertaker-tracecontrol-prepare(initrd) to A-Guest Machine..."
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_guest_a" ~/auto-kernel-tailoring/${script_path}/${initrd_install} /home/"$guser"/"$initrd_install"

#
# Copy undertaker configuration files
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_guest_a" ~/auto-kernel-tailoring/${script_path}/${undertaker_whitelist} /home/"$guser"/"$undertaker_whitelist"
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromHostToGuest "$vmx_guest_a" ~/auto-kernel-tailoring/${script_path}/${undertaker_ignore} /home/"$guser"/"$undertaker_ignore"

#
# Execute the Script File in Kernel Trace VM(A-Guest) Machine
#
echo "Executing the Script File into A-Guest Machine..."
vmrun -T ws -gu "$guser" -gp "$gpw" runProgramInGuest "$vmx_guest_a" "/usr/bin/env" "DISPLAY=:0" "$terminal_name" "-x" "/home/$guser/$script_in_guest_a" & 2>/dev/null


# Print Ending Time & Time Difference 
date
duration=$SECONDS
#echo "$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed..."
echo -e "${GREEN}$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed...${NC}"

#
# Check Kernel Trace VM whether Firtst Kernel Tailoring Finished by Undertaker
#
while true
do
	echo "Waiting VM-A Finish The Kernel Tailoring..."
	# Get State File of VM
	exit_code=$(vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_guest_a" "/tmp/$vm_a_state_file" "$ram_disk_dir" 2> /dev/null)
	vm_state=$(cat $ram_disk_dir/$vm_a_state_file 2>/dev/null)
	if [ -z "$exit_code" ] && [ "$vm_state" == "0" ]
	then
		rm -rf /$ram_disk_dir/$vm_a_state_file
		break
	elif [ "$vm_state" == "-1" ]
	then
		echo -e "${RED}[$vm_state]${NC} Kernel Tailoring Failed by Undertaker! :("
		rm -rf /$ram_disk_dir/$vm_a_state_file
        	exit 1
	elif [ "$vm_state" == "1" ]
	then
		#echo "[$vm_state] Install Undertaker & Download Kernel Source, DbgSym..."
		echo -e "${YELLOW}[$vm_state]${NC} Install Undertaker & Download Kernel Source, DbgSym..."

	elif [ "$vm_state" == "2" ]
	then
		#echo "[$vm_state] Performing Use-Cases..."
		echo -e "${YELLOW}[$vm_state]${NC} Performing Use-Cases..."

	elif [ "$vm_state" == "3" ]
	then
		#echo "[$vm_state] Kernel Tailoring by Undertaker..."
		echo -e "${YELLOW}[$vm_state]${NC} Kernel Tailoring by Undertaker..."

	fi
	sleep 15
done

#
# Complete First Kernel Tailoring
# Print Ending Time & Time Difference 
date
duration=$SECONDS
#echo "$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed..."
echo -e "${GREEN}$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed...${NC}"
#send_email "Finish Kernel Features Tracing \r\n"

#FIRST_STAGE
####################################################################
#<<'COMMENT_2' 
#Testing Tailored Kernel & Complementary

#
# Copy Kernel Source File in Trace VM to Ram Disk in Host
#
echo "Copy Source Of Kernel & .config File..."
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_guest_a" "/tmp/$guest_kernel_src" "$ram_disk_dir/"

<<'COMMENT' # Block Comments
kernel_ver=$(cat $ram_disk_dir/$guest_kernel_ver)
kernel_ver=${kernel_ver:0:5}
if [ "${kernel_ver:4:1}" -eq "0" ]
then
        kernel_file="linux-${kernel_ver:0:3}.tar.gz"
else
        kernel_file="linux-$kernel_ver.tar.gz"
fi
COMMENT

kernel_file=$(cat $ram_disk_dir/$guest_kernel_src)
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_guest_a" "/home/$guser/$kernel_file" "$ram_disk_dir"
tar xvfz "$ram_disk_dir/$kernel_file" -C $ram_disk_dir

#
# Copy First Tailored Kernel Config File & Original Kernel Config File into Host
#
kernel_dir_name=$(ls $ram_disk_dir | grep "linux-*" | head -1)
echo "Copy Tailored .config File to Host"
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_guest_a" "/home/$guser/$kernel_dir_name/.config" $ram_disk_dir/$kernel_dir_name/.config

echo "Copy Original .config File to Host"
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_guest_a" "/tmp/$org_kern_conf" "$ram_disk_dir"
org_kern_conf_file=$(cat $ram_disk_dir/$org_kern_conf)
vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_guest_a" "/boot/$org_kern_conf_file" "$ram_disk_dir/$kernel_dir_name/$org_kern_conf_file"

# For Testing, /boot/config-x.x.x to .config
# vmrun -T ws -gu "$guser" -gp "$gpw" copyFileFromGuestToHost "$vmx_guest_a" "/boot/$org_kern_conf_file" "$ram_disk_dir/$kernel_dir_name/.config"

#
# Suspend Kernel Trace VM. It won't be used
vmrun -T ws suspend "$vmx_guest_a"

#COMMENT_2
##################################################################################################
#COMMENT
#################################################
# Preparation of Testing Tailored Kernel in Host(Ramdisk)
#################################################
#SECONDS=0

cd $ram_disk_dir/linux-*

#
# Look into 1th Tailored .config by undertaker
#
<<'COMMENT'
first_config_result="[ 1th Tailored .config file ] \r\n"
first_config_result="$first_config_result Groups : $(grep -v "^# CONFIG" "$config_file" | grep "# " | sort | wc -l)\r\n"
first_config_result="$first_config_result Enable : $(grep -v "^# CONFIG" "$config_file" | grep '=y' "$config_file" | sort | wc -l)\r\n"
first_config_result="$first_config_result Module : $(grep -v "^# CONFIG" "$config_file" | grep '=m' "$config_file" | sort | wc -l)\r\n"
first_config_result="$first_config_result Disable : $(grep 'not set' "$config_file" | sort | wc -l)\r\n"
first_config_result="$first_config_result Etc(Str, Num) : $(grep -v "^# CONFIG" "$config_file" | cut -d'=' -f2 | grep '^"\|0x[0-9a-e]*\|^[0-9]\+' | wc -l)\r\n"
COMMENT
first_config_result="$(analysis_config "$config_file")"

#
# Send Email about Working State
#
send_email "Finish Kernel Features Tracing \r\n $first_config_result \r\n"

make -s clean

#make -f debian/rules clean
#export DEBEMAIL="gooroom@gooroom.kr"
#export NAME="gooroom"
#export NEW_VERSION="$(dpkg-parsechangelog --show-field Version)+grm1"
#echo "$DEBEMAIL:$NAME:$NEW_VERSION"
#dch --distribution gooroom-1.0 --force-distribution --newversion $NEW_VERSION "Disable JUMP_LABEL for security"

#
# Patch Kernel Source Code For Customizing
#
#patch -N -p1 < blablabla.patch

#
# Write Kernel Name & Version of Makefile
#
#sed -i '/EXTRAVERSION =/c\EXTRAVERSION = .gooroom' ./Makefile
#sed -i '/NAME =/c\NAME = Gooroom' ./Makefile

#
# Make Localmodconfig of Original Kernel .config File
# - Maximum Set of Kernel Configuration
#

# Change .config to Original .config(config-xxxx.xxx.xxx.)
#org_kern_conf_file=$(ls -l | awk '{print $9}' | grep '^config-[0-9]\.[0-9]\.[0-9]')
org_kern_conf_file=$(ls -l | awk '{print $9}' | grep '^config-[0-9]\.[0-9]\+\.[0-9]\+')

# Copy Tailored Config
cp "./$config_file" ./"$first_tailored_config"

# Restore .config to Original Configuration
cp "$org_kern_conf_file" "./$config_file"

# Localmodconfig to Default .config
make LSMOD="./$lsmod_file" localmodconfig
#yes "" | make LSMOD="./$lsmod_file" localmodconfig

# Copy Localmodconfig File to Another
cp "./$config_file" "$other_config_file"

#
# Make Localmodconfig of Tailored .config File
# - Find out Dependencis of Localmodconfig for Tailored .config
#

# Restore Tailored Config to .config 
cp ./"$first_tailored_config" "./$config_file"

# Localmodconfig to Tailored .config
# Save Dependencies of Localmodconfig
make LSMOD="./$lsmod_file" localmodconfig &> ./"$localmodconfig_result"

##
# Using Original .config(config-xxxx.xxx.xxx) Not Localmodconfig
##
#cp "$org_kern_conf_file" "$other_config_file"

# Print Dependencies of Localmodconfig on Tailored .config
cat ./"$localmodconfig_result"

# Restore Tailored Config File to .config
cp ./"$first_tailored_config" "./$config_file"

#
# Disable Enabled(=y) Configurations Not in Original Localmodconfig
#
diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '< CONFIG_' | awk '{print $2}' | sed 's/=y//g' | sed 's/CONFIG_//g' | while read line; 
do
	#echo "./scripts/config --disable "$line""
	./scripts/config --disable "$line"
done

#
# Disable Modules(=m) Configurations Not in Original Localmodconfig
#
diff -i <(sort "$config_file" | grep '=m') <(sort "$other_config_file" | grep '=m') | grep '< CONFIG_' | awk '{print $2}' | sed 's/=m//g' | sed 's/CONFIG_//g' | while read line; 
do
	#echo "./scripts/config --disable "$line""
	./scripts/config --disable "$line"
done

# Adjust Tailored .config by Results(Dependencies) of Localmodconfig
# Set Config of Dependencies by Warning & Error Messages From Tailored Localmodconfig
sed 's/\<module [a-zA-Z0-9_]* did not have configs\>//g' ./"$localmodconfig_result" | sed 's/\ /\n/g' | sort -u | grep "^CONFIG_" | sed 's/CONFIG_//g' | while read line;
do
	temp=$(grep "$line" "$org_kern_conf_file")
	if echo "$temp" | grep -q '=y';
	then
		#echo "./scripts/config --enable "$line""
		./scripts/config --enable "$line"
	elif echo "$temp" | grep -q '=m';
	then
		#echo "./scripts/config --module "$line""
		./scripts/config --module "$line"
	#else
		#echo "./scripts/config --disable "$line""
		#./scripts/config --disable "$line"
	fi
done

# Enable Dependency Configuration of Modules
grep -o "dependencies ([A-Z\_\& ]*)" ./"$localmodconfig_result" | sed 's/dependencies (//g' | sed 's/)//g' | sed 's/\&\&//g' | while read dep_conf; 
do
	for item in $dep_conf
	do
		#echo "./scripts/config --enable "$item""
		./scripts/config --enable "$item"
	done
done

# Print Ending Time & Time Difference 
#date
#duration=$SECONDS
#echo "$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed..."
#send_email "Finish Adjusting Kernel .config \r\n"

#COMMENT
##############################################################################################
# Identify Essential Config in Original Localmodconfig
#

#
# Initialize Test VM State File
echo "Initialize Test VM State File..."
rm -rf "$test_vm_state_file"
for i in $(seq "$test_vm_num");
do
	echo "Tester_$i:0" >> "$test_vm_state_file"
done

#
# Initialize Lock In /tmp
rm -rf /tmp/*.lock.d

#
# Initialize Necessary & Not Necessary Configuration Files
echo "$useless_config_group" > "$useless_config_group_file"
echo "$whitelist" > "$essential_config_list_file"


###################################################################
#
# Extract Test Kernel Configuration
# Localmodconfig(Maximum Set) - 1st Tailored .config(Minimum Set)
#
###################################################################

#
# Grouping(NET -> NET, NET_XXX)
# The Group = (Localmodconfig Group - Tailored Config Group)
# Only Enabled(=y) Test Configs
# - Descending Order of Group
#test_config_list=$(diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '> CONFIG_' | cut -d"_" -f2 | sed 's/=y//g' | uniq -c | sort -r | awk '{print $2}')

# Only Enabled(=y) Test Configs
# - Ascending Order of Group
#test_config_list=$(diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '> CONFIG_' | cut -d"_" -f2 | sed 's/=y//g' | uniq -c | sort | awk '{print $2}')

# Only Enabled, Module Configuration
# - Descending Order
#test_config_list=$(diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '> CONFIG_' | cut -d"_" -f2 | sed 's/=[ym]//g' | uniq -c | sort -r | awk '{print $2}')


#
# Each Configuration(Not Grouping), Lexical Ascending Order
#
# All Configurations(Not Exception Values)
# 
test_config_list=$(diff -i <(sort "$config_file") <(sort "$other_config_file") | grep '> CONFIG_' | sed 's/> CONFIG_//g' | cut -d"=" -f1 | sort)
#test_config_list=$(diff -i <(sort "$config_file" | grep '=y\|=m\|="\|=[0x]*[0-9a-e]*\|^[0-9]\+') <(sort "$other_config_file" | grep '=y\|=m\|=^"\|=[0x]*[0-9a-e]*\|^[0-9]\+') | grep '> CONFIG_' | sed 's/> CONFIG_//g' | cut -d"=" -f1 | uniq -c | awk '{print $2}')

# Except Module(=m), Number(=0x1234), String(="as")
# Only Enabled(=y) Configurations ???
#
#test_config_list=$(diff -i <(sort "$config_file") <(sort "$other_config_file") | grep '> CONFIG_' | grep '=y' | sed 's/> CONFIG_//g' | cut -d"=" -f1 | sort)
#test_config_list=$(diff -i <(sort "$config_file") <(sort "$other_config_file") | grep '> CONFIG_' | grep -v '=m\|="\|=0x[0-9a-e]*\|=[0-9]\+' | sed 's/> CONFIG_//g' | cut -d"=" -f1 | sort)


# Except Number & String
#
#test_config_list=$(diff -i <(sort "$config_file") <(sort "$other_config_file") | grep '> CONFIG_' | grep -v '="\|=0x[0-9a-e]*\|=[0-9]\+' | sed 's/> CONFIG_//g' | cut -d"=" -f1 | sort)

# Only Enabled(=y) Configurations
#
#test_config_list=$(diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '> CONFIG_' | sed 's/> CONFIG_//g' | sed 's/=y//g' | uniq -c | sort -r | awk '{print $2}')

# Ignore Configurations of Whitelist
if [ ${#whitelist} -ne 0 ];
then
	test_config_list=$(echo "$test_config_list" | grep -v "$whitelist")
fi

# Ignore Configurations of Blacklist
if [ ${#blacklist} -ne 0 ];
then
	test_config_list=$(echo "$test_config_list" | grep -v "$blacklist")
fi

<<'COMMENT'
# Ignore Configuration of Useless Configuration Group
if [ ${#useless_config_group} -ne 0 ];
then
	test_config_list=$(echo "$test_config_list" | grep -v "$useless_config_group")
fi
COMMENT

################################################################
#
# Prune The List of Test Configurations
# - Check Optional Configuration("HasPrompt") in models/x86.rsf
# - HasPrompt means that can be choose on Menuconfig
#
################################################################
echo "Prune Test Configuration List"
while read line;
do
        #echo "$line"
        hasprompts=$(grep '^HasPrompts'$'\t'"$line"$'\t' ./models/x86.rsf | head -n 1 | awk '{print $3}')
	# Only Having Prompts on Menuconfig
        if [ "$hasprompts" == "1" ];
        then
                #echo "$line"
                config_list="$config_list\n$line"
        fi
done <<< "$(echo "$test_config_list")"
test_config_list=$(echo -e "$config_list" | tail -n +2) # Starting with 2nd Line(1st Line is Space)


<<'TEST_CONFIG_1'
##############################################################
#
# Sorting Test Configuration List
# - Sorting by Config of Depth("_" -> delimiter)
#
##############################################################
echo "Sorting Test Configuration List"
config_list=""
while read line;
do
	# Count "_"
        depth_conf=$(echo "$line" | grep -o '_' | wc -l)
        depth_conf=$((depth_conf+1))
        #echo "$depth_conf    $line"
	
	# Write	Configuration Name with Depth
        depth_conf="$depth_conf\t$line"
        config_list="$config_list\n$depth_conf"
done <<< "$(echo "$test_config_list")"
#test_config_list=$(echo -e "$config_list" | sort -r | awk '{print $2}')

##############################################################
#
# Randomize for Each Configuration in Same Depth
#
##############################################################
test_config_list=$(echo -e "$config_list" | sort -R | sort -r -s -n -k 1,1 | awk '{print $2}')
#test_config_list=$(echo -e "$config_list" | sort -R | sort -r -s -n | awk '{print $2}')
TEST_CONFIG_1

#<<'TEST_CONFIG_2'

#############################################################
#
# Make a Dependency List of Each Configuration Depending on Original Localmodconfig
#
#############################################################
echo "Make a Dependency List of Each Configuration..."
list_config_deps=""
while read line;
do
	# Find out a Dependency of a Configuration & Remove a Name of Configuration
	# Only Depends on Configuration, Ignore Select Configuration(->)
	config_deps=$(grep "^$line " ./models/x86.model | sed "s/^$line //g" | sed "s/-> CONFIG_[A-Z0-9_]\+//g")
	if [ -n "$config_deps" ];
	then
		#echo "$config_deps"
		# Make a Dependency List
		list_config_deps="$list_config_deps$config_deps\n"
	fi
done <<< "$(cat "$other_config_file" | grep "^CONFIG_" | awk -F'=' '{print $1}')"
#done <<< "$(echo "$test_config_list" | grep "^CONFIG_" | awk -F'=' '{print $1}')"
#echo -e "$list_config_deps"

#############################################################
#
# Count The Number of Dependencies
#
#############################################################
echo "Count The Number of Dependencies..."
for test_config in $(echo "$test_config_list");
do
	# Count
	deps_num=$(echo -e "$list_config_deps" | grep -c "CONFIG_$test_config")
	#echo -e "$deps_num\t$test_config"
	# Count Number & Configuration Name 
	config_deps_num="$deps_num\t$test_config"
	# Make a List
	list_config_deps_num="$list_config_deps_num$config_deps_num\n"
done

#echo -e "$list_config_deps_num" | sort -n | tail -n +2

# Dependencies in Descending Order 
#test_config_list=$(echo -e "$list_config_deps_num" | sort -n | tail -n +2 | sort -R | sort -s -n -r -k 1,1 | awk '{print $2}')
# Dependencies in Ascending Order 
test_config_list=$(echo -e "$list_config_deps_num" | sort -n | tail -n +2 | sort -R | sort -s -n -k 1,1 | awk '{print $2}')

#TEST_CONFIG_2

#
# Save Test Configuration List to File
echo "$test_config_list" > ./"$test_config_group_list"

#
# Analyze Tailored Configuration File
echo -n "" > ./"$log_file"
analysis_config_log "$config_file" "[Kernel Tailoring Start]"

#
# Duplicate Kernel Source Directory
#
echo "Duplicate Kernel Source Directory..."
cd ..
# Remove Previous Directories
rm -rf ./Tester_*

#test_vm_num=5
# Create New Directories & Copy Kernel Source
for i in $(seq "$test_vm_num");
do
	mkdir ./"Tester_$i"
	cp -R ./linux-*/ ./"Tester_$i/"
done
cd $ram_disk_dir/linux-*

#
# Count All Configurations on the List
num_of_conf=$(echo "$test_config_list" | wc -l)

#
# Calculate a Quater of All Configurations
quater_num_of_conf=$((num_of_conf/4))

#
# Calculate a Half of All Configurations
half_num_of_conf=$((num_of_conf/2))
echo -e "${GREEN}Testing Configs [#]: ${num_of_conf} ${NC}"


#
# Run Periodical Restart Script for VMware Network Daemon
#
sudo ~/auto-kernel-tailoring/tools/restart_vmnet.sh & >/dev/null

################################################################################
#
# Start Test Each Configurations on Testing VM
# - via Background Job
#
################################################################################
#for test_config in $(echo "$test_config_list" | tail -n +"$count");
#send_email "Start Test VM \r\n"
progress_cnt=0
for test_config in $(echo "$test_config_list");
do
	# Change Test Config String
	#test_config="^${test_config}_\|^${test_config}=" # For Configuration Group 

	echo -e "${GREEN}[${num_of_conf}]${NC} Putting a Testing Job to Each Virtual Machines..."
	while true; 
	do
		#
		# Send an Email about Progress
		#
		if [ "$num_of_conf" -eq "$((half_num_of_conf+quater_num_of_conf))" ] && [ "$progress_cnt" -eq 0 ]
		then
			send_email "Tailored Kernel Testing Progress: A Quater Done!\r\nRemaining Configs : $num_of_conf\r\nTotal $(($SECONDS / 60)) Minutes and $(($SECONDS % 60)) Seconds Elapsed...\r\n"
			progress_cnt=$((progress_cnt + 1))
		elif [ "$num_of_conf" -eq "$half_num_of_conf" ] && [ "$progress_cnt" -eq 1 ]
		then
			send_email "Tailored Kernel Testing Progress: Half Done!\r\nRemaining Configs : $num_of_conf \r\n Total $(($SECONDS / 60)) Minutes and $(($SECONDS % 60)) Seconds Elapsed...\r\n"
			progress_cnt=$((progress_cnt + 1))
		elif [ "$num_of_conf" -eq "$quater_num_of_conf" ] && [ "$progress_cnt" -eq 2 ]
		then
			send_email "Tailored Kernel Testing Progress: Three Fourths Done!\r\nRemaining Configs : $num_of_conf \r\n Total $(($SECONDS / 60)) Minutes and $(($SECONDS % 60)) Seconds Elapsed... \r\n"
			progress_cnt=$((progress_cnt + 1))
		fi

		#
		# Grant Jobs to a Idle Virtual machine
		#
		#echo "Checking Idle State of VM..."
		if [ "$(grep "Tester_1" "$test_vm_state_file" | cut -d':' -f2)" != "1" ]; then
			echo -e "\t[VM-#1] Start Working..."
			create_lock_or_wait "/tmp/test_vm_state"
			# Change to Busy State
			sed -i 's/Tester_1:0/Tester_1:1/g' "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"
			
			#
			# Testing on VM-1
			test_config_func "Tester_1" "$ram_disk_dir/vmware/Tester_1/Tester_1.vmx" "$test_config" &
			num_of_conf=$((num_of_conf-1))
			sleep 2
			break

		elif [ "$(grep "Tester_2" "$test_vm_state_file" | cut -d':' -f2)" != "1" ]; then

			if [ "$test_vm_num" -le 1 ]
			then
				continue
			fi

			echo -e "\t[VM-#2] Start Working..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i 's/Tester_2:0/Tester_2:1/g' "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"

			#
			# Testing on VM-2
			test_config_func "Tester_2" "$ram_disk_dir/vmware/Tester_2/Tester_2.vmx" "$test_config" &
			num_of_conf=$((num_of_conf-1))
			sleep 2
			break

		elif [ "$(grep "Tester_3" "$test_vm_state_file" | cut -d':' -f2)" != "1" ]; then

			if [ "$test_vm_num" -le 2 ]
			then
				continue
			fi

			echo -e "\t[VM-#3] Start Working..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i 's/Tester_3:0/Tester_3:1/g' "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"
			
			#
			# Testing on VM-3
			test_config_func "Tester_3" "$ram_disk_dir/vmware/Tester_3/Tester_3.vmx" "$test_config" &
			num_of_conf=$((num_of_conf-1))
			sleep 2
			break

		elif [ "$(grep "Tester_4" "$test_vm_state_file" | cut -d':' -f2)" != "1" ]; then

			if [ "$test_vm_num" -le 3 ]
			then
				continue
			fi

			echo -e "\t[VM-#4] Start Working..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i 's/Tester_4:0/Tester_4:1/g' "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"

			#
			# Testing on VM-4
			test_config_func "Tester_4" "$ram_disk_dir/vmware/Tester_4/Tester_4.vmx" "$test_config" &
			num_of_conf=$((num_of_conf-1))
			sleep 2
			break

		elif [ "$(grep "Tester_5" "$test_vm_state_file" | cut -d':' -f2)" != "1" ]; then
	
			if [ "$test_vm_num" -le 4 ]
			then
				continue
			fi

			echo -e "\t[VM-#5] Start Working..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i 's/Tester_5:0/Tester_5:1/g' "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"

			#
			# Testing on VM-5
			test_config_func "Tester_5" "$ram_disk_dir/vmware/Tester_5/Tester_5.vmx" "$test_config" &
			num_of_conf=$((num_of_conf-1))
			sleep 2
			break

		elif [ "$(grep "Tester_6" "$test_vm_state_file" | cut -d':' -f2)" != "1" ]; then
			
			if [ "$test_vm_num" -le 5 ]
			then
				continue
			fi

			echo -e "\t[VM-#6] Start Working..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i 's/Tester_6:0/Tester_6:1/g' "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"

			#
			# Testing on VM-6
			test_config_func "Tester_6" "$ram_disk_dir/vmware/Tester_6/Tester_6.vmx" "$test_config" &
			num_of_conf=$((num_of_conf-1))
			sleep 2
			break

		elif [ "$(grep "Tester_7" "$test_vm_state_file" | cut -d':' -f2)" != "1" ]; then
	
			if [ "$test_vm_num" -le 6 ]
			then
				continue
			fi

			echo -e "\t[VM-#7] Start Working..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i 's/Tester_7:0/Tester_7:1/g' "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"

			#
			# Testing on VM-7
			test_config_func "Tester_7" "$ram_disk_dir/vmware/Tester_7/Tester_7.vmx" "$test_config" &
			num_of_conf=$((num_of_conf-1))
			sleep 2
			break

		elif [ "$(grep "Tester_8" "$test_vm_state_file" | cut -d':' -f2)" != "1" ]; then
	
			if [ "$test_vm_num" -le 7 ]
			then
				continue
			fi

			echo -e "\t[VM-#8] Start Working..."
			create_lock_or_wait "/tmp/test_vm_state"
			sed -i 's/Tester_8:0/Tester_8:1/g' "$test_vm_state_file"
			remove_lock "/tmp/test_vm_state"
			
			# 
			# Testing on VM-8
			test_config_func "Tester_8" "$ram_disk_dir/vmware/Tester_8/Tester_8.vmx" "$test_config" &
			num_of_conf=$((num_of_conf-1))
			sleep 2
			break

		fi
		sleep 10
	done
done

#
# Waiting All Testing Finished
#
while true;
do
	echo "Waiting All Jobs of VMs Finished..."
	if [ "$(cat "$test_vm_state_file" | cut -d':' -f2 | grep "1" | head -n 1)" != "1" ]; then
		echo -e "\tAll Jobs are done !!"
		# Power off VMs  
		while read line;
		do
			vm_dir=$(echo "$line" | cut -d':' -f1)
			#
			# Stop Virtual Machines Finished
			vmrun -T ws stop "$ram_disk_dir/vmware/$vm_dir/$vm_dir.vmx"
			sleep 2

		done <<< "$(cat "$test_vm_state_file")"		
		break
	fi
	sleep 5
done

echo "Complete Testing about All Test Configurations :)..."

#
#
# Final Testing for Kernel Tailoring
# - Using Test VM-1
# - Move to Tester_1's Kernel Source Directory
#
test_config_func "Tester_1" "$ram_disk_dir/vmware/Tester_1/Tester_1.vmx" "$final_test_id"

#
# Killall Etc Processes
#
#sudo killall "restart_vmnet.sh"
#killall "watch_dog_vmrun"

#
# Save Final Tailored .config
#
if [[ -n "$(cat "$useless_config_group_file" | sed 's/\\|/\n/g' | grep "FINAL_TEST")" ]];then
	cp "$config_file" ~/auto-kernel-tailoring/tailored_conf_file/$(date +%y%m%d).config
fi

##################################################
#
# Send Email about Information of Tailored Kernel
#
##################################################

#
# Print Ending Time & Time Difference 
duration=$SECONDS
#echo "Total $(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed..."
echo -e "Total ${GREEN}$(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed...${NC}"
essential_result="Essential Config Groups : $(cat $essential_config_list_file | sed s/\|/\\n/g | wc -l)"
echo "$essential_result"
useless_result="Not Essential Config Groups : $(cat $useless_config_group_file | sed s/\|/\\n/g | wc -l)"
echo "$useless_result"

#
# Look into Final Tailored .config
<<'COMMENT'
final_config_result="[ Final Tailored .config file ] \r\n"
final_config_result="$final_config_result Groups : $(grep -v "^# CONFIG" "$config_file" | grep "# " | sort | wc -l)\r\n"
final_config_result="$final_config_result Enable : $(grep -v "^# CONFIG" "$config_file" | grep '=y' "$config_file" | sort | wc -l)\r\n"
final_config_result="$final_config_result Module : $(grep -v "^# CONFIG" "$config_file" | grep '=m' "$config_file" | sort | wc -l)\r\n"
final_config_result="$final_config_result Disable : $(grep 'not set' "$config_file" | sort | wc -l)\r\n"
final_config_result="$final_config_result Etc(Str, Num) : $(grep -v "^# CONFIG" "$config_file" | cut -d'=' -f2 | grep '^"\|0x[0-9a-e]*\|^[0-9]\+' | wc -l)\r\n"
COMMENT
# Analyze Tailored .config
first_config_result="$(analysis_config "$first_tailored_config")"
final_config_result="$(analysis_config "$config_file")"
lmconfig_result="$(analysis_config "$other_config_file")"
original_config_result="$(analysis_config "$(find ./ -maxdepth 1 -type f -name "config-*" 2>/dev/null)")"

#
# Send Email about Information of Tailored Kernel

# Analyze Distribution of Tailored .config
analyze_config_dir "$config_file" > ./distribute_tailored.config
tmp="$(cat ./distribute_tailored.config)"
# Analyze Distribution of Original_localmodconfig
analyze_config_dir "$other_config_file" > ./distribute_localmodconfig.config
tmp2="$(cat ./distribute_localmodconfig.config)"
# Analyze Distribution of Original .config
analyze_config_dir "$(find ./ -maxdepth 1 -type f -name "config-*" 2>/dev/null)" > ./distribute_original.config
tmp3="$(cat ./distribute_original.config)"
# Analyze Distribution of First Tailored .config
analyze_config_dir "$first_tailored_config" > ./distribute_first.config
tmp4="$(cat ./distribute_first.config)"


# Check Target OS(Linux Distro)
case "${target_os}" in
	0)
	  #
	  # Gooroom
	  target="Gooroom"
	  ;;
	
	1)
	  #
	  # Debian
	  target="Debian"
	  ;;

	2)
	  #
	  # Ubuntu
	  target="Ubuntu"
	  ;;
esac

# Send Email about Kernel Tailoring Results
send_email "$target Kernel Tailoring Finished! \r\n\r\n \
Total $(($duration / 60)) Minutes and $(($duration % 60)) Seconds Elapsed... \r\n \
[ Final Tailored .config ] \r\n \
$final_config_result \r\n \
[ First Tailored .config ] \r\n \
$first_config_result \r\n \
[ Localmodconfig .config ]\r\n \
$lmconfig_result \r\n \
[ Original .config ]\r\n \
$original_config_result \r\n\r\n \
[ Distribution of Final Tailored .config ]\r\n \
$tmp \r\n \
[ Distribution of First Tailored .config ]\r\n \
$tmp4 \r\n \
[ Distribution of Localmodconfig .config ]\r\n \
$tmp2 \r\n \
[ Distribution of original .config ]\r\n \
$tmp3 \r\n\r\n \
[ Test Failure Log Data ] \r\n \
$(cat $faillog_file) \r\n \
[ Kernel Build Failure Configuration ] \r\n \
$(cat $kern_build_failure)\r\n"

<<'BACKUP_VM'
#
# Backup Final Tested Virtual Machine
vmrun -T ws stop "$ram_disk_dir/vmware/Tester_1/Tester_1.vmx"
sleep 60
cp -r "$ram_disk_dir/vmware/Tester_1" /media/ultract/HDD/tailored_VMs/"${target_os_name[$target_os]}"/

# Start a Virtual Machine
vmrun -T ws start "$ram_disk_dir/vmware/Tester_1/Tester_1.vmx"
sleep 60
BACKUP_VM

# Execute Kernel Analyzing Script
echo "Execute Kernel Analyzing Script in Virtual Machone..."
/home/ultract/auto-kernel-tailoring/tools/auto_kernel_analyze.sh "$target_os" "$email_addr"

# Execute Performance Test For Tailored Kernel in Virtual Machine
#echo "Execute Performance Comparision Test For Kernels in Virtual Machine..."
#/home/ultract/auto-kernel-tailoring/tools/auto_performance_test_vm.sh "$target_os" "$email_addr"
