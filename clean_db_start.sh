cd $(pwd)
sh stop.sh
filename=`ls -l |awk '/^d/ {print $NF}'`
if [ ! -d "$filename" ];then
	echo "violas data directories do not exist "
else
	while true
	do
		read -r -p "Are you sure delete the data directory: "\"$(pwd)/$filename\""? [Y/n] " input
		case $input in
		    [yY][eE][sS]|[yY])
				rm -rf $(pwd)/$filename
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
tar -zxf *.tar.gz
sh start.sh