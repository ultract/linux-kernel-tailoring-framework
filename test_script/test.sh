#!/bin/bash

<<'COMMENT'
temp="123"
test_config="123"

if [ -n "$test_config" ]
then
	if [ -z "$temp" ]
	then
		echo "Test Config Removed!"
	else
		echo "Test Config Not Removed!"
	fi
fi

COMMENT

<<'COMMENT'
send_email()
{
        # Write Contents
        contents="To: ultractgm@gmail.com\r\n"
        contents="${contents}From: ultractgm@gmail.com\r\n"
        contents="${contents}Subject: Kernel Tailoring Message\r\n"
        contents="${contents}$1\r\n"

        # Send Contents
        echo -e "$contents" | ssmtp ultractgm@gmail.com
}

send_email "test"

COMMENT
<<'COMMENT'

watch_dog(){
	while true;
	do
		sleep 2
		kill -9 $(jobs -p)
	done
}

asdf(){
	#watch_dog &
	exit_code=$(vmrun -gu ultract2 -gp ultract2 runProgramInGuest /mnt/RAM_disk/vmware/Tester_6/Tester_6.vmx "/usr/bin/env" "DISPLAY=:0" "/usr/bin/xfce4-terminal" "-x")
}

asdf &
COMMENT

<<'COMMENT'
num_of_conf=745
half_num_of_conf=$((num_of_conf/2))
quater_num_of_conf=$((num_of_conf/4))

echo "$num_of_conf"
echo "$half_num_of_conf"
echo "$quater_num_of_conf"

num_of_conf=372
while true;
	do
		if [ "$num_of_conf" -le "$half_num_of_conf" ] && [ "$num_of_conf" -ge "$((half_num_of_conf-10))" ]
		then
			echo "Half"
		fi
	num_of_conf=$((num_of_conf-1))
	sleep 1
done


#echo "$num_of_conf"
#echo "$half_num_of_conf"
#echo "$quater_num_of_conf"
COMMENT

<<'COMMENT'
func(){
	duration=$SECONDS
	timetolive=180
	while true; do
		sleep 2
		echo "$duration"
		echo "$timetolive"
	done
}


func &
sleep 5
duration=1
timetolive=2
echo "$duration, $timetolive"
COMMENT

<<'COMMENT'
progress_cnt=0
for i in $(seq 5)
do
	while true;
	do
		if [ "$progress_cnt" -eq 0 ]
		then
			echo "0"
			progress_cnt=$((progress_cnt + 1))
			continue
		elif [ "$progress_cnt" -eq 1 ]
		then
			echo "1"
			progress_cnt=$((progress_cnt + 1))
			continue
		fi
		break
	done
done

echo "$progress_cnt"
COMMENT

<<'COMMENT'
cn=0
for i in $(seq 4)
do
	#if ! ping -c 1 192.168.2.1 >> /dev/null;
	if ping -c 1 192.168.2.1 >> /dev/null;
        then
                cn=$((cn+1))
                #usecase_log "Ping to Gateway(192.168.2.1) Failed"
                #sleep 1
        fi
done

echo "$cn"

if [ "$cn" -ge 5 ];
then
	echo "ASDF"
fi
COMMENT


