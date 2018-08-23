#!/bin/bash

#set -x

test_config_list=$(cat ./test_config_group.txt)

while read line;
do
	#echo "$line"
	#hasprompts=$(grep 'HasPrompts'$'\t'"$line" ./models/x86.rsf | cut -d$'\t' -f3)
	#hasprompts=$(grep '^HasPrompts'$'\t'"$line"$'\t' ./models/x86.rsf | head -n 1 | awk '{print $3}')
	depth_conf=$(echo "$line" | grep -o '_' | wc -l)
	depth_conf=$((depth_conf+1))
	#echo "$depth_conf    $line"
	depth_conf="$depth_conf\t$line"
	config_list="$config_list\n$depth_conf"
<<'COMMENT'
	if [ "$hasprompts" == "1" ];
	then
		#echo "$line"
		config_list="$config_list\n$line"
		#echo -e "$config_list"
	fi

COMMENT
done <<< "$(echo "$test_config_list")"
final_config_list=$(echo -e "$config_list")
echo "$final_config_list" | sort -r
