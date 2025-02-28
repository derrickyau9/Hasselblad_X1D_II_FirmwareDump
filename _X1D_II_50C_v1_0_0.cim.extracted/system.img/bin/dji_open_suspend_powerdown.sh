#########################################################################
# File Name: dji_open_suspend_powerdown.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 18 Oct 2018 03:20:30 PM CST
#########################################################################
#!/bin/bash
#open auto suspend
odindb-send -s config -p gui_idle_timeout 10
if [ $? -ne 0 ]; then
	echo "open auto suspend filed!"
	exit $?
fi
#open auto power down
odindb-send -s config -p sys_standby_idle_timeout 600
if [ $? -ne 0 ]; then
	echo "open auto power down filed!"
	exit $?
fi
exit 0
