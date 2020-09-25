config_path=""
waypoint=`cat $config_path/config/waypoint.txt`
$HOME/violas/target/release/cli -c 4 -m $config_path/config/mint.key -u http://127.0.0.1:50001 --waypoint $waypoint
