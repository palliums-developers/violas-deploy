script_path=`echo $(pwd)`
cd $script_path
data_dir=`ls -l |awk '/^d/ {print $NF}'`
cd $data_dir
data_dir_path=`echo $(pwd)`
sed -i "s|path:.*/violascfg|path: $(dirname $script_path)/violascfg|g" $data_dir_path/node.yaml
sed -i "s|data_dir:.*|data_dir: $data_dir_path|g" $data_dir_path/node.yaml

violaspro="diem-node"
pythonpro="violas_chain_monitor.py"
logfile="$script_path/violas.log"
split_line="*************************************************************"

#启动violas链
ViolasPPID=`ps -ef | grep $violaspro | grep -v grep | wc -l`
if [ $ViolasPPID -eq 0 ]
	then
	echo "$split_line">>$logfile
	echo "`date "+%Y-%m-%d %H:%M:%S"` :violas is starting" >>$logfile
	echo "$split_line">>$logfile
	nohup $script_path/diem-node  -f $data_dir_path/node.yaml >>$logfile 2>&1 &
	sleep 3
	CurrentViolasPPID=`ps -ef | grep $violaspro | grep -v grep | wc -l`
	if [ $CurrentViolasPPID -ne 0 ]
		then
		echo "$split_line">>$logfile
		echo "`date "+%Y-%m-%d %H:%M:%S"` :violas is running" >>$logfile
		echo "$split_line">>$logfile
		echo "`date "+%Y-%m-%d %H:%M:%S"`: violas start success"
	else
		echo "`date "+%Y-%m-%d %H:%M:%S"`: violas start failed"
		echo "`cat $logfile | tail -n 100`"
	fi
else
	echo "`date "+%Y-%m-%d %H:%M:%S"`: violas process already exist"
fi

#启动监控运行脚本
sleep 3
PythonPPID=`ps -ef | grep $pythonpro | grep -v grep | wc -l`
if [ $PythonPPID -eq 0 ]
	then
	cd $script_path
	CurrentViolasPPID=`ps -ef | grep $violaspro | grep -v grep | wc -l`
	if [ $CurrentViolasPPID -ne 0 ]
		then
		nohup python3 $pythonpro >>$logfile 2>&1 &
	fi
	sleep 3
	CurrentPythonPPID=`ps -ef | grep $pythonpro | grep -v grep | wc -l`
	if [ $CurrentPythonPPID -ne 0 ]
		then
		echo "$split_line">>$logfile
		echo "`date "+%Y-%m-%d %H:%M:%S"`: $pythonpro is running" >>$logfile
		echo "$split_line">>$logfile
		echo "`date "+%Y-%m-%d %H:%M:%S"`: $pythonpro start success"
	else
		echo "`date "+%Y-%m-%d %H:%M:%S"`: $pythonpro start failed"
		echo "`cat $logfile | tail -n 100`"
	fi
else
	echo "`date "+%Y-%m-%d %H:%M:%S"`: $pythonpro process already exist"
fi

