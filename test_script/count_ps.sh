#!/bin/bash

count_ps=$(ps aux | grep "asdfasdfasdf" | wc -l)

echo "$count_ps"
if [ "$count_ps" > "80" ]
then
	echo "many"
else
	echo "few"
fi
