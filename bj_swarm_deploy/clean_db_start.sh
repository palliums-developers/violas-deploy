cd $HOME/violascfg/
filename=`ls -l |awk '/^d/ {print $NF}'`
cd $filename
data_dir_path=`echo $(pwd)`
violaspro="diem-node"
pythonpro="violas_chain_monitor.py"

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

cd $data_dir_path
if [ -d "db" ]; then
	rm $data_dir_path/db/ -rf
fi

cd $HOME/violascfg
if [ -f "violas.log" ]; then
	rm $HOME/violascfg/violas.log
fi

cd $HOME/violascfg
if [ -f "violas_error_log.txt" ]; then
	rm $HOME/violascfg/violas_error_log.txt
fi

sh $HOME/violascfg/start.sh

