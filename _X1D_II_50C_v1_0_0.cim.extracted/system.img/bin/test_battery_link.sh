#########################################################################
# File Name: test_battery_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 28 Jun 2018 05:53:10 PM CST
#########################################################################
#!/bin/bash

battery_link_test()
{
	local ret
	local battery_idx
	local value
	battery_idx=$(odindb-send -s suc -p battery_level)
	ret=$?
	if [ $ret != 0 ]; then
		echo "access battery failed!"
		return 1
	fi
	value=$(echo $battery_idx | busybox awk '{print $3}')
	if [ $value = 0 ]; then
		echo "battery link test failed!"
		return 2
	else
		echo "battery link test pass!"
		return 0
	fi
}

battery_link_test
exit $?
