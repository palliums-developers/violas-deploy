#!/bin/bash
#下载violas并编译
sudo apt-get install git
sudo apt-get update
sudo apt-get install -y build-essential
sudo pip3 install psutil

script_path=`echo $(pwd)`
violas_path=$(dirname $script_path)/violas
deploy_path=$(dirname $script_path)/deploy_node

read  -p "Please enter the violas tag:" tag
cd $(dirname $script_path)
if [ ! -d "violas" ];then
	git clone https://github.com/palliums-developers/Violas violas
	cd violas && git checkout $tag && ./scripts/dev_setup.sh
else	
	cd violas && git checkout violas && git pull origin violas:violas && git checkout $tag && ./scripts/dev_setup.sh
fi
source $HOME/.cargo/env
cargo build --release --all 

while true
do
	read  -p $'MAINNET = 1\x0aTESTNET = 2\x0aDEVNET = 3\x0aTESTING = 4\x0aPREMAINNET = 5\x0aPlease enter chainid :' chainid
	# if [[ $num =~ ^[1-5]+$ ]]; then
	# 	break
	if [ $chainid -eq 1 ]; then
		echo "Chainid not used yet,please re-enter:"
	elif [ $chainid -eq 2 ]; then
		break
	elif [ $chainid -eq 3 ]; then
		echo "Chainid not used yet,please re-enter:"
	elif [ $chainid -eq 4 ]; then
		break
	elif [ $chainid -eq 5 ]; then
		break
	else
		echo "Chainid input error,please re-enter:"
	fi
done

read  -p "Please enter the number of validators nodes:" num_validator
if [ $num_validator -eq 1 ]; then
	read  -p "Please enter validator IP:" validators_ip
	master_node_ip=$validators_ip
else
	read  -p "Please enter the master node IP:" master_node_ip
	read  -p "Please enter all validators IP,separated by \",\":" validators_ip
fi
read  -p "Please enter the number of full nodes,If not filled in 0:" num_full_nodes

if [ $num_full_nodes -ne 0 ]; then
	read  -p "Please enter all full nodes IP,separated by \",\":" full_nodes_ip
fi

cd $violas_path/target/release/
strip diem-node cli
if [  -f "genesis.yaml" ]; then
	rm genesis.yaml
fi
touch genesis.yaml
echo "---" >> genesis.yaml
echo "chain_id: $chainid" >> genesis.yaml
echo "validators:" >> genesis.yaml

# 根据输入验证节点IP生成validators.conf
validators_array=(${validators_ip//,/ })
for ip in ${validators_array[@]}
do
	echo " - /ip4/$ip/tcp/40002" >> genesis.yaml
done

# cd  $(dirname $script_path)
# if [ -d "violascfg" ]; then
# 	while true
# 	do
# 		read -r -p "violascfg already exist, Are You Sure Delete? [Y/n] " input
# 		case $input in
# 		    [yY][eE][sS]|[yY])
# 				rm -rf violascfg
# 				break
# 				;;
	
# 		    [nN][oO]|[nN])
# 				echo "Exit compilation, please delete config file manually"
# 				exit 1	       	
# 				;;
	
# 		    *)
# 				echo "Invalid input..."
# 				;;
# 		esac
# 	done
# fi

# 根据输入的num_full_nodes判断生成验证节点或全节点配置文件，num_full_nodes为0时只生成验证节点配置文件
if [ $num_full_nodes -eq 0 ]; then
	nohup ./diem-swarm -c $script_path/config --diem-node ./diem-node -n $num_validator >$script_path/swarm.log 2>&1 &
	sleep 10
else
	nohup ./diem-swarm -c $script_path/config --diem-node ./diem-node -n $num_validator -f $num_full_nodes >$script_path/swarm.log 2>&1 &
	sleep 10
fi
sh $script_path/stop.sh

#将配置文件以及脚本打包至下载路径
cd $(dirname $script_path)
if [ -d "deploy_node" ]; then
	rm -rf deploy_node
fi
mkdir -p deploy_node && cd deploy_node
cp $script_path/deploy_node.sh .
cp $script_path/clean_db_start.sh .
cp $script_path/start.sh .
cp $script_path/stop.sh .
cp $script_path/cli.sh .
cp -R $script_path/full_node .
cp $script_path/config/full_nodes/0/genesis.blob full_node
cp $script_path/violas_chain_monitor.py .
cp $violas_path/target/release/diem-node .
cp $violas_path/target/release/cli .
touch waypoint.txt
sed -i "s|IP=.*|IP=$master_node_ip|g" $deploy_path/deploy_node.sh
sed -i "s|IP=.*|IP=$master_node_ip|g" $deploy_path/full_node/deploy_full_node.sh
sed -i "s|Full_nodes_IP=.*|Full_nodes_IP=$full_nodes_ip|g" $deploy_path/deploy_node.sh


# 修改validator节点配置文件端口并打包
cd $script_path/config
i=1
for ip_validator_node in ${validators_array[@]}
do
	j=`expr $i - 1`
	sed -i "89s|level:.*|level: ERROR|g" $script_path/config/$j/node.yaml
	sed -i "108s|address:.*|address: \"0.0.0.0:50001\"|g" $script_path/config/$j/node.yaml
	sed -i "72s|listen_address:.*|listen_address: /ip4/0.0.0.0/tcp/40013|g" $script_path/config/$j/node.yaml
	tar -zcf $deploy_path/$ip_validator_node.tar.gz  $j/* *$j*
	let i++
done

# 修改full_nodes节点配置文件端口并打包
if [ $num_full_nodes -ne 0 ]; then
	i=1
	full_nodes_array=(${full_nodes_ip//,/ })
	for ip_full_node in ${full_nodes_array[@]}
	do
		j=`expr $i - 1`
		sed -i "99s|-.*ln-noise-ik|- /ip4/${validators_array[j]}/tcp/40013/ln-noise-ik|g" $script_path/config/full_nodes/$j/node.yaml
		sed -i "154s|address:.*|address: \"0.0.0.0:50001\"|g" $script_path/config/full_nodes/$j/node.yaml
		sed -i "135s|level:.*|level: ERROR|g" $script_path/config/full_nodes/$j/node.yaml
		tar -zcf $deploy_path/$ip_full_node.tar.gz  full_nodes/$j/* safety-rules_$j* full_node_$j*
		let i++
	done
fi

if [  -f "0/node.yaml" ]; then
	echo "********************************************************"
	echo "Config file was created successfully"
	echo "path:$script_path/config/"
	echo "Please run the following command on the deployment server:"
	echo "curl -O http://$master_node_ip/deploy_node.sh && chmod 775 deploy_node.sh"
	echo "curl -O http://$master_node_ip/full_node/deploy_full_node.sh && chmod 775 deploy_full_node.sh"
	echo "********************************************************"
else
	echo "********************************************************"
	echo "Config created failed,Please run again build_config.sh"
	echo "********************************************************"
fi