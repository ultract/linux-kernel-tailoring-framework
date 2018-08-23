#!/bin/bash

#set -x

test_config_list=$(cat ./test_config_group.txt)

while read line;
do
	#echo "$line"
	#hasprompts=$(grep 'HasPrompts'$'\t'"$line" ./models/x86.rsf | cut -d$'\t' -f3)
	hasprompts=$(grep '^HasPrompts'$'\t'"$line"$'\t' ./models/x86.rsf | head -n 1 | awk '{print $3}')
	if [ "$hasprompts" == "1" ];
	then
		#echo "$line"
		config_list="$config_list\n$line"
		#echo -e "$config_list"
	fi
done <<< "$(echo "$test_config_list")"

final_config_list=$(echo -e "$config_list" | tail -n +2)
echo "$final_config_list"
