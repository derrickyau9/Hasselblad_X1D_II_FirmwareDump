#########################################################################
# File Name: fpga_ddr_stress_test.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 14 Aug 2018 10:40:27 AM CST
#########################################################################
#!/bin/bash
. lib_test.sh
. aging_test.sh
. lib_test_cases.sh

local addr_log=/blackbox/system
mkdir -p $addr_log
fpga_ddr_aging_test()
{
	err_info="Failed to send message"
	err_info="farmus is not available"
	check_info="time_ms = 0"
	local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
	local ddr_test_start=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
	local diff=0
	local ddr_test_timeout=60
	#test ddr
    odindb-send -s farmus -m func_test E_FuncTestModule_Ddr E_FuncTestAction_Start 1 0 0 > /dev/null 2>&1
	local ret=$?
	if [ $ret != 0 ]; then
		echo "start test ddr error"
		return 1
	fi

    sleep 10
    start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
	while true
	do
		test=$(odindb-send -s farmus -m func_test E_FuncTestModule_Ddr E_FuncTestAction_Check 1 0 0)
		ret=$?
		if [ $ret = 0 ]; then
			echo $test | grep "$check_info"
			if [ $? = 0 ]; then
				echo "farm ddr test pass"
                sleep 5
				return 0
			else
				echo "check fpga ddr test failed:$test not is:$check_info!"
                sleep 5
				return 2
			fi
		else
			sleep 5
			now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
			diff=$(($now-$ddr_test_start))
			if [ $diff -ge $ddr_test_timeout ]; then
				echo "check fpga ddr test failed:timeout!"
                sleep 5
				return 3
			fi
			continue
		fi
	done
}

fpga_ddr_test_time=${1:-43200}
# fpga ddr aging test
timeout=$fpga_ddr_test_time
start_timeout_error_action_block 1 "fpga_ddr_aging_test" >> $addr_log/fpga_ddr_stress_test.log
