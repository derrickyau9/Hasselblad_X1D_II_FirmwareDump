#!/system/bin/sh

touch /data/usb_no_suspend
for loop in `find /sys/bus/scsi/devices/[0-9]:[0-9]:[0-9]:[0-9]/power -name "control"`
do
	echo on > "$loop"
done

for loop in `find /sys/bus/usb/devices/[0-9]-[0-9]/power -name "control"`
do
	echo on > "$loop"
done

ver=$(gl_inquiry)
if [ $ver == 3230303032303030 ]; then
	echo "3227 version is right"
	rm /data/usb_no_suspend
	exit 0
else
	echo "3227 version is wrong."
	echo "please run gl_flash.sh to upgrade it"
	echo "and then, restart system"
	rm /data/usb_no_suspend
	exit 1
fi
