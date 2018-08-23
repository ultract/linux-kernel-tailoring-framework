#!/bin/bash

check_vmware=$(ps aux | grep "/usr/lib/vmware/bin/vmware$")
#if [ ! -z "$check_vmware" ];
if [ -z "$check_vmware" ];
then
	#echo $check_vmware
	/usr/lib/vmware/bin/vmware &
fi

