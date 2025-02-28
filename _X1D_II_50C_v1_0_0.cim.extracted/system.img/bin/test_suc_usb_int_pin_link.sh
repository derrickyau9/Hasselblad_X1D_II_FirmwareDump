#########################################################################
# File Name: test_suc_usb_int_pin.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 09 Aug 2018 01:00:33 PM CST
#########################################################################
#!/bin/bash

check_pc_connect()
{
	local pc_con_pattern="E_AdapterSourceType_SDP"
	local tmp
	local usb_con
	local ret
	local usb_con_pattern="HD3SS_TYPE_SINK"

	usb_con=$(cat /sys/devices/virtual/type-c-hd3ss/hd3ss/type)
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "check hd3ss error!"
		return 4
	fi

	if [ "$usb_con" = "$usb_con_pattern" ]; then
		echo "usb is connected!"
	else
		echo "usb is not connected"
		return 5
	fi

	tmp=$(odindb-send -s suc -p adapter_source_typ)
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "use odindb-send to check device type error!"
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

	if [ "$tmp" = "$pc_con_pattern" ]; then
		echo "is pc connected!"
		return 0
	else
		echo "is not pc connected:$tmp"
		return 9
	fi

}

suc_usb_int_pin_test()
{
	local val_tmp
	local pin_val
	local ret
	local pin_pattern="E_SucGpioLevel_PinHigh"

	check_pc_connect
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "pc is not connected!"
		return 10
	fi
	odindb-send -s suc -m opt_otg true 500 5500
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "vbus setting failed!"
		return 11
	fi

	val_tmp=$(odindb-send -s suc -m get_gpio_status 4 2)
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "odindb-send run error!"
		return 1
	fi

	pin_val=$(echo $val_tmp | busybox awk '{print $9}')
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "awk run  error!"
		return 2
	fi

	if [ "$pin_val" = "$pin_pattern" ]; then
		echo "suc usb int pin pass!^_^"
		return 0
	else
		echo "suc usb int pin failed!err:$pin_val"
		return 3
	fi

	echo "can not arrive here!"
	return 4
}

suc_usb_int_pin_test
exit $?
