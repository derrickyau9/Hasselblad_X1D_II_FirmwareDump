#########################################################################
# File Name: test_main_board_power.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 21 June 2018 20:55:25 PM CST
#########################################################################
#Version : v0.1
#########################################################################

#########################################################################
# File Name: test_main_board_power.sh
# Author: Rose.Cai
# mail: Rose.Cai@dji.com
# Created Time: Sat 18 December 2018
#########################################################################
#Version : v0.2
#Change : Add retry counter to power on PL
#########################################################################
#!/bin/bash

#chanelx_rang=(min expectation max)
chanel0_range=(3200000 3300000 3400000)
chanel1_range=(3200000 3300000 3400000)
chanel2_range=(3200000 3300000 3400000)
chanel3_range=(3200000 3300000 3400000)
chanel4_range=(1700000 1800000 1900000)
chanel5_range=(1100000 1200000 1300000)
chanel6_range=(900000 1000000 1100000)
chanel7_range=(1700000 1800000 1900000)
chanel8_range=(1700000 1800000 1900000)
chanel9_range=(1000000 1100000 1200000)
chanel10_range=(800000 900000 1000000)
chanel11_range=(620000 720000 820000)
chanel12_range=(1100000 1200000 1300000)
chanel13_range=(2400000 2500000 2600000)
chanel14_range=(5400000 5500000 5750000)
chanel15_range=(2400000  2500000  2600000)

chanel_table=(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
rate_table=(2 2 2 2 1 1 1 1 1 1 1 1 1 1 2 1)
val_table=(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
# check voltage
# $1 - chanel_range
# $2 - chanel_value
check_voltage()
{
	if [ $# != 3 ]; then
		echo Invalid arguments for check_voltage
		echo "Argumnts number:$#,Argument:$*"
		return 1
	fi

	range="chanel"$1"_range"

	if [ ! $(eval echo \$$range) ]; then
		echo Error! Range not defined for $1!
		return 2
	fi

	min=$(eval echo \${$range[0]})
	max=$(eval echo \${$range[2]})
	local val=$(expr $2 \* ${rate_table[$3]})
#	local min_val=$(expr $min \* ${rate_table[$3]})
#	local max_val=$(expr $max \* ${rate_table[$3]})
	if [ $min -le $val ] && [ $val -le $max ]; then
		#echo $1 $2 in valid range: $min \~ $max
		busybox printf "%-8s %-5d in valid range: %5d ~ %-5d\n" $1 $val $min $max
		return 0
	else
		echo Error! $1 $val not in valid range: $min \~ $max
		return 3
	fi
}

power_test()
{
	local num=${#chanel_table[@]}
	local idx=0
	local retry_count=0
	local retry_count_max=5
	local err_count=0
	for idx in $(seq 0 $(($num-1)))
	do
		if [ idx -eq 10 ]; then
			vinput half_press
			sleep 2
			for retry_count in $(seq 0 $(($retry_count_max-1)))
			do
				odindb-send -s farmus -p power_mode | cut -d '(' -f 2 | cut -d ')' -f 1 > power_pl.log
				if [ $(busybox awk '{print $1}' ./power_pl.log) != 1 ]; then
					echo "Retry to power PL!"
					vinput half_press
					sleep 2
				else
					echo "Pl power on!"
					break;
				fi
			done
			rm power_pl.log
			if [ retry_count -eq retry_count_max-1 ]; then
				echo "ERROR: Can't power on PL!"
			fi
		fi
		odindb-send -s suc -m read_adc_cpu_voltage 1 ${chanel_table[$idx]} | grep adc_cpu_voltage > tmp_cal.log
		adc_val[$idx]=$(busybox awk '{print $3}' ./tmp_cal.log)
		echo ${adc_val[$idx]}
		val_table[$idx]=$(expr ${adc_val[$idx]} \* ${rate_table[$idx]})
		check_voltage ${chanel_table[$idx]} ${adc_val[$idx]} $idx
		if [ $? != 0 ]; then
			let err_count++
		fi
	done
	vinput menu_key
	echo ${val_table[*]}
	rm -f tmp_cal.log
	if [ $err_count != 0 ]; then
		return 4
	else
		echo "pass main board power test!^_^"
		return 0
	fi
}

power_test
exit $?

