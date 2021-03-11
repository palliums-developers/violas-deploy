#!/bin/bash
#下载violas并编译
sudo apt-get install git
sudo apt-get update
sudo pip3 install psutil

IP=52.151.2.66
Full_nodes_IP=127.0.0.1

#根据输入的ip地址下载对应的节点配置文件
read  -p "Please enter the IP address:" node_ip

cd $HOME
if [ ! -d "violascfg" ]; then
	mkdir -p violascfg && cd violascfg
else
	rm -rf $HOME/violascfg
	mkdir -p violascfg && cd violascfg
fi
curl -O -s http://$IP/$node_ip.tar.gz
tar -zxf $node_ip.tar.gz

script_path=`echo $(pwd)`
cd $script_path
full_nodes_array=(${Full_nodes_IP//,/ })
for ip_full_node in ${full_nodes_array[@]}
do
	if
		[ "$ip_full_node" == "$node_ip" ]
		curl -O -s http://$IP/start.sh && sudo chmod 775 start.sh
		sed -i "2s|cd.*|cd \$script_path/full_nodes/|g" $HOME/violascfg/start.sh
	else
		curl -O -s http://$IP/start.sh && sudo chmod 775 start.sh
	fi
done

curl -O -s http://$IP/stop.sh && sudo chmod 775 stop.sh
curl -O -s http://$IP/clean_db_start.sh && sudo chmod 775 clean_db_start.sh
curl -O -s http://$IP/diem-node && sudo chmod 775 diem-node
curl -O -s http://$IP/cli && sudo chmod 775 cli
curl -O -s http://$IP/cli.sh && sudo chmod 775 cli.sh
curl -O -s http://$IP/violas_chain_monitor.py && sudo chmod 775 violas_chain_monitor.py
sh start.sh

logfile="$script_path/violas.log"
ps -fe|grep diem-node |grep -v grep
if [ $? -ne 0 ]
	then
	echo "`cat $logfile | tail -n 100`"
else
	echo "*************************************************"
	echo "VIOLAS SUCCESS START"
	echo "*************************************************"
fi
