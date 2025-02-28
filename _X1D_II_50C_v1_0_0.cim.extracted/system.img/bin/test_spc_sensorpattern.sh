#!/system/bin/sh
#
# Test for SPC sensor pattern
#
# Usage:    test_spc_sensorpattern.sh
#
# Author:   Cunkui Ye
# Date:     2018/05
# Version:  V1.0
#

test_target='SPC sensor pattern'

# Use pass_keyword is recommended since there are multiple fail_keyword
pass_keyword='E_ProdSensorPatternResult_Ok'
fail_keyword='E_ProdSensorPatternResult_ErrorCommunication'

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

function check_sensor_pattern()
{
	odindb-send -s farmus -m prod_sensorpattern | grep $pass_keyword
}

function do_test()
{
	# check apps-msg link between Eagle and FARM.
	upgrade_fw -c -n farmus > /dev/null 2>&1
	if [ $? != 0 ]; then
		echo Error! Please check apps-msg link between Eagle and FARM
		return 2
	fi

	# check apps-msg link between Eagle and SPC (via FARM), which is optional for this case
	upgrade_fw -c -n pwrctrl > /dev/null 2>&1
	if [ $? != 0 ]; then
		echo Warning! Please check apps-msg link between Eagle and SPC.
	fi

	# check sensor pattern
	check_sensor_pattern
	if [ $? != 0 ]; then
		echo Error! Failed to check sensor pattern.
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
