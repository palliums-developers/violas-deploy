#!/bin/bash
sudo pip3 install psutil

IP=52.151.2.66
Full_nodes_IP=127.0.0.1

#根据输入的ip地址下载对应的节点配置文件
read  -p "Please enter the Validator IP address:" node_ip

cur_path=`echo $(pwd)`
script_path=$cur_path/violascfg
logfile="$script_path/violas.log"

cd $cur_path
if [ -d "violascfg" ]; then
	rm -rf violascfg	
fi
mkdir -p violascfg && cd violascfg
curl -O -s http://$IP/$node_ip.tar.gz
tar -zxf $node_ip.tar.gz

full_nodes_array=(${Full_nodes_IP//,/ })
for ip_full_node in ${full_nodes_array[@]}
do
	if
		[ "$ip_full_node" == "$node_ip" ]
		curl -O -s http://$IP/start.sh && sudo chmod 775 start.sh
		sed -i "2s|cd.*|cd \$script_path/full_nodes/|g" $script_path/start.sh
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
curl -O -s http://$IP/waypoint.txt
sh start.sh

ps -fe|grep diem-node |grep -v grep
if [ $? -ne 0 ]
	then
	echo "`cat $logfile | tail -n 100`"
else
	echo "*************************************************"
	echo "VIOLAS SUCCESS START"
	echo "*************************************************"
fi
