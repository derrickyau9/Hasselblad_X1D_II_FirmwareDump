#!/system/bin/sh
# usage:
# ./stress_test.sh [num_of_test_mem] [test_mem_size_per_instance]

# include the script lib
. lib_test_stress.sh

local addr_log=/blackbox/system
mkdir -p $addr_log
memory_test()
{
	# memory test
	num=4
	sz=0x2000000

	start_inf_error_action $num "test_mem -s $sz -l $1" >> $addr_log/eagle_ddr_stress_test.log
}
# compression test
#dd if=/dev/urandom of=/tmp/testimage bs=524288 count=10
#start_inf_error_action 4 "gzip -9 -c /tmp/testimage | gzip -d -c > /dev/null"
is_mem_test_finish()
{
	local ret

	ps | grep test_mem
	ret=$?
	while [ $ret -eq 0 ]; do
		ps | grep test_mem
		ret=$?
		if [ $ret -ne 0 ]; then
			echo "test mem finish!"
			return $ret
		else
			echo "test mem continue!"
			sleep 2
		fi
	done
	
	echo "test mem finish!"
	return $ret
}

test_mem_func()
{
	if [ $# -ne 1 ]; then
		echo "parameter should be one"
		return 3
	fi 
	date > $addr_log/eagle_ddr_stress_test.log
	sync
	memory_test $1
	is_mem_test_finish
	if [ $? -ne 0 ]; then
		echo "finish" >> $addr_log/eagle_ddr_stress_test.log
		date >> $addr_log/eagle_ddr_stress_test.log
		return 0
	else
		echo "can not arrive here"
		return 2
	fi
}

eagle_ddr_test_times=${1:-50}
test_mem_func $eagle_ddr_test_times
exit 0
