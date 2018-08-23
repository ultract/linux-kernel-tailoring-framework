#!/bin/bash

whitelist=""
whitelist="^MTRR\|^NUMA\|^NUMA_BALANCING\|^NET_NS\|^SCHED_AUTOGROUP\|^NET_SCHED\|^BLK_DEV\|^SCHED_SMT\|^SCHED_MC\|^SCHED_HRTICK\|^HUGETLB_PAGE\|^HUGETLBFS\|^CGROUP_HUGETLB\|^SYSVIPC\|^SYSVIPC_SYSCTL\|^SYSVIPC_COMPAT\|^COMPAT_BINFMT_ELF"
whitelist=$whitelist"\|^DETECT_HUNG_TASK\|^SCHED_DEBUG\|^NUMA_BALANCING\|^SCHED_AUTOGROUP\|^BPF_SYSCALL"                                                                                                 
whitelist=$whitelist"\|^LOCKUP_DETECTOR\|^IA32_EMULATION\|^USER_NS\|^CHECKPOINT_RESTORE\|^PERSISTENT_KEYRINGS"
whitelist=$whitelist"\|^MEMORY_FAILURE\|^MAGIC_SYSRQ\|^CFS_BANDWIDTH\|^NET_NS\|^POSIX_MQUEUE"
whitelist=$whitelist"\|^X86_MCE\|^EFIVAR_FS\|^STACK_TRACER\|^PID_NS\|^KPROBES"
whitelist=$whitelist"\|^COMPACTION\|^KEXEC\|^COREDUMP\|^DNOTIFY\|^SYSVIPC\|^DMADEVICES"


echo "$whitelist" | sed 's/[\^\|]\+/\n/g' | while read line;
do
	echo -n "$line" && grep -n "CONFIG_$line=" "$1"
done

ram_disk_dir="/mnt/RAM_disk"
undertaker_models_file="$(find "$ram_disk_dir" -maxdepth 1 -type d -name "linux*" 2>/dev/null)/models/x86.rsf"
echo "$whitelist" | sed 's/[\^\|]\+/\n/g' | while read line; 
do                                                                                               
	grep "^Definition"$'\t'"$line"$'\t' "$undertaker_models_file" | awk '{print $3}' | sed 's/"//g' | awk -F"/" '{print $1}'
done | sort | uniq -c


