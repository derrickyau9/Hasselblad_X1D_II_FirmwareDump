#########################################################################
# File Name: set_aging_test.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 11 Oct 2018 10:34:40 PM CST
#########################################################################
#!/bin/bash
function create_aging_test_flag()
{
	if [ -d /data/dji ]; then
		touch /data/dji/aging_test_flag
		if [ $? -ne 0 ]; then
			echo "create aging_test_flag failed!"
			return 1
		fi
	else
		mkdir -p /data/dji
		if [ $? -ne 0 ]; then
			echo "create /data/dji failed!"
			return 2
		fi
		touch /data/dji/aging_test_flag
		if [ $? -ne 0 ]; then
			echo "create aging_test_flag failed!"
			return 1
		fi
	fi
}

create_aging_test_flag
exit $?
