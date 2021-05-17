#!/bin/bash
sudo pip3 install psutil
IP=52.151.2.66

cur_path=`echo $(pwd)`
script_path=$cur_path/violascfg
cd $cur_path
if [ -d "violascfg" ]; then
	rm -rf violascfg
fi
mkdir -p violascfg/full_node && cd violascfg

curl -O -s http://$IP/waypoint.txt
curl -O -s http://$IP/start.sh && sudo chmod 775 start.sh
curl -O -s http://$IP/stop.sh && sudo chmod 775 stop.sh
curl -O -s http://$IP/clean_db_start.sh && sudo chmod 775 clean_db_start.sh
curl -O -s http://$IP/diem-node && sudo chmod 775 diem-node
curl -O -s http://$IP/cli && sudo chmod 775 cli
curl -O -s http://$IP/cli.sh && sudo chmod 775 cli.sh
curl -O -s http://$IP/violas_chain_monitor.py && sudo chmod 775 violas_chain_monitor.py

data_dir_str="sed -i \"s|data_dir:.*|data_dir: \$script_path\/full_node|g\" \$data_dir_path\/\$config_file"
from_file_str="sed -i \"s|from_file:.*|from_file: \$script_path\/waypoint.txt|g\" \$data_dir_path\/\$config_file"
genesis_file_location_str="sed -i \"s|genesis_file_location:.*|genesis_file_location: \$script_path\/full_node\/genesis.blob|g\" \$data_dir_path\/\$config_file"
sed -i "7s/.*/$data_dir_str/g" $script_path/start.sh
sed -i "8s/.*/$from_file_str/g" $script_path/start.sh
sed -i "9s/.*/$genesis_file_location_str/g" $script_path/start.sh

cd $script_path/full_node
while true
do
	read  -p $'MAINNET = 1\x0aTESTNET = 2\x0aDEVNET = 3\x0aTESTING = 4\x0aPREMAINNET = 5\x0aPlease enter chainid :' chainid
	if [ $chainid -eq 1 ]; then
		echo "Chainid not used yet,please re-enter:"
	elif [ $chainid -eq 2 ]; then
		curl -O -s http://$IP/full_node/full_node_TESTING.yaml
		sed -i "s|data_dir:.*|data_dir: \"\$script_path/full_node\"|g" $script_path/full_node/full_node_TESTING.yaml
		sed -i "s|from_file:.*|from_file: \"\$script_path/waypoint.txt\"|g" $script_path/full_node/full_node_TESTING.yaml
		sed -i "s|genesis_file_location:.*|genesis_file_location: \"\$script_path/full_node/genesis.blob\"|g" $script_path/full_node/full_node_TESTING.yaml
		sed -i "s|config_file=.*|config_file=\"full_node_TESTING.yaml\"|g" $script_path/start.sh
		break
	elif [ $chainid -eq 3 ]; then
		echo "Chainid not used yet,please re-enter:"
	elif [ $chainid -eq 4 ]; then
		echo "Chainid not used yet,please re-enter:"
	elif [ $chainid -eq 5 ]; then
		curl -O -s http://$IP/full_node/full_node_PREMAINNET.yaml
		sed -i "s|data_dir:.*|data_dir: $script_path/full_node|g" $script_path/full_node/full_node_PREMAINNET.yaml
		sed -i "s|from_file:.*|from_file: $script_path/waypoint.txt|g" $script_path/full_node/full_node_PREMAINNET.yaml
		sed -i "s|genesis_file_location:.*|genesis_file_location: $script_path/full_node/genesis.blob|g" $script_path/full_node/full_node_PREMAINNET.yaml
		sed -i "s|config_file=.*|config_file=\"full_node_PREMAINNET.yaml\"|g" $script_path/start.sh		
		break
	else
		echo "Chainid input error,please re-enter."
	fi
done
curl -O -s http://$IP/full_node/genesis.blob

cd $script_path
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
