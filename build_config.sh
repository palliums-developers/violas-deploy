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
# sed -i "s|max_transaction_size_in_bytes: 4096|max_transaction_size_in_bytes: 32768|g" $HOME/violas/language/move-core/types/src/gas_schedule.rs
source $HOME/.cargo/env
cargo build --release --all 

cd $HOME
if [  -f "violas/target/release/validators.conf" ]; then
	rm $HOME/violas/target/release/validators.conf
	touch $HOME/violas/target/release/validators.conf
else
	touch $HOME/violas/target/release/validators.conf
fi
#创建配置文件，输入需要创建的节点数量
# cd $HOME
# if [ ! -d "violas_scripts/config" ]; then
# 	mkdir -p  violas_scripts/config && cd violas_scripts/config
# else
# while true
# do
# 	read -r -p "Are You Sure Delete "$config_dir_path/config"? [Y/n] " input
# 	case $input in
# 	    [yY][eE][sS]|[yY])
# 			rm -rf $config_dir_path/config
# 			mkdir -p  violas_scripts/config && cd violas_scripts/config
# 			break
# 			;;

# 	    [nN][oO]|[nN])
# 			echo "Exit compilation, please delete config file manually"
# 			exit 1	       	
# 			;;

# 	    *)
# 			echo "Invalid input..."
# 			;;
# 	esac
# done
# fi
#$HOME/violas/target/release/generate-keypair -o faucet_keys
read  -p "Please Enter The Number of Nodes Created:" num
read  -p "Please Enter num-full-nodes:" num_full_nodes
read  -p "Please Enter The Primary Node IP:" master_node_ip
read  -p "Please Enter All Validators IP,Separated by \",\":" validators_ip
read  -p "Please Enter All Full_nodes IP,Separated by \",\":" full_nodes_ip

# randseed=`$config_dir_path/randseed`
# echo $randseed >$config_dir_path/config/seed
# $HOME/violas/target/release/config-builder faucet -o $config_dir_path/config -s $randseed -n $num

sed -i "s|IP=.*|IP=$master_node_ip|g" $config_dir_path/deploy_validator_node.sh
sed -i "s|IP=.*|IP=$master_node_ip|g" $config_dir_path/deploy_full_node.sh
# sed -i "s|tag=.*|tag=$tag|g" $config_dir_path/deploy_node.sh

# for i in $(seq 1 $num)
# do
# 	i=`expr $i - 1`	
# 	$HOME/violas/target/release/config-builder validator -a "/ip4/51.140.241.96/tcp/40002" -b "/ip4/$master_node_ip/tcp/40002" -d $HOME/violascfg/$i  -i $i -l "/ip4/0.0.0.0/tcp/40002" -n $num -o $config_dir_path/config/$i -s $randseed
# done


cd $HOME/violas/target/release/
strip diem-node
strip cli


#将配置文件以及部署脚本打包
cd $HOME
if [ ! -d "deploy_node" ]; then
	mkdir -p  deploy_node && cd deploy_node
	cp $config_dir_path/deploy_validator_node.sh .
	cp $config_dir_path/deploy_full_node.sh .
	cp $config_dir_path/clean_db_start.sh .
	cp $config_dir_path/start.sh .
	cp $config_dir_path/stop.sh .
	cp $config_dir_path/cli.sh .
	cp $config_dir_path/full_node_cli.sh .
	cp $config_dir_path/violas_chain_monitor.py .
	cp $HOME/violas/target/release/diem-node .
	cp $HOME/violas/target/release/cli .
else
	rm -rf $HOME/deploy_node
	mkdir -p deploy_node && cd deploy_node
	cp $config_dir_path/deploy_validator_node.sh .
	cp $config_dir_path/deploy_full_node.sh .
	cp $config_dir_path/clean_db_start.sh .
	cp $config_dir_path/start.sh .
	cp $config_dir_path/stop.sh .
	cp $config_dir_path/cli.sh .
	cp $config_dir_path/full_node_cli.sh .
	cp $config_dir_path/violas_chain_monitor.py .
	cp $HOME/violas/target/release/diem-node .
	cp $HOME/violas/target/release/cli .
fi

sleep 3

# 根据输入验证节点IP生成validators.conf
i=1
validators_array=(${validators_ip//,/ })

for ip in ${validators_array[@]}
do
	echo /ip4/$ip/tcp/40002 >> $HOME/violas/target/release/validators.conf
done

# 根据输入的num_full_nodes判断生成验证节点或全节点配置文件，num_full_nodes为0时只生成验证节点配置文件
cd $HOME/violas/target/release/
if [ $num_full_nodes -eq 0 ]; then
	nohup $HOME/violas/target/release/diem-swarm -c $HOME/violascfg --diem-node $HOME/violas/target/release/diem-node -n $num >$config_dir_path/swarm.log 2>&1 &
	sleep 5
	killall diem-node
else
	nohup $HOME/violas/target/release/diem-swarm -c $HOME/violascfg --diem-node $HOME/violas/target/release/diem-node -n $num -f $num_full_nodes >$config_dir_path/swarm.log 2>&1 &
	sleep 10
	killall diem-node
fi

# 修改validator节点配置文件端口并打包
cd  $HOME
for ip_validator_node in ${validators_array[@]}
do
	j=`expr $i - 1`
	sed -i "89s|level:.*|level: ERROR|g" $HOME/violascfg/$j/node.yaml
	sed -i "108s|address:.*|address: \"0.0.0.0:50001\"|g" $HOME/violascfg/$j/node.yaml
	sed -i "72s|listen_address:.*|listen_address: /ip4/0.0.0.0/tcp/40013|g" $HOME/violascfg/$j/node.yaml
	# sed -i "s|address: \"0.0.0.0:8080\"|address: \"0.0.0.0:50001\"|g" $config_dir_path/config/$j/node.yaml
	# sed -i "s|advertised_address:.*|advertised_address: \"\/ip4\/$ip\/tcp\/40002\"|g" $config_dir_path/config/$j/node.yaml
	cd $HOME/violascfg
	tar -zcf $HOME/deploy_node/$ip_validator_node.tar.gz  $j/* *$j*
	let i++
done

# 修改full_nodes节点配置文件端口并打包
i=1
full_nodes_array=(${full_nodes_ip//,/ })
cd  $HOME
for ip_full_node in ${full_nodes_array[@]}
do
	j=`expr $i - 1`
	sed -i "99s|-.*ln-noise-ik|        - /ip4/${validators_array[j]}/tcp/40013/ln-noise-ik|g" $HOME/violascfg/full_nodes/$j/node.yaml
	sed -i "154s|address:.*|address: \"0.0.0.0:50001\"|g" $HOME/violascfg/full_nodes/$j/node.yaml
	sed -i "135s|level:.*|level: ERROR|g" $HOME/violascfg/full_nodes/$j/node.yaml
	cd $HOME/violascfg
	tar -zcf $HOME/deploy_node/$ip_full_node.tar.gz  full_nodes/$j/* safety-rules_$j* full_node_$j*
	let i++
done


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
	echo "Config generated"
	echo "path:$config_dir_path/config/"
	echo "Please run the following command on the deployment server:"
	echo "curl -O http://$master_node_ip/deploy_validator_node.sh && chmod 775 deploy_validator_node.sh"
	echo "curl -O http://$master_node_ip/deploy_full_node.sh && chmod 775 deploy_full_node.sh"
	echo "********************************************************"
else
	echo "********************************************************"
	echo "Config create failure,Please run again build_config.sh"
	echo "********************************************************"
fi