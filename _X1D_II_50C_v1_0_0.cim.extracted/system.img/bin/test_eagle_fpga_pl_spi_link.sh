#########################################################################
# File Name: test_eagle_fpga_pl_spi_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 26 May 2018 05:23:28 PM CST
#########################################################################
#!/bin/bash

eagle_fpga_pl_spi_stop()
{
	local ret
	sleep 2
	odindb-send -s farmus -m func_test E_FuncTestModule_PlSpi E_FuncTestAction_Stop 1 0 0
	ret=$?
	if [ $ret != 0 ]; then
		echo "odindb-send failed!"
		return 5
	fi
}

eagle_fpga_pl_spi_test()
{
	local ret
	local val_table
	local val_array
	echo 256 > /sys/meta_spi/read
	ret=$?
	if [ $ret != 0 ]; then
		echo "set number of reading failed"
		return 1
	fi

	odindb-send -s farmus -m func_test E_FuncTestModule_PlSpi E_FuncTestAction_Start 1 0 0
	ret=$?
	if [ $ret != 0 ]; then
		echo "odindb-send start failed!"
		eagle_fpga_pl_spi_stop
		return 2
	fi
	val_table=$(pl_spi)
	ret=$?
	if [ $ret != 0 ]; then
		echo "pl_spi failed"
		eagle_fpga_pl_spi_stop
		return 3
	fi

	val_array=($val_table)
	local idx=0
	for idx in $(seq 0 15)
	do
		if [ ${val_array[idx]} != $idx ]; then
			echo "val_array[$idx]:${val_array[$idx]}"
			eagle_fpga_pl_spi_stop
			return 4
		fi
	done
#	echo ${val_array[*]}
	eagle_fpga_pl_spi_stop
	echo "eagle pl spi test pass!"
	return 0
}

eagle_fpga_pl_spi_test
exit $?
