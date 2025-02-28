#!/system/bin/sh

eagle_product()
{
	cat /proc/cmdline | grep "mp_state=production"
	local pro_ret=$?
	return $pro_ret
}

sleep 0.5
eagle_product

if [ $? -eq 0 ]; then
	setprop sys.usb.config none
	setprop sys.usb.config rndis,mass_storage,bulk,acm
else
	setprop sys.usb.config none
	setprop sys.usb.config rndis,mass_storage,bulk,acm,adb
fi
