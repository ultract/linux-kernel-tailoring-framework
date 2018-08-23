Recording Use Case by xnee

# Install xnee Package
$ sudo apt-get install xnee
 
# Record Keyboard & Mouse Event
$ cnee --record --keyboard --mouse --time 5 -o ./event1.xnr # --verbose
 
# Replay it!
# --force-core-replay: VMware에서 TouchPad로 생기는 문제 해결?
# --no-synchronise: Synchronise Error로 종료되는 것 방지
$ cnee --replay --no-synchronise --force-core-replay -f ./event1.xnr # --verbose

