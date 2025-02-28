#########################################################################
# File Name: test_power_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 26 May 2018 06:55:25 PM CST
#########################################################################
#!/bin/bash

#chanelx_rang=(min expectation max)
chanel0_range=(2400000 2500000 2600000)
chanel1_range=(1200000 1250000 1300000)
chanel2_range=(2400000 2500000 2600000)
chanel3_range=(1775000 1850000 1925000)
chanel4_range=(1600000 1650000 1700000)
chanel5_range=(1533000 2200000 2867000)
chanel13_range=(2400000 2500000 2600000)
chanel14_range=(2650000 2750000 2850000)
chanel15_range=(460000  500000  540000)

chanel_table=(0 1 2 3 4 5 13 14 15)
rate_table=(2 4 2 2 2 3 1 2 5)
val_table=(0 0 0 0 0 0 0 0 0)
# check voltage
# $1 - chanel_range
# $2 - chanel_value
check_voltage()
{
	if [ $# != 3 ]; then
		echo Invalid arguments for check_voltage
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
	local min_val=$(expr $min \* ${rate_table[$3]})
	local max_val=$(expr $max \* ${rate_table[$3]})
	if [ $min -le $2 ] && [ $2 -le $max ]; then
		#echo $1 $2 in valid range: $min \~ $max
		busybox printf "%-8s %-5d in valid range: %5d ~ %-5d\n" $1 $val $min_val $max_val
		return 0
	else
		echo Error! $1 $val not in valid range: $min_val \~ $max_val
		return 3
	fi
}

power_test()
{
	local num=${#chanel_table[@]}
	local idx=0
	local err_count=0
	for idx in $(seq 0 $(($num-1)))
	do
		odindb-send -s suc -m read_adc_cpu_voltage 1 ${chanel_table[$idx]} > tmp_cal.log
		if [ $idx = 0 ]; then
			adc_val[$idx]=$(busybox awk 'NR==3{print $3}' ./tmp_cal.log)
		else
			adc_val[$idx]=$(busybox awk 'NR==2{print $3}' ./tmp_cal.log)
		fi
		echo ${adc_val[$idx]}
		val_table[$idx]=$(expr ${adc_val[$idx]} \* ${rate_table[$idx]})
		check_voltage ${chanel_table[$idx]} ${adc_val[$idx]} $idx
		if [ $? != 0 ]; then
			let err_count++
		fi
	done
	echo ${val_table[*]}
	rm -f tmp_cal.log
	if [ $err_count != 0 ]; then
		return 4
	else
		echo "pass power link test!^_^"
		return 0
	fi
}

power_test
exit $?

