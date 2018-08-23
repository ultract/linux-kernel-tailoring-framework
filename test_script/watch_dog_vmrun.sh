#!/bin/bash

watch_dog_vmrun(){
	duration=$SECONDS
        while true; do
                sleep 5
                ps -eo pid,comm,lstart,etime | grep "vmrun" | while read line;
                do
                	pid=$(echo "$line" | awk '{print $1}')
                	etime=$(echo "$line" | awk '{print $8}' | awk -F: '{print ($1 * 60) + $2}')
			if [ "$etime" -gt "30" ]
			then
				kill -9 "$pid"
			fi
                done
		timeout=$((SECONDS-duration))
		if [ "$timeout" -gt "30" ]
		then
			return
		fi
        done
}

watch_dog_vmrun 
