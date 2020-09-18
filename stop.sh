cd $HOME/violascfg/
filename=`ls -l |awk '/^d/ {print $NF}'`
cd $filename
data_dir_path=`echo $(pwd)`
violaspro="libra-node"
pythonpro="violas_error_send.py"

ViolasPPID=`ps -ef | grep $violaspro | grep -v grep | wc -l`
if [ $ViolasPPID -ne 0 ]
	then
	ViolasPID=`ps -ef | grep $violaspro | grep -v grep | awk '{print $2}'`
	kill $ViolasPID
	echo "`date "+%Y-%m-%d %H:%M:%S"`: violas stop success"
else
	echo "`date "+%Y-%m-%d %H:%M:%S"`: violas process does not exist"
fi

PythonPPID=`ps -ef | grep $pythonpro | grep -v grep | wc -l`
if [ $PythonPPID -ne 0 ]
	then
	PythonPID=`ps -ef | grep $pythonpro | grep -v grep | awk '{print $2}'`
	kill $PythonPID
	echo "`date "+%Y-%m-%d %H:%M:%S"`: violas_error_send.py stop success"
else
	echo "`date "+%Y-%m-%d %H:%M:%S"`: violas_error_send.py process does not exist"
fi


