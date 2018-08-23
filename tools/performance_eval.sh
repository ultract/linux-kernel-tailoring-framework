#!/bin/bash
#
# - Run This Script After Install Essential Packages 
#   for Building Test Tools of Phoronix
# - Change File Name to use-case.sh in Test Machine
# - Recommend to Run phoronix-test-suite Manually at First

# Debug Mode
#set -x

change_boot_seq(){
	sudo grub-set-default $1
	sudo update-grub
	sudo /sbin/reboot
	sleep 5
	exit
}

watch_dog_lmbench(){
	while true;do
		if killall vi 2>/dev/null ; then     # Kill vi for Filling System Info of Lmbench
			echo "vi Killed"
			break
		fi
		sleep 5
	done
}

test_state_file="performance_test_state.txt"

#sudo awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg 

# Change to Home Directory
PWD="/home/ultract2/"

if [ ! -s "./$test_state_file" ];
then
	# Set Grub Configuration
	sudo sed -i -E "s/^GRUB_DEFAULT=0/GRUB_DEFAULT=saved/g" /etc/default/grub
	sudo /bin/bash -c "echo "GRUB_DISABLE_SUBMENU=y" >> /etc/default/grub"
    echo "2.0" > ~/$test_state_file      # Write Start State
	cp ~/"$test_state_file" /tmp/
	change_boot_seq 0	# Select First Entry
fi

usecase_state=$(cat ~/$test_state_file)

if [ "$usecase_state" == "2.0" ];
then
	# Analyze Kernel Image
	# Analyze Kernel Modules
	#find "/lib/modules/$(uname -r)" -type f -name *.ko 2>/dev/null | wc -l > ~/module_info.txt
	#du -sh "/lib/modules/$(uname -r)" >> ~/module_info.txt

	echo -e "2\n26\nY\nTailored\n11\n" | ~/phoronix-test-suite/phoronix-test-suite interactive
	#echo -e "Y\nTailored\n11\n" | ~/phoronix-test-suite/phoronix-test-suite run linux-system
    echo "2.1" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	change_boot_seq 2	# Select Third Entry

elif [ "$usecase_state" == "2.1" ];
then
	echo -e "2\n26\nY\nOriginal\n11\n" | ~/phoronix-test-suite/phoronix-test-suite interactive
	#echo -e "Y\nOriginal\n11\n" | ~/phoronix-test-suite/phoronix-test-suite run linux-system
	# Merge Phoronix Test Results 
	echo -e "Y\n\n" | ~/phoronix-test-suite/phoronix-test-suite merge-results tailored original
	sleep 5
	echo "2.2" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	change_boot_seq 0

elif [ "$usecase_state" == "2.2" ];
then
	cd ~/lmbench-3.0-a9/
	watch_dog_lmbench &
	echo -e "\n\n\n\n\n" | make results && make rerun && make rerun && make rerun
	echo "2.3" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	change_boot_seq 2

elif [ "$usecase_state" == "2.3" ];
then
	cd ~/lmbench-3.0-a9/
	#watch_dog_lmbench &
	echo -e "\n\n\n\n\n" | make results && make rerun && make rerun && make rerun
	make see
	echo "2.4" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	change_boot_seq 0

elif [ "$usecase_state" == "2.4" ];
then
	# Archieve Performace Test Results
	cd ~/ && mkdir ./performance_result && cd ./performance_result && mkdir ./phoronix_test_suite && mkdir ./lmbench
	cp -r ~/.phoronix-test-suite/test-results/* ./phoronix_test_suite/
	cp -r ~/lmbench-3.0-a9/results/* ./lmbench/
	cd ~/ && tar cvfz "$(date '+%y%m%d')"-performance_result.tar.gz ./performance_result/
	echo "2.5" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
fi


sleep 30
