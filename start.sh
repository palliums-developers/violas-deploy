cd $HOME/violascfg/
filename=`ls -l |awk '/^d/ {print $NF}'`
cd $filename
data_dir_path=`echo $(pwd)`
violaspro="libra-node"
pythonpro="violas_chain_monitor.py"
logfile="$HOME/violascfg/violas.log"
split_line="*************************************************************"

#启动violas链
ViolasPPID=`ps -ef | grep $violaspro | grep -v grep | wc -l`
if [ $ViolasPPID -eq 0 ]
	then
	echo "$split_line">>$logfile
	echo "`date "+%Y-%m-%d %H:%M:%S"` :violas is starting" >>$logfile
	echo "$split_line">>$logfile
	nohup $HOME/violascfg/libra-node  -f $data_dir_path/node.yaml >>$logfile 2>&1 &
	sleep 3
	CurrentViolasPPID=`ps -ef | grep $violaspro | grep -v grep | wc -l`
	if [ $CurrentViolasPPID -ne 0 ]
		then
		echo "$split_line">>$logfile
		echo "`date "+%Y-%m-%d %H:%M:%S"` :violas is running" >>$logfile
		echo "$split_line">>$logfile
		echo "`date "+%Y-%m-%d %H:%M:%S"`: violas start success"
	fi
else
	echo "`date "+%Y-%m-%d %H:%M:%S"`: violas process already exist"
fi

#启动监控运行脚本
sleep 3
PythonPPID=`ps -ef | grep $pythonpro | grep -v grep | wc -l`
if [ $PythonPPID -eq 0 ]
	then
	cd $(dirname $data_dir_path)
	CurrentViolasPPID=`ps -ef | grep $violaspro | grep -v grep | wc -l`
	if [ $CurrentViolasPPID -ne 0 ]
		then
		nohup python3 violas_error_send.py >>$logfile 2>&1 &
	fi
	CurrentPythonPPID=`ps -ef | grep $pythonpro | grep -v grep | wc -l`
	if [ $CurrentPythonPPID -ne 0 ]
		then
		echo "$split_line">>$logfile
		echo "`date "+%Y-%m-%d %H:%M:%S"`: $pythonpro is running" >>$logfile
		echo "$split_line">>$logfile
		echo "`date "+%Y-%m-%d %H:%M:%S"`: $pythonpro start success"
	fi
else
	echo "`date "+%Y-%m-%d %H:%M:%S"`: $pythonpro process already exist"
fi

