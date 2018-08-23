#!/bin/bash
# local
sed 's/\<module [a-zA-Z0-9_]* did not have configs\>//g' ./config.test | sed 's/\ /\n/g' | sort -u | grep "^CONFIG" | sed 's/$/=m/' >> ./.config


