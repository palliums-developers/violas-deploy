#!/bin/bash
violas_scripts_path=`echo $(pwd)`
violas_path="$HOME/violas/target/release/"
violascfg_path="$HOME/violascfg"

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

nohup $violas_path/diem-swarm -c $violascfg_path --diem-node $violas_path/diem-node -n 1 >$violas_scripts_path/swarm.log 2>&1 &

sleep 3
cd $violascfg_path
rm -rf $violascfg_path/logs
cp $violas_scripts_path/start.sh .
cp $violas_scripts_path/stop.sh .
cp $violas_scripts_path/cli.sh .
cp $violas_scripts_path/clean_db_start.sh .
cp $violas_scripts_path/violas_chain_monitor.py .
cp $violas_path/diem-node .
mv mint.key mint_beijing.key

sed -i "89s|level:.*|level: ERROR|g" $violascfg_path/0/node.yaml
sed -i "108s|address:.*|address: \"0.0.0.0:50001\"|g" $violascfg_path/0/node.yaml

sh stop.sh
sleep 2
sh start.sh

