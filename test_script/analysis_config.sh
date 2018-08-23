#!/bin/bash

echo -n "Groups of Config : "
grep -v "^# CONFIG" "$1" | grep "# " | sort | wc -l

echo -n "Enable Config : "
grep '=y' "$1" | sort | wc -l

echo -n "Module Config : "
grep '=m' "$1" | sort | wc -l

echo -n "Disable Config : "
grep 'not set' "$1" | sort | wc -l
