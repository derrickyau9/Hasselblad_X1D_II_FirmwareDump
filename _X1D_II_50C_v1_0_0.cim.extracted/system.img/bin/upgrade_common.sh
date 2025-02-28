#!/system/bin/sh
#
# Common functions used when upgrading
#

function stop_live_view()
{
	echo "Check live view"
	local output=$(odindb-send -s camera -p live_view)
	if [[ $output == *"true"* ]]; then
		echo "   Stopping live view before upgrade"
		odindb-send -s camera -m set_live_view_state false
		sleep 2
	fi
}