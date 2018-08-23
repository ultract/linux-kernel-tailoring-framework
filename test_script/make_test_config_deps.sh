#!/bin/bash


test_config_group_list="test_config_group.txt"
test_config_list="$(cat ./"$test_config_group_list")"


# Make a Dependency List of Each Configuration Depending on Original Localmodconfig
echo "Make a Dependency List of Each Configuration"
while read line;
do
	# Find out a Dependency of a Configuration & Remove a Name of Configuration
	config_deps=$(grep "^$line " ./models/x86.model | sed "s/^$line //g")
	if [ -n "$config_deps" ];
	then
		#echo "$config_deps"
		# Make a Dependency List
		list_config_deps="$list_config_deps$config_deps\n"
	fi
done <<< "$(cat ./original_localmodconfig | grep "^CONFIG_" | awk -F'=' '{print $1}')"

#echo -e "$list_config_deps"

# Count The Number of Dependencies
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

echo -e "$list_config_deps_num" | sort -n
#echo -e "$list_config_deps_num" | sort -n | tail -n +2 | sort -R | sort -s -n -k 1,1 | awk '{print $2}'
#echo -e "$list_config_deps_num" | sort -R | sort -s -n -k 1,1 | awk '{print $2}'



