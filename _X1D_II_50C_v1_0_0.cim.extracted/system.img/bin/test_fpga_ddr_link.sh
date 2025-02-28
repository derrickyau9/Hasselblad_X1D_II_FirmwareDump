#########################################################################
# File Name: test_fpga_ddr_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 24 May 2018 03:56:35 PM CST
#########################################################################
#!/bin/bash

timeout=100
elapsed()
{
	local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
	local diff=$(($now-$start))
	echo $diff
}

test_fpga_ddr()
{
	err_info="Failed to send message"
	err_info="farmus is not available"
	check_info="time_ms = 0"
	#test ddr
	odindb-send -s farmus -m func_test E_FuncTestModule_Ddr E_FuncTestAction_Start 1 0 0 > /dev/null 2>&1
	local ret=$?
	if [ $ret != 0 ]; then
		echo "start test ddr error"
		return 1
	fi

	start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
	while true
	do
		test=$(odindb-send -s farmus -m func_test E_FuncTestModule_Ddr E_FuncTestAction_Check 1 0 0)
		ret=$?
		if [ $ret = 0 ]; then
			echo $test | grep "$check_info"
			if [ $? = 0 ]; then
				echo "farm ddr test pass"
				return 0
			else
				echo "check fpga ddr test failed:$test not is:$check_info!"
				return 2
			fi
		else
			sleep 2
			if [ $(elapsed) -ge $timeout ]; then
				echo "check fpga ddr test failed:timeout!"
				return 3
			fi
			continue
		fi
	done
#			echo $test | grep $err_info
#			if [ $? = 0 ]; then
#				sleep 2
#				if [ $(elapsed) -ge $timeout ]; then
#					echo "check fpga ddr test failed!"
#					return 3
#				fi
#				continue
#			else
#				echo "$test"
#				echo "check fpga ddr test failed for other reason!"
#				return 4
#			fi
}

test_fpga_ddr
return $?
