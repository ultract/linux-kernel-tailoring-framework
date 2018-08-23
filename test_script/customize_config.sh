#!/bin/bash

localmodconfig_result="lmconfig_result.txt"
not_have_config="not_have_config.txt"
lsmod_file="lsmod_result.txt"

config_file=".config"
#other_config_file="test_config"
#other_config_file="config-4.7.0-0.bpo.1-amd64"
other_config_file="org_localmodconfig"
#other_config_file="x86_64_defconfig"

# INPUT, VT, 
config_filter="KVM\|XEN\|CHROME\|APPARMOR\|TOMOYO\|SMACK\|DEBUG\|TEST\|TRACE\|_DUMP\|MACINTOSH"
#keywords="SERIAL\|MOUSE\||RTC\|BLK\|USB\|EFI\|THERMAL\|KEXEC\|AGP\|VT\|SND\|KALLSYMS\|DRM\|VGA\|TASK"
#keywords="X86\|ACPI\|PCI\|MOUSE\|GENERIC\|SERIAL\|BLK\|MEMORY\|SCHED\|INTEL\|ARCH\|NET\|MOUSE\|CPU\|INPUT\|RTC\|BLK\|USB\|EFI\|THERMAL\|PROC\|MODULE\|KEXEC\|AGP\|VT\|SND\|KALLSYMS\|DRM\|VGA\|TASK"

# Must be included keywords in Config 
# INPUT, VT, DRM, VGA(Just To Print Image During Booting time), 
#
#keywords="X86\|ACPI\|PCI\|MOUSE\|GENERIC\|SERIAL\|BLK\|MEMORY\|SCHED\|INTEL\|ARCH\|NET\|CPU\|RTC\|BLK\|USB\|EFI\|THERMAL\|PROC\|MODULE\|KEXEC\|AGP\|KALLSYMS\|WLAN\|KALLSYMS\|TASK"
keywords="^X86\|^ACPI\|^PCI\|^MOUSE\|^GENERIC\|^SERIAL\|^BLK\|^MEMORY\|^SCHED\|^INTEL\|^ARCH\|^NET\|^CPU\|^RTC\|^BLK\|^USB\|^EFI\|^THERMAL\|^PROC\|^MODULE\|^KEXEC\|^AGP\|^KALLSYMS\|^WLAN\|^KALLSYMS\|^TASK"
#keywords="NET\|MOUSE\|CPU\|INPUT"
#keywords="RTC\|BLK\|USB\|EFI\|THERMAL\|PROC\|MODULE\|KEXEC\|AGP\|VT\|SND\|KALLSYMS\|DRM\|VGA\|TASK"

#<<'COMMENT'
#######################################################################################
#
# Modify .config from warning & error messages of localmodconfig
#
#######################################################################################
# Adjusting Local Module Config
make LSMOD="./$lsmod_file" localmodconfig &> ./"$localmodconfig_result"
cat ./"$localmodconfig_result"
# Collect & Add not included CONFIG
#sed 's/\<module [a-zA-Z0-9_]* did not have configs\>//g' ./"$localmodconfig_result" | sed 's/\ /\n/g' | sort -u | grep "^CONFIG" | sed 's/$/=y/' > ./"$not_have_config"

# Checking Each Configuration From Original Config File
org_config_file=$(ls -l | awk '{print $9}' | grep '^config-[0-9]\.[0-9]\.[0-9]')

sed 's/\<module [a-zA-Z0-9_]* did not have configs\>//g' ./"$localmodconfig_result" | sed 's/\ /\n/g' | sort -u | grep "^CONFIG_" | sed 's/CONFIG_//g' | while read line;
do
	temp=$(grep "$line" "$org_config_file")
	if echo "$temp" | grep -q '=y';
	then
		echo "./scripts/config --enable "$line""
		./scripts/config --enable "$line"
	elif echo "$temp" | grep -q '=m';
	then
		echo "./scripts/config --module "$line""
		./scripts/config --module "$line"
	else
		echo "./scripts/config --disable "$line""
		./scripts/config --disable "$line"
	fi
done
#COMMENT

#cat ./"$not_have_config"
#diff .config "$not_have_config" | grep "> " | cut -d" " -f2 >> .config

#<<'COMMENT'
# Adjusting Dependencies
grep -o "dependencies ([A-Z\_\& ]*)" ./"$localmodconfig_result" | sed 's/dependencies (//g' | sed 's/)//g' | sed 's/\&\&//g' | while read line; 
do
	for item in $line
	do
		echo "./scripts/config --enable "$item""
		./scripts/config --enable "$item"
	done
