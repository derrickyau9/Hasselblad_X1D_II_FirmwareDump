#########################################################################
# File Name: test_fpga_emmc_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 24 May 2018 03:56:35 PM CST
#########################################################################
#!/bin/bash
test_fpga_emmc()
{
	#test emmc
    odindb-send -s farmus -m func_test 3 0 1 0 0 > /dev/null 2>&1
	local ret=$?
	if [ $ret != 0 ]; then
		echo "start test emmc error"
		return 1
	fi

	while true
	do
		odindb-send -s farmus -m func_test 3 2 1 0 0 > /dev/null 2>&1
		ret=$?
		if [ $ret = 0 ]; then
			#stop emmc test,which is needed
			odindb-send -s farmus -m func_test 3 1 1 0 0 > /dev/null 2>&1
			ret=$?
			if [ $ret != 0 ]; then
				echo "stop test emmc error"
				return 2
			fi
			break
		fi
		sleep 2
	done
	echo "farm emmc test pass"
	return 0
}

test_fpga_emmc
return $?
