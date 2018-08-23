#!/bin/bash

for i in $(seq 5);
do
	echo "$i"
done

# Tester_1:0
# Tester_2:1
# Tester_3:0
# Tester_4:1
# Tester_5:0

if [ $(grep "Tester_1" "./test.dat" | cut -d':' -f2) != "1" ]; then
	echo "VM is Idle"
fi

if [ $(grep "Tester_2" "./test.dat" | cut -d':' -f2) != "1" ]; then
	echo "VM is Idle"
fi

if [ $(grep "Tester_3" "./test.dat" | cut -d':' -f2) != "1" ]; then
	echo "VM is Idle"
fi

if [ $(grep "Tester_4" "./test.dat" | cut -d':' -f2) != "1" ]; then
	echo "VM is Idle"
fi

if [ $(grep "Tester_5" "./test.dat" | cut -d':' -f2) != "1" ]; then
	echo "VM is Idle"
fi

echo "123" > ./asdf.dat
temp=$(cat ./asdf.dat)
echo "File Lengh : ${#temp}"
if [ ${#temp} -eq 0 ];
then
	echo "File is empty!!"
fi

