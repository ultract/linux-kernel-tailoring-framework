#!/bin/bash

create_lock_or_wait () {
	path="$1"
	wait_time="${2:-10}"
	while true; do
		if mkdir "${path}.lock.d" 2>/dev/null; then
			break;
		fi
	#sleep $wait_time
	done
}

remove_lock () {
	path="$1"
	rmdir "${path}.lock.d"
}

test_func()
{
	create_lock_or_wait "/tmp/"

	test_var=$(cat /tmp/test_var.dat)
	if [ ${#test_var} -eq 0 ]
	then
		echo "^$1\|" > /tmp/test_var.dat
	else
		test_var="$(cat /tmp/test_var.dat)\|^$1"
		echo "$test_var" > /tmp/test_var.dat
	fi
	#sleep 1
	exit_var=$(cat /tmp/exit_var.dat)
	exit_var=$((exit_var-1))
	echo "$exit_var : $1"
	echo "$exit_var" > /tmp/exit_var.dat

	remove_lock "/tmp/"
}

echo "" > /tmp/test_var.dat
echo "5" > /tmp/exit_var.dat

test_func AAA &
test_func 111 &
test_func QWE &
test_func 333 &
test_func PPP &

while true;
do
	exit_var=$(cat /tmp/exit_var.dat)
	if [ "$exit_var" == "0" ]
	then
		test_var=$(cat /tmp/test_var.dat)
		echo "$test_var"
		break
	fi
	#sleep 1
done
