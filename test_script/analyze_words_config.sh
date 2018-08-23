#!/bin/bash
config=".config"
another_config="org_localmodconfig"
filter="KVM\|XEN\|CHROME\|APPARMOR\|TOMOYO\|SMACK\|DEBUG\|TEST\|TRACE\|_DUMP\|MACINTOSH"
diff -i <(sort "$config" | grep '=y') <(sort "$another_config" | grep '=y') | grep '> CONFIG_' | grep -v "$filter" | cut -d"_" -f2 | sed 's/=[ym]//g' | uniq -c| sort -r
