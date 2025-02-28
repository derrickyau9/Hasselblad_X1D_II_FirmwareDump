#########################################################################
# File Name: test_qc_flow_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 09 Aug 2018 01:00:33 PM CST
#########################################################################
#!/bin/bash

in_range()
{
	val=$1
	min=$2
	max=$3
	string=$4

	if [ $val -le $min -o  $val -ge $max ]; then
		echo "$string $val not in range $min-$max"
		return 1
	fi

	echo "$string $val in range $min-$max"
	return 0
}
check_pc_connect()
{
	local pc_con_pattern1="E_AdapterSourceType_SDP"
	local pc_con_pattern2="E_AdapterSourceType_CDP"
	local tmp
	local usb_con
	local ret
	local usb_con_pattern="HD3SS_TYPE_SINK"

	usb_con=$(cat /sys/devices/virtual/type-c-hd3ss/hd3ss/type)
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "/sys/devices/virtual/type-c-hd3ss/hd3ss/type not found."
		return 4
	fi

	echo "$usb_con must be $usb_con_pattern"
	if [ "$usb_con" != "$usb_con_pattern" ]; then
		return 5
	fi

	tmp=$(odindb-send -s suc -p adapter_source_typ)
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "odindb-send -s suc -p adapter_source_typ returned fail."
		return 6
	fi

	tmp=$(echo $tmp | busybox awk '{print $3}')
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "awk(-F' ') run error!"
		return 7
	fi

	tmp=$(echo $tmp | busybox awk -F'(' '{print $1}')
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "awk(-F'(') run error!"
		return 8
	fi

	echo "$tmp must be $pc_con_pattern1 or $pc_con_pattern2"
	if [ "$tmp" = "$pc_con_pattern1" -o "$tmp" = "$pc_con_pattern2" ]; then
		return 0
	else
		return 9
	fi
}

voltage_current_test()
{
	local val_tmp
	local vol_val
	local vsys_val
	local vbat_val
	local cur_val
	local ret
	local max_input_current=2000
	local min_input_current=0
	local max_batt_voltage=8600
	local min_batt_voltage=5000
	local max_vsys_voltage=8600
	local min_vsys_voltage=5000
	local min_usb_voltage=4000
	local max_usb_voltage=5500

	check_pc_connect
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "pc is not connected!"
		return 10
	fi

	val_tmp=$(odindb-send -s suc -m get_charge_flow_adc 1)
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "odindb-send run error!"
		return 1
	fi

	vol_val=$(echo $val_tmp | busybox awk '{print $3}')
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "vol_val:awk run  error!"
		return 2
	fi

	in_range $vol_val $min_usb_voltage $max_usb_voltage vol_val
	if [ $? -ne 0 ]; then
		return 12
	fi

	cur_val=$(echo $val_tmp | busybox awk '{print $15}')
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "cur_val:awk run  error!"
		return 13
	fi

	in_range $cur_val $min_input_current $max_input_current cur_val
	if [ $? -ne 0 ]; then
		return 14
	fi

	vsys_val=$(echo $val_tmp | busybox awk '{print $21}')
	if [ $? -ne 0 ]; then
		echo "vsys_val:awk run  error!"
		return 15
	fi

	in_range $vsys_val $min_vsys_voltage $max_vsys_voltage vsys_val
	if [ $? -ne 0 ]; then
		return 16
	fi

	vbat_val=$(echo $val_tmp | busybox awk '{print $24}')
	if [ $? -ne 0 ]; then
		echo "vbat_val:awk run  error!"
		return 17
	fi

	in_range $vbat_val $min_batt_voltage $max_batt_voltage vbat_val
	if [ $? -ne 0 ]; then
		return 18
	fi

	echo "qc test pass!^_^"
	return 0
}


voltage_current_test
#odindb-send -s suc -m get_charge_flow_adc 1 might return 0 instead of correct values
#Re-run once if this happens.
if [ $? -ne 0 ]; then
	sleep 1
	voltage_current_test
fi

exit $?
