waypoint=`cat $HOME/violas_scripts/config/waypoint.txt`
$HOME/violas/target/release/cli -c 4 -m $HOME/violas_scripts/config/mint.key -u http://127.0.0.1:50001 --waypoint $waypoint
