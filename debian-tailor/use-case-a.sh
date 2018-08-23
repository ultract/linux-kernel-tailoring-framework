#!/bin/bash

vm_a_state_file="VM-A-State.dat"
auto_event_file="cnee_events.tar.gz"
default_event="default_event.xnr"
browser_event="browser_event.xnr"
benchmark_event="benchmark_event.xnr"

usecase_state_file="Usecase-State.dat"

browser_name=""

watchdog() {
	# Wait 5 Minutes
	sleep 300
	
	# Kill processes of ARGV[1]
	sudo killall "$1"
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
# Check Usecase State
#
if [ ! -s ~/"$usecase_state_file" ]
then
	echo "2.0" > ~/$usecase_state_file	# Write Start State
	
	# Write UseCase State
	echo "2" > /tmp/$vm_a_state_file

	# Install Xnee & Extract Event Files
	sudo apt-get install xnee -y
	tar xvfz $auto_event_file
fi

usecase_state=$(cat ~/$usecase_state_file)

#
# Viewing undertaker-trace.out
#
sudo /usr/bin/gnome-terminal --geometry 10x20 -x /usr/bin/tail -f /run/undertaker-trace.out &

if [ "$usecase_state" == "2.0" ]
then
	# #-0 No Cnee Replay Test
	# GtkPerf
	sudo apt-get install gtkperf -y && /usr/bin/gtkperf -a
	echo "2.1" > ~/$usecase_state_file	# Write Next Usecase State
	sudo /etc/init.d/lightdm restart

elif [ "$usecase_state" == "2.1" ]
then
	# #-1 Default Test - Default Application, Control Panel, Etc...
	# Replay Default Event
	cnee --replay --no-synchronise --force-core-replay -f ./$default_event
	echo "2.2" > ~/$usecase_state_file	# Write Next Usecase State
	sudo /etc/init.d/lightdm restart

elif [ "$usecase_state" == "2.2" ]
then
	# #-2 Browser Test
	#/usr/bin/epiphany https://html5test.com/ &
	#/usr/bin/epiphany http://peacekeeper.futuremark.com/ &
	#/usr/bin/epiphany http://web.basemark.com/ &
	#/usr/bin/epiphany https://webkit.org/perf/sunspider/sunspider.html &
	#/usr/bin/epiphany http://browserbench.org/ &

	# Replay Browser Event
	cnee --replay --no-synchronise --force-core-replay -f ./$browser_event
	echo "2.3" > ~/$usecase_state_file	# Write Next Usecase State
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
#cd ~/lmbench-3.0-a9/
#echo -ne '\n\n\n\n\n\n\n\n\n\nno\nnone\n' | make results
#cd ~/
	# Replay Benchmark Event
	#cnee --replay --no-synchronise --force-core-replay -f ./$benchmark_event

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

	# Etc Test
	# For Identifying Fuctions of Proc & Sys FileSystem"
	watchdog "grep" &
	sudo sysctl -a
	sudo grep -rn "asdf" /proc/ 2> /dev/null
	sudo grep -rn "asdf" /sys/ 2> /dev/null

	#wget https://cisofy.com/files/lynis-2.4.0.tar.gz
	#tar xvfz lynis-2.4.0.tar.gz
	#sudo chown -R 0:0 lynis
	git clone https://github.com/CISOfy/lynis
	cd lynis/
	echo -e "\n\n" | sudo ./lynis audit system

	cd ~/
	git clone https://github.com/lateralblast/lunar
	cd lunar
	sudo apt-get install sysv-rc-conf -y
	sudo apt-get install bc -y
    	sudo apt-get install finger -y
	#sudo /bin/bash lunar.sh -a -v | grep "warning"
	sudo /bin/bash lunar.sh -A | grep "warning"
	
	# Trace Kernel Memory Address Manually
	#exit

	echo "2.9" > ~/$usecase_state_file	# Write Next Usecase State
	sudo /etc/init.d/lightdm restart

fi

# Kernel Tailoring For Getting .config File
/usr/bin/gnome-terminal -x ~/kernel-tailoring.sh
