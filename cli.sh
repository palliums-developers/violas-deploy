if [  -f "waypoint.txt" ]; then
	waypoint=`cat waypoint.txt`
	while true
	do
		read  -p $'MAINNET = 1\x0aTESTNET = 2\x0aDEVNET = 3\x0aTESTING = 4\x0aPREMAINNET = 5\x0aPlease enter chainid :' chainid
		# if [[ $num =~ ^[1-5]+$ ]]; then
		# 	break
		if [ $chainid -eq 1 ]; then
			echo "Chainid not used yet,please re-enter:"
		elif [ $chainid -eq 2 ]; then
			break
		elif [ $chainid -eq 3 ]; then
			echo "Chainid not used yet,please re-enter:"
		elif [ $chainid -eq 4 ]; then
			break
		elif [ $chainid -eq 5 ]; then
			break
		else
			echo "Chainid input error,please re-enter:"
		fi
	done
	if [  -f "mint.key" ]; then
		cli -c $chainid -m mint.key -u http://127.0.0.1:50001 --waypoint $waypoint.txt
	else
		cli -c $chainid -u http://127.0.0.1:50001 --waypoint $waypoint.txt
	fi
else
	echo "waypoint.txt does not exist."
fi


