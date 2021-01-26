config_path="/home/ops/violascfg"
waypoint=`cat $config_path/waypoint.txt`
$config_path/cli -c 4 -m $config_path/mint.key -u http://127.0.0.1:50001 --waypoint $waypoint
