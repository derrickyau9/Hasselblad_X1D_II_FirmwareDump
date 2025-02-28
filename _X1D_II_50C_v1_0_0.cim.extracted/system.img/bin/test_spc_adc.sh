#!/system/bin/sh
#
# Test for SPC adc
#
# Usage:    test_spc_adc.sh
#
# Author:   Cunkui Ye
# Date:     2018/05
# Version:  V1.0
#

test_target='SPC adc'

# valid voltage range in mV
# vdd_xx_range=(Min Typical Max)
vdd_cb_range=(1764 1800 1836)
vdd_cm_range=(4784 5000 5183)
vdd_cn_range=(1764 1800 1836)
vdd_da_range=(4784 5000 5183)
vdd_lsv_range=(1764 1800 1836)
vdd_lv_range=(1764 1800 1836)
vdd_pl_range=(1764 1800 1836)
vdd_sa_range=(1764 1800 1836)
vdd_sc_range=(1764 1800 1836)
vdd_sub_range=(4784 5000 5183)
vdd_sv_range=(4784 5000 5183)
vdd_vrh_range=(4377 4500 4742)
vdd_vrl_range=(-1562 -1500 -1441)
vdd_vrm_range=(863 900 936)
vtemp_tl_range=(0 0 0)
vtemp_bl_range=(0 0 0)
vtemp_tr_range=(0 0 0)
vtemp_br_range=(0 0 0)

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

# check voltage
# $1 - vdd name, like vdd_cb
# $2 - vdd value, like 1800
function check_voltage()
{
	if [ $# != 2 ]; then
		echo Invalid arguments for check_voltage
		return 2
	fi

	range=$1"_range"

	if [ ! $(eval echo \$$range) ]; then
		echo Error! Range not defined for $1!
		return 3
	fi

	min=$(eval echo \${$range[0]})
	max=$(eval echo \${$range[2]})
	if [ $min -le $2 ] && [ $2 -le $max ]; then
		#echo $1 $2 in valid range: $min \~ $max
		busybox printf "%-8s %-5d in valid range: %5d ~ %-5d\n" $1 $2 $min $max
		return 0
	else
		echo Error! $1 $2 not in valid range: $min \~ $max
		return 1
	fi
}

function check_spc_adc()
{
	#sample output:
	#root@eagle_ec1704:/ #  odindb-send -s pwrctrl -m read_adc 0
	#vdd_lsv = 1803
	#vdd_cb = 1800
	#vdd_sub = 4948
	#vdd_da = 4935
	#vdd_cm = 5030
	#vdd_sv = 5018
	#vdd_vrh = 4551
	#vdd_vrm = 902
	#vdd_vrl = -1494
	#vdd_sc = 1802
	#vdd_cn = 1799
	#vdd_sa = 1801
	#vdd_pl = 1800
	#vdd_lv = 1802
	#vtemp_tl = 0
	#vtemp_bl = 0
	#vtemp_tr = 0
	#vtemp_br = 0

	invalid_count=0

	result=read_adc_result.txt
	odindb-send -s pwrctrl -m read_adc 0 > $result
	if [ $? != 0 ]; then
		return 1
	fi

	while read line
	do
		vdd_name=$(echo $line | busybox awk '{print $1}')
		vdd_value=$(echo $line | busybox awk '{print $3}')
		check_voltage $vdd_name $vdd_value
		if [ $? != 0 ]; then
			let invalid_count++
		fi
	done < $result
	rm $result

	if [ $invalid_count = 0 ]; then
		return 0
	else
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
	check_spc_adc
	if [ $? != 0 ]; then
		echo Error! Failed to check spc adc.
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
