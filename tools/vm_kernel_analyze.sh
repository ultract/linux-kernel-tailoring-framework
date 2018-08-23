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

test_state_file="kernel_analyze_state.txt"

analyze_result="analyze_result.txt"

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
	echo "[ Tailored Kernel Image ]" > ~/"$analyze_result"
	sudo chmod 644 /boot/vmlinuz-$(uname -r)
	~/extract-vmlinux /boot/vmlinuz-$(uname -r) > ~/tailored_kernel
	ls -al ~/tailored_kernel >> ~/"$analyze_result"

	echo "[ Tailored Initrd Image ]" >> ~/"$analyze_result"
	ls -al /boot/initrd.img-$(uname -r) >> ~/"$analyze_result"

	# Analyze Kernel Modules
	echo "[ Tailored Kernel Module ]" >> ~/"$analyze_result"
	echo -n "Size : " >> ~/"$analyze_result"
	du -bs "/lib/modules/$(uname -r)" >> ~/"$analyze_result"
	echo -n "# of Modules : " >> ~/"$analyze_result"
	find "/lib/modules/$(uname -r)" -type f -name *.ko 2>/dev/null | wc -l >> ~/"$analyze_result"

	# systemd-analyze(Booting Time)
	# Wait until Booting Up Finished
	echo "[ Tailored Kernel Booting Time ]" >> ~/"$analyze_result"
	sleep 10
	systemd-analyze >> ~/"$analyze_result"

    echo "2.1" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	#sleep 10
	sudo /sbin/reboot
	exit
	#change_boot_seq 2	# Select Third Entry

elif [ "$usecase_state" == "2.1" ];
then
	# systemd-analyze(Booting Time)
	# Wait until Booting Up Finished
	sleep 10
	systemd-analyze >> ~/"$analyze_result"

	echo "2.2" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	#sleep 10
	sudo /sbin/reboot
	exit
	#change_boot_seq 0

elif [ "$usecase_state" == "2.2" ];
then
	# systemd-analyze(Booting Time)
	# Wait until Booting Up Finished
	sleep 10
	systemd-analyze >> ~/"$analyze_result"
	
	echo "2.3" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	#sleep 10
	change_boot_seq 2

elif [ "$usecase_state" == "2.3" ];
then
	# Analyze Kernel Image
	echo -e "\n\n[ Original Kernel Image ]" >> ~/"$analyze_result"
	sudo chmod 644 /boot/vmlinuz-$(uname -r)
	~/extract-vmlinux /boot/vmlinuz-$(uname -r) >> ~/original_kernel
	ls -al ~/original_kernel >> ~/"$analyze_result"

	echo "[ Tailored Initrd Image ]" >> ~/"$analyze_result"
	ls -al /boot/initrd.img-$(uname -r) >> ~/"$analyze_result"

	# Analyze Kernel Modules
	echo "[ Original Kernel Module ]" >> ~/"$analyze_result"
	echo -n "Size : " >> ~/"$analyze_result"
	du -bs "/lib/modules/$(uname -r)" >> ~/"$analyze_result"
	echo -n "# of Modules : " >> ~/"$analyze_result"
	find "/lib/modules/$(uname -r)" -type f -name *.ko 2>/dev/null | wc -l >> ~/"$analyze_result"

	# systemd-analyze(Booting Time)
	echo "[ Original Kernel Booting Time ]" >> ~/"$analyze_result"
	# Wait until Booting Up Finished
	sleep 10
	systemd-analyze >> ~/"$analyze_result"

	echo "2.4" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	#sleep 10
	sudo /sbin/reboot
	exit
	#change_boot_seq 0

elif [ "$usecase_state" == "2.4" ];
then
	# systemd-analyze(Booting Time)
	# Wait until Booting Up Finished
	sleep 10
	systemd-analyze >> ~/"$analyze_result"
	
	echo "2.5" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/
	#sleep 10
	sudo /sbin/reboot
	exit

elif [ "$usecase_state" == "2.5" ];
then
	# systemd-analyze(Booting Time)
	# Wait until Booting Up Finished
	sleep 10
	systemd-analyze >> ~/"$analyze_result"
	echo "2.6" > ~/$test_state_file      # Write Next Usecase State
	cp ~/"$test_state_file" /tmp/

fi

sleep 5
