#/bin/bash

# Getting byte size of argv(1)
du -bs "$1"

# Number of files of argv(1)
find "$1" -type f | wc -l
