#!/bin/bash

sudo lsof /var/lib/apt/lists/lock 2>/dev/null | awk '{print $2}' | grep "^[0-9]\+" | while read line;
do
	sudo kill -9 $line
done

sudo lsof /var/lib/dpkg/lock 2>/dev/null | awk '{print $2}' | grep "^[0-9]\+" | while read line;
do
	sudo kill -9 $line
done
