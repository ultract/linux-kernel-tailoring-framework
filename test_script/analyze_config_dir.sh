#!/bin/bash

ram_disk_dir="/mnt/RAM_disk"

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

tmp="$(analyze_config_dir ".config")"
tmp2="$(analyze_config_dir "original_localmodconfig")"


echo -e "Distribution of .config\n $tmp"
echo -e "Distribution of original_localmodconfig\n $tmp2"


