# Linux Kernel Tailoring Framework

### Supports For Three Linux Ditros below
- Gooroom 1.0 Beta 64bit
- Debian 9.x Stretch 64bit
- Ubuntu 18.04 Bionic Beaver 64bit

### Test Environment
|  | |
| ------ | ------ |
| H/W | HP Z840, Intel Xeon E5-2697 RAM 256GB, SSD 1TB, 1Gbps Ethernet|
| Host OS | Ubuntu 16.04 Desktop 64bit |
| Virtual Machine | VMware Workstation 14, 4 Core CPU, 4GB RAM, 16GB HDD, 1440X900|
| Language | Bash Script |
| Etc | undertaker-tailor 1.6.1, cnee 3.19 |

### Procedure of Kernel Tailoring
#### 1. Host Machine
- Create Ram Disk
    * 128 GB(For 8 VMs and Kernel Compile)
	* http://www.hecticgeek.com/2015/12/create-ram-disk-ubuntu-linux/
- Install Packages For the Kernel Build
- Install VMware Workstation 14
- Set an Email Address($email_addr in commands-in-host.sh) to Get Results about the Kernel Tailoring

#### 2. Trace VM 
- Path of VMX File : (Change $vmx_guest_a in commands-in-host.sh)
- Snapshot Name : (Change $snapshot_vm_a in commands-in-host.sh)
- Login ID/Password : (Change $guser, $gpw in commands-in-host.sh)
- Check Each README.md

#### 3. Verification VM
- Path of VMX File : /mnt/RAM_disk/vmware/Tester_1.vmx, Tester_2.vmx ..
- Snapshot Name : (Change $snapshot_vm_b in commands-in-host.sh)
- Login ID/Password : (Change $guser, $gpw in commands-in-host.sh)
- Check Each README.md

### Usage
##### 1. Copy VM Images to a RAM Disk Path
##### 2. Execute a VMware Workstation
##### 3. Execute a Host Script File
```sh
$ ./commands-in-host.sh 8(Number of VM)
```

### Reference
* Presentation Slide #1: A Practical Approach of Tailoring Linux Kernel (<http://sched.co/BCsG>)
* Demo Video #1 : <https://www.youtube.com/watch?v=fnnCn-Bxjnw&t=1s>
* Presentation Slide #2: An Empirical Study of an Advanced Kernel Tailoring Framework (<http://sched.co/FAN5>)
* Demo Video #2 : <https://www.youtube.com/watch?v=fHceA4asiXU&t=126s>
* <https://vamos.informatik.uni-erlangen.de/trac/undertaker/wiki/UndertakerTailor>


### License
Apache License 2.0

### Acknowledgments
The Kernel Tailoring Framework has been developed to reduce an attack surface of the linux kernel of Gooroom platform which is an open source project. This work was supported by Institute for Information & communications Technology Promotion (IITP) grant funded by the Korea government (MSIP) (No.R0236-15-1006, Open Source Software Promotion).

