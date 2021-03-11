#!/bin/bash
#下载violas并编译
sudo apt-get install git
sudo apt-get update
sudo apt-get install -y build-essential
sudo pip3 install psutil

config_dir_path=`echo $(pwd)`
read  -p "Please enter the violas tag:" tag
cd $HOME
if [ ! -d "violas" ];then
	git clone https://github.com/palliums-developers/Violas violas
	cd $HOME/violas && git checkout $tag && ./scripts/dev_setup.sh
else	
	cd $HOME/violas && git checkout violas && git pull origin violas:violas && git checkout $tag && ./scripts/dev_setup.sh
fi
source $HOME/.cargo/env
cargo build --release --all 

read  -p "Please enter chianID:" chain_id
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

sed -i "s|IP=.*|IP=$master_node_ip|g" $config_dir_path/deploy_node.sh
sed -i "s|Full_nodes_IP=.*|Full_nodes_IP=$full_nodes_ip|g" $config_dir_path/deploy_node.sh

cd $HOME/violas/target/release/
strip diem-node
strip cli


#将配置文件以及部署脚本打包
cd $HOME
if [ ! -d "deploy_node" ]; then
	mkdir -p  deploy_node && cd deploy_node
	cp $config_dir_path/deploy_node.sh .
	cp $config_dir_path/clean_db_start.sh .
	cp $config_dir_path/start.sh .
	cp $config_dir_path/stop.sh .
	cp $config_dir_path/cli.sh .
	cp $config_dir_path/violas_chain_monitor.py .
	cp $HOME/violas/target/release/diem-node .
	cp $HOME/violas/target/release/cli .
else
	rm -rf $HOME/deploy_node
	mkdir -p deploy_node && cd deploy_node
	cp $config_dir_path/deploy_node.sh .
	cp $config_dir_path/clean_db_start.sh .
	cp $config_dir_path/start.sh .
	cp $config_dir_path/stop.sh .
	cp $config_dir_path/cli.sh .
	cp $config_dir_path/violas_chain_monitor.py .
	cp $HOME/violas/target/release/diem-node .
	cp $HOME/violas/target/release/cli .
fi

sleep 3

cd $HOME
if [  -f "violas/target/release/genesis.yaml" ]; then
	rm $HOME/violas/target/release/genesis.yaml
	touch $HOME/violas/target/release/genesis.yaml
	echo "---" >> $HOME/violas/target/release/genesis.yaml
	echo "chain_id: $chain_id" >> $HOME/violas/target/release/genesis.yaml
	echo "validators:" >> $HOME/violas/target/release/genesis.yaml
else
	touch $HOME/violas/target/release/genesis.yaml
	echo "---" >> $HOME/violas/target/release/genesis.yaml
	echo "chain_id: $chain_id" >> $HOME/violas/target/release/genesis.yaml
	echo "validators:" >> $HOME/violas/target/release/genesis.yaml
fi

# 根据输入验证节点IP生成validators.conf
validators_array=(${validators_ip//,/ })

for ip in ${validators_array[@]}
do
	echo " - /ip4/$ip/tcp/40002" >> $HOME/violas/target/release/genesis.yaml
done

# 根据输入的num_full_nodes判断生成验证节点或全节点配置文件，num_full_nodes为0时只生成验证节点配置文件
cd $HOME/violas/target/release/
if [ $num_full_nodes -eq 0 ]; then
	nohup $HOME/violas/target/release/diem-swarm -c $HOME/violascfg --diem-node $HOME/violas/target/release/diem-node -n $num_validator >$config_dir_path/swarm.log 2>&1 &
	sleep 10
else
	nohup $HOME/violas/target/release/diem-swarm -c $HOME/violascfg --diem-node $HOME/violas/target/release/diem-node -n $num_validator -f $num_full_nodes >$config_dir_path/swarm.log 2>&1 &
	sleep 10
fi
sh stop.sh
# 修改validator节点配置文件端口并打包
i=1
cd  $HOME
for ip_validator_node in ${validators_array[@]}
do
	j=`expr $i - 1`
	sed -i "89s|level:.*|level: ERROR|g" $HOME/violascfg/$j/node.yaml
	sed -i "108s|address:.*|address: \"0.0.0.0:50001\"|g" $HOME/violascfg/$j/node.yaml
	sed -i "72s|listen_address:.*|listen_address: /ip4/0.0.0.0/tcp/40013|g" $HOME/violascfg/$j/node.yaml
	cd $HOME/violascfg
	tar -zcf $HOME/deploy_node/$ip_validator_node.tar.gz  $j/* *$j*
	let i++
done

# 修改full_nodes节点配置文件端口并打包
if [ $num_full_nodes -ne 0 ]; then
	i=1
	full_nodes_array=(${full_nodes_ip//,/ })
	cd  $HOME
	for ip_full_node in ${full_nodes_array[@]}
	do
		j=`expr $i - 1`
		sed -i "99s|-.*ln-noise-ik|- /ip4/${validators_array[j]}/tcp/40013/ln-noise-ik|g" $HOME/violascfg/full_nodes/$j/node.yaml
		sed -i "154s|address:.*|address: \"0.0.0.0:50001\"|g" $HOME/violascfg/full_nodes/$j/node.yaml
		sed -i "135s|level:.*|level: ERROR|g" $HOME/violascfg/full_nodes/$j/node.yaml
		cd $HOME/violascfg
		tar -zcf $HOME/deploy_node/$ip_full_node.tar.gz  full_nodes/$j/* safety-rules_$j* full_node_$j*
		let i++
	done
fi

cd $config_dir_path
if [ ! -d "config" ]; then
	cp -R $HOME/violascfg/ $config_dir_path/config
else
	rm -rf $config_dir_path/config
	cp -R $HOME/violascfg/ $config_dir_path/config
fi

cd  $HOME
if [  -f "violascfg/0/node.yaml" ]; then
	echo "********************************************************"
	echo "Config file was created successfully"
	echo "path:$config_dir_path/config/"
	echo "Please run the following command on the deployment server:"
	echo "curl -O http://$master_node_ip/deploy_node.sh && chmod 775 deploy_node.sh"
	echo "********************************************************"
else
	echo "********************************************************"
	echo "Config created failed,Please run again build_config.sh"
	echo "********************************************************"
fi