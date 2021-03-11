cd $(pwd)
sh stop.sh
sleep 2
filename=`ls -l |awk '/^d/ {print $NF}'`
if [ ! -d "$filename" ];then
	tar -zxf *.tar.gz
	sh start.sh
else
	while true
	do
		read -r -p "Are you sure delete the data directory: "\"$(pwd)/$filename\""? [Y/n] " input
		case $input in
		    [yY][eE][sS]|[yY])
				rm -rf $(pwd)/$filename
				tar -zxf *.tar.gz
				sh start.sh
				break
				;;
	
		    [nN][oO]|[nN])
				echo "Exit, please delete data directory manually"
				exit 1	       	
				;;
	
		    *)
				echo "Invalid input..."
				;;
	esac
	done
fi
