#!/bin/bash

file_name="/etc/passwd"

if [ -s "$file_name" ]
then
	echo "File Exist And Not Empty!!"
fi
