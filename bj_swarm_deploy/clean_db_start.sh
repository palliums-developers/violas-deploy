# cd $HOME/violascfg/
# filename=`ls -l |awk '/^d/ {print $NF}'`
# cd $filename
# data_dir_path=`echo $(pwd)`
# violaspro="diem-node"
# pythonpro="violas_chain_monitor.py"

violas_scripts_path=`echo $(pwd)`
violas_path="$HOME/violas/target/release/"
violascfg_path="$HOME/violascfg"

ViolasPPID=`ps -ef | grep $violaspro | grep -v grep | wc -l`
if [ $ViolasPPID -ne 0 ]
	then
	ViolasPID=`ps -ef | grep $violaspro | grep -v grep | awk '{print $2}'`
	kill $ViolasPID
fi

PythonPPID=`ps -ef | grep $pythonpro | grep -v grep | wc -l`
if [ $PythonPPID -ne 0 ]
	then
	PythonPID=`ps -ef | grep $pythonpro | grep -v grep | awk '{print $2}'`
	kill $PythonPID
fi

# cd $data_dir_path
# if [ -d "db" ]; then
# 	rm $data_dir_path/db/ -rf
# fi

# cd $HOME/violascfg
# if [ -f "violas.log" ]; then
# 	rm $HOME/violascfg/violas.log
# fi

# cd $HOME/violascfg
# if [ -f "violas_error_log.txt" ]; then
# 	rm $HOME/violascfg/violas_error_log.txt
# fi
cd $HOME
if [  -f "violas/target/release/genesis.yaml" ]; then
        rm $HOME/violas/target/release/genesis.yaml
        touch $HOME/violas/target/release/genesis.yaml
        echo "---" >> $HOME/violas/target/release/genesis.yaml
        echo "chain_id: 4" >> $HOME/violas/target/release/genesis.yaml
        echo "validators:" >> $HOME/violas/target/release/genesis.yaml
        echo " - /ip4/47.93.114.230/tcp/40002" >> $HOME/violas/target/release/genesis.yaml
else
        touch $HOME/violas/target/release/genesis.yaml
        echo "---" >> $HOME/violas/target/release/genesis.yaml
        echo "chain_id: 4" >> $HOME/violas/target/release/genesis.yaml
        echo "validators:" >> $HOME/violas/target/release/genesis.yaml
        echo " - /ip4/47.93.114.230/tcp/40002" >> $HOME/violas/target/release/genesis.yaml
fi

nohup $violas_path/diem-swarm -c $violascfg_path --diem-node $violas_path/diem-node -n 1 >$violas_scripts_path/swarm.log 2>&1 &

sleep 3
if [ -d "$violascfg_path" ]; then
        cd $violascfg_path
        rm -rf $violascfg_path/logs
        cp $violas_scripts_path/start.sh .
        cp $violas_scripts_path/stop.sh .
        cp $violas_scripts_path/cli.sh .
        cp $violas_scripts_path/clean_db_start.sh .
        cp $violas_scripts_path/violas_chain_monitor.py .
        cp $violas_path/diem-node .
        cp $violas_path/cli .
        mv mint.key mint_beijing.key
        sed -i "89s|level:.*|level: ERROR|g" $violascfg_path/0/node.yaml
        sed -i "108s|address:.*|address: \"0.0.0.0:50001\"|g" $violascfg_path/0/node.yaml
        sh stop.sh
        sleep 2
        sh start.sh
fi

sh $HOME/violascfg/start.sh

