#!/system/bin/sh

usb_conn=`cat /sys/class/android_usb/android0/state`
udc_name=`cat /sys/kernel/config/usb_gadget/g1/UDC`
chk_usb_device_conn_state()
{
	if [ $usb_conn == CONFIGURED ]; then
		echo "usb conn ok"
		return 0
	elif [ $udc_name != "" ];then
		echo "usb not conn but udc exists"
		return 1
	else
		echo "usb not conn, no udc"
		return 2
	fi
}

chk_usb_device_conn_state
exit $?
