#!/system/bin/sh
#
# Test FARM recovery mode
#
# Usage:    test_farm_recovery_mode.sh
#
# Author:   Cunkui Ye
# Date:     2018/08
# Version:  V1.0
#

test_target='FARM recovery mode'

# Use keywords to check recovery mode or normal mode
recovery_keyword1="RecoveryImageSetup: Starting up"
recovery_keyword2="recovery image flag set"
recovery_keyword3="Enter Recovery Image"
normal_keyword1="NormalImageSetup: Starting up"
normal_keyword2="recovery image flag no set"

logcat_id=0
test_timeout=10
log_file=test_recovery_mode.log
log_err_file=/blackbox/camera/log/test_recovery_mode.log

# result_show_and_exit
# $1 - exit code
function result_show_and_exit()
{
	if [ $1 = 0 ]; then
		echo Congratulations. Test for $test_target succeeded. ^_^
	elif [ $1 -ge 0 ]; then
		echo Sorry! Test for $test_target failed!!!
	fi

	exit $1
}

function pre_test()
{
	logcat -s -T1 msg2dbus:V > $log_file &
	logcat_id=$!
	#echo logcat_id=$logcat_id

	odindb-send -s suc -m set_recovery_mode 1 true
}

function do_test()
{
	test_time=0
	while [ $test_time -lt $test_timeout ]
	do
		recovery_mode=$(odindb-send -s farmus -p recovery_mode | busybox awk '{print $3}')
		echo Got RECOVERY property: recovery_mode=$recovery_mode
		if [ $recovery_mode = true ]; then
			return 0
		fi

		grep "$recovery_keyword1" $log_file > /dev/null
		if [ $? = 0 ]; then
			echo Found RECOVERY keyword: $recovery_keyword1
			return 0
		fi

		grep "$recovery_keyword2" $log_file > /dev/null
		if [ $? = 0 ]; then
			echo Found RECOVERY keyword: $recovery_keyword2
			return 0
		fi

		grep "$recovery_keyword3" $log_file > /dev/null
		if [ $? = 0 ]; then
			echo Found RECOVERY keyword: $recovery_keyword3
			return 0
		fi

		grep "$normal_keyword1" $log_file > /dev/null
		if [ $? = 0 ]; then
			echo Found NORMAL keyword: $normal_keyword1
			return 1
		fi

		grep "$normal_keyword2" $log_file > /dev/null
		if [ $? = 0 ]; then
			echo Found NORMAL keyword: $normal_keyword2
			return 1
		fi

		sleep 1
		let test_time++
	done

	echo Test timeout!
	return 2
}

function post_test()
{
	if [ $logcat_id -gt 0 ]; then
		kill $logcat_id
	fi

	if [ $1 = 0 ]; then
		odindb-send -s suc -m set_recovery_mode 1 false
		rm $log_file
	else
		echo Saving error log to $log_err_file ...
		mv $log_file $log_err_file
	fi
}

pre_test
do_test
result=$?
post_test $result

result_show_and_exit $result