done
#COMMENT
#######################################################################################

# Getting CONFIG to Enable From Tailoring Original Config File by localmodconfig
<<'COMMENT'
diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '> CONFIG_' | awk '{print $2}' | sed 's/=y//g' | sed 's/CONFIG_//g' | while read line; 
do 
	#if echo "$line" | grep -vq "$config_filter";
	#then
	echo "./scripts/config --enable "$line""
	./scripts/config --enable "$line"
	#fi
done
COMMENT
#<<'COMMENT'
# Disable Config Only included in .config
diff -i <(sort "$config_file" | grep '=y') <(sort "$other_config_file" | grep '=y') | grep '< CONFIG_' | awk '{print $2}' | sed 's/=y//g' | sed 's/CONFIG_//g' | while read line; 
do 
	echo "./scripts/config --disable "$line""
	./scripts/config --disable "$line"
done

##COMMENT_1
#COMMENT_3

<<'COMMENT'
diff -i <(sort "$config_file" | grep '=m') <(sort "$other_config_file" | grep '=m') | grep '> CONFIG_' | awk '{print $2}' | sed 's/=m//g' | sed 's/CONFIG_//g' |  while read line; 
do 
	echo "./scripts/config --module "$line""
	./scripts/config --module "$line"
done
#COMMENT

# Disable Config Only included in .config
diff -i <(sort "$config_file" | grep '=m') <(sort "$other_config_file" | grep '=m') | grep '< CONFIG_' | awk '{print $2}' | sed 's/=m//g' | sed 's/CONFIG_//g' | while read line; 
do 
	echo "./scripts/config --disable "$line""
	./scripts/config --disable "$line"
done
#COMMENT_4
COMMENT
#<<'COMMENT'
# Getting CONFIG to Disable From Tailoring Original Config File by localmodconfig
diff -i <(sort "$config_file" | grep 'not set') <(sort "$other_config_file" | grep 'not set') | grep '> # CONFIG_' | awk '{print $3}' | sed 's/is not set//g' | sed 's/CONFIG_//g'  | while read line; 
do 
	echo "./scripts/config --disable "$line""
	./scripts/config --disable "$line"
done

# Enable Config Only include in .config
<<'COMMENT'
diff -i <(sort "$config_file" | grep 'not set') <(sort "$other_config_file" | grep 'not set') | grep '< # CONFIG_' | awk '{print $3}' | sed 's/is not set//g' | sed 's/CONFIG_//g' | while read line; 
do 
	echo "./scripts/config --enable "$line""
	./scripts/config --enable "$line"
done
COMMENT

# Enable Configurations for Initrd
echo "./scripts/config --enable BLK_DEV_INITRD"
./scripts/config --enable BLK_DEV_INITRD
#echo "./scripts/config --enable INITRAMFS_SOURCE"
./scripts/config --enable INITRAMFS_SOURCE
#echo "echo \"CONFIG_INITRAMFS_SOURCE=\"\" >> .config"
#echo "CONFIG_INITRAMFS_SOURCE=\"\"" >> .config

# Etc
#echo "./scripts/config --disable DEBUG_INFO"
#./scripts/config --disable DEBUG_INFO
#./scripts/config --disable FTRACE

#<<'COMMENT'
# Enable Configuration by Keyword (like SCSI, USB...)
diff -i <(sort "$config_file") <(sort "$other_config_file") | grep '> CONFIG_' | sed 's/> CONFIG_//g' | grep -v "$keywords" | while read line;
do
	temp=$(echo $line | cut -d'=' -f1)
	if echo "$line" | grep -q '=y';
	then
		echo "./scripts/config --enable "$temp""
		./scripts/config --enable "$temp"
	elif echo "$line" | grep -q '=m';
	then
		echo "./scripts/config --module "$temp""
		./scripts/config --module "$temp"
	else
		echo "./scripts/config --disable "$temp""
		./scripts/config --disable "$temp"
	fi
done
#COMMENT

# Disable Configuration Manually
sort "$config_file" | grep '=y' | sed 's/=y//g' | sed 's/CONFIG_//g' | while read line; 
do 
	if echo "$line" | grep -q "$config_filter";
	then
		echo "./scripts/config --disable "$line""
		./scripts/config --disable "$line"
	fi
done


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

make deb-pkg -j112


