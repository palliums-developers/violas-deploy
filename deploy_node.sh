#!/bin/bash
#下载violas并编译
sudo apt-get install git
sudo apt-get update
sudo apt-get install -y build-essential
sudo pip3 install psutil

IP=52.151.2.66
# tag=v0.3.0

# cd $HOME
# if [ ! -d "violas" ];then
# 	git clone https://github.com/palliums-developers/Violas violas
# 	cd $HOME/violas && git checkout $tag && ./scripts/dev_setup.sh
# else
# 	cd $HOME/violas && git pull origin violas:violas && git checkout $tag && ./scripts/dev_setup.sh
# fi
# sed -i "s|const MAX_GAS_AMOUNT: u64 = 140_000|const MAX_GAS_AMOUNT: u64 = 280_000|g" $HOME/violas/client/cli/src/client_proxy.rs
# source $HOME/.cargo/env
# cargo build --release --all

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

# 获取当前目录下所有文件夹名
# filename=`ls -l |awk '/^d/ {print $NF}'`
# cd $filename
# data_dir_path=`echo $(pwd)`
# sed -i "s|data_dir: .*|data_dir: \"$data_dir_path\"|g" $data_dir_path/node.yaml

#创建监控脚本，每隔5秒检测节点进程是否存在，不存在则重启
# cd $HOME
# grep -q "$(pwd)/violascfg/monitor.sh" /etc/crontab 
# if [ $? -ne 0 ];then
# 	echo "* *   * * *   ${USER}     $(pwd)/violascfg/monitor.sh" | sudo tee -a /etc/crontab
# fi


if [  -f "violascfg/stop.sh" ]; then
	sudo rm $HOME/violascfg/stop.sh
	cd  $HOME/violascfg && curl -O -s http://$IP/stop.sh
	sudo chmod 775 $HOME/violascfg/stop.sh
else
	cd  $HOME/violascfg && curl -O -s http://$IP/stop.sh
	sudo chmod 775 $HOME/violascfg/stop.sh
fi

if [  -f "violascfg/start.sh" ]; then
	sudo rm $HOME/violascfg/start.sh
	cd  $HOME/violascfg && curl -O -s http://$IP/start.sh
	sudo chmod 775 $HOME/violascfg/start.sh
else
	cd  $HOME/violascfg && curl -O -s http://$IP/start.sh
	sudo chmod 775 $HOME/violascfg/start.sh
fi

if [  -f "violascfg/restart.sh" ]; then
	sudo rm $HOME/violascfg/restart.sh
	cd  $HOME/violascfg && curl -O -s http://$IP/clean_db_start.sh
	sudo chmod 775 $HOME/violascfg/clean_db_start.sh
else
	cd  $HOME/violascfg && curl -O -s http://$IP/clean_db_start.sh
	sudo chmod 775 $HOME/violascfg/clean_db_start.sh
fi

# if [  -f "violascfg/update_node.sh" ]; then
# 	sudo rm $HOME/violascfg/update_node.sh
# 	cd  $HOME/violascfg && curl -O -s http://$IP/update_node.sh
# 	sudo chmod 775 $HOME/violascfg/update_node.sh
# else
# 	cd  $HOME/violascfg && curl -O -s http://$IP/update_node.sh
# 	sudo chmod 775 $HOME/violascfg/update_node.sh
# fi

if [  -f "violascfg/libra-node" ]; then
	sudo rm $HOME/violascfg/libra-node
	cd  $HOME/violascfg && curl -O -s http://$IP/libra-node
	sudo chmod 775 $HOME/violascfg/libra-node
else
	cd  $HOME/violascfg && curl -O -s http://$IP/libra-node
	sudo chmod 775 $HOME/violascfg/libra-node
fi

if [  "$node_ip" = "$IP" ]; then
	if [  -f "violascfg/cli.sh" ]; then
		sudo rm $HOME/violascfg/cli.sh
		cd  $HOME/violascfg && curl -O -s http://$IP/cli.sh
		sudo chmod 775 $HOME/violascfg/cli.sh
	else
		cd  $HOME/violascfg && curl -O -s http://$IP/cli.sh
		sudo chmod 775 $HOME/violascfg/cli.sh
	fi
fi

if [  -f "violascfg/violas_error_send.py" ]; then
	sudo rm $HOME/violascfg/violas_error_send.py
	cd  $HOME/violascfg && curl -O -s http://$IP/violas_chain_monitor.py
	sudo chmod 775 $HOME/violascfg/violas_chain_monitor.py
else
	cd  $HOME/violascfg && curl -O -s http://$IP/violas_chain_monitor.py
	sudo chmod 775 $HOME/violascfg/violas_chain_monitor.py
fi

sh $HOME/violascfg/start.sh
# `nohup $HOME/violascfg/libra-node  -f $data_dir_path/node.yaml >$HOME/violascfg/violas.log 2>&1 &`
# `nohup python3 violas_error_send.py >$HOME/violascfg/violas_error_send.log 2>&1 &`
sleep 5
ps -fe|grep libra-node |grep -v grep
if [ $? -ne 0 ]
	then
	cat $HOME/violascfg/violas.log
else
	echo "*************************************************"
	echo "VIOLAS SUCCESS START"
	echo "*************************************************"
fi