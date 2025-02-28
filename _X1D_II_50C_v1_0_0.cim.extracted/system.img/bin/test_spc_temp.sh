#!/system/bin/sh
#
# Test for SPC temperature
#
# Usage:    test_spc_temp.sh
#
# Author:   Cunkui Ye
# Date:     2018/05
# Version:  V1.0
#

test_target='SPC temperature'
valid_temp_range=(0 75)

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
	ps | grep msg2dbus > /dev/null
	if [ $? != 0 ]; then
		echo Error! msg2dbus not running.
		result_show_and_exit 3
	fi

	return 0
}

function check_spc_temp()
{
	#sample output:
	#root@eagle_ec1704:/ # odindb-send -s pwrctrl -m read_temperature 0
	#temp_celcius = 43

	temp=$(odindb-send -s pwrctrl -m read_temperature 0 | busybox awk '{print $3}')
	#echo temp=$temp
	if [ ${valid_temp_range[0]} -lt $temp -a $temp -lt ${valid_temp_range[1]} ]; then
		echo Temperature $temp in valid range: ${valid_temp_range[0]} \~ ${valid_temp_range[1]}
		return 0
	else
		echo Temperature $temp not in valid range: ${valid_temp_range[0]} \~ ${valid_temp_range[1]}
		return 1
	fi
}

function do_test()
{
	# check apps-msg link between Eagle and FARM.
	upgrade_fw -c -n farmus > /dev/null 2>&1
	if [ $? != 0 ]; then
		echo Error! Please check apps-msg link between Eagle and FARM
		return 2
	fi

	# check apps-msg link between Eagle and SPC (via FARM)
	upgrade_fw -c -n pwrctrl > /dev/null 2>&1
	if [ $? != 0 ]; then
		echo Error! Please check apps-msg link between Eagle and SPC.
		return 2
	fi

	# check SPC temperature
	check_spc_temp
	if [ $? != 0 ]; then
		echo Error! Failed to check spc temp.
		return 1
	fi

	return 0
}

function post_test()
{
	return 0
}

pre_test
do_test
result=$?
post_test

result_show_and_exit $result
