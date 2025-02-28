#########################################################################
# File Name: dji_close_suspend_powerdown.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 18 Oct 2018 03:20:30 PM CST
#########################################################################
#!/bin/bash
#close auto suspend
odindb-send -s config -p gui_idle_timeout 0
if [ $? -ne 0 ]; then
	echo "close auto suspend filed!"
	exit $?
fi
#close auto power down
odindb-send -s config -p sys_standby_idle_timeout 0
if [ $? -ne 0 ]; then
	echo "close auto power down filed!"
	exit $?
fi
exit 0
