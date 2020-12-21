#!/bin/bash
cd $HOME/violas && git pull
# source $HOME/.cargo/env
# cargo build --release --all 
sudo rm $HOME/violascfg/nohup.out
sudo killall diem-node
sleep 5
ps -fe|grep diem-node |grep -v grep
if [ $? -ne 0 ]
	then
	cat $HOME/violascfg/nohup.out
else
	echo "*************************************************"
	echo "VIOLAS SUCCESS START"
	echo "*************************************************"
fi