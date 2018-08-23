#!/bin/bash

kernel_ver=$(uname -r)
#major_ver=${kernel_ver:0:1}
if [ "${kernel_ver:0:1}" -eq "4" ]      # Major Version Of Kernel
then
        ver_url="v4.x"
else
        ver_url="v3.x"
fi

kernel_ver=${kernel_ver:0:5}
if [ "${kernel_ver:4:1}" -eq "0" ]
then
        kernel_file="linux-${kernel_ver:0:3}.tar.gz"
else
        kernel_file="linux-$kernel_ver.tar.gz"
fi

wget -O ~/$kernel_file https://www.kernel.org/pub/linux/kernel/$ver_url/$kernel_file
tar xvfz ~/$kernel_file -C ~/
cd ~/linux-*
pwd

