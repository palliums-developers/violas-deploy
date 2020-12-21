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
read  -p "Please Enter The Primary Node IP:" master_node_ip
read  -p "Please Enter All Deployed IP,Separated by \",\":" deployed_ip
read  -p "Please Enter num-full-nodes:" num-full-nodes
# randseed=`$config_dir_path/randseed`
# echo $randseed >$config_dir_path/config/seed
# $HOME/violas/target/release/config-builder faucet -o $config_dir_path/config -s $randseed -n $num

sed -i "s|IP=.*|IP=$master_node_ip|g" $config_dir_path/deploy_node.sh
# sed -i "s|tag=.*|tag=$tag|g" $config_dir_path/deploy_node.sh

# for i in $(seq 1 $num)
# do
# 	i=`expr $i - 1`	
# 	$HOME/violas/target/release/config-builder validator -a "/ip4/51.140.241.96/tcp/40002" -b "/ip4/$master_node_ip/tcp/40002" -d $HOME/violascfg/$i  -i $i -l "/ip4/0.0.0.0/tcp/40002" -n $num -o $config_dir_path/config/$i -s $randseed
# done


cd $HOME/violas/target/release/
strip diem-node


#将配置文件以及部署脚本打包
cd $HOME
if [ ! -d "deploy_node" ]; then
	mkdir -p  deploy_node && cd deploy_node
	cp $config_dir_path/deploy_node.sh .
	# cp $config_dir_path/monitor.sh .
	cp $config_dir_path/clean_db_start.sh .
	cp $config_dir_path/start.sh .
	cp $config_dir_path/stop.sh .
	cp $config_dir_path/cli.sh .
	cp $config_dir_path/violas_chain_monitor.py .
	cp $HOME/violas/target/release/diem-node .
else
	rm -rf $HOME/deploy_node
	mkdir -p deploy_node && cd deploy_node
	cp $config_dir_path/deploy_node.sh .
	# cp $config_dir_path/monitor.sh .
	cp $config_dir_path/clean_db_start.sh .
	cp $config_dir_path/start.sh .
	cp $config_dir_path/stop.sh .
	cp $config_dir_path/cli.sh .
	cp $config_dir_path/violas_chain_monitor.py .
	cp $HOME/violas/target/release/diem-node .
fi

sleep 3
# 根据输入的部署IP更新配置文件并修改访问端口为50001
i=1
array=(${deployed_ip//,/ })

for ip in ${array[@]}
do
	echo /ip4/$ip/tcp/40002 >> $HOME/violas/target/release/validators.conf
done

cd $HOME/violas/target/release/
if [ $num-full-nodes eq 0]; then
	nohup $HOME/violas/target/release/diem-swarm -c $HOME/violascfg --diem-node $HOME/violas/target/release/diem-node -n $num >$config_dir_path/swarm.log 2>&1 &
	sleep 5
	killall diem-node
else
	nohup $HOME/violas/target/release/diem-swarm -c $HOME/violascfg --diem-node $HOME/violas/target/release/diem-node -n $num -f $num-full-nodes>$config_dir_path/swarm.log 2>&1 &
	sleep 10
	killall diem-node
fi

cd  $HOME
for ip in ${array[@]}
do
	j=`expr $i - 1`
	sed -i "89s|level:.*|level: ERROR|g" $HOME/violascfg/$j/node.yaml
	sed -i "108s|address:.*|address: \"0.0.0.0:50001\"|g" $HOME/violascfg/$j/node.yaml
	# sed -i "s|address: \"0.0.0.0:8080\"|address: \"0.0.0.0:50001\"|g" $config_dir_path/config/$j/node.yaml
	# sed -i "s|advertised_address:.*|advertised_address: \"\/ip4\/$ip\/tcp\/40002\"|g" $config_dir_path/config/$j/node.yaml
	cd $HOME/violascfg
	tar -zcf $HOME/deploy_node/$ip.tar.gz  $j/* *$j*
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
	echo "curl -O http://$master_node_ip/deploy_node.sh && chmod 775 deploy_node.sh"
	echo "********************************************************"
else
	echo "********************************************************"
	echo "Config create failure,Please run again build_config.sh"
	echo "********************************************************"
fi