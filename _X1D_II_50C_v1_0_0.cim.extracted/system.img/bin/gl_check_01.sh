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

if [ -e /dev/sg0 ]; then
	vea=$(gl_inquiry0)
	if [ "$vea" = "32303030" ]; then
		echo "3227 sg0 version is right"
	else
		echo "3227 sg0 version is wrong"
	fi
fi

if [ -e /dev/sg1 ]; then
	veb=$(gl_inquiry1)
	if [ "$veb" = "32303030" ]; then
		echo "3227 sg1 version is right"
	else
		echo "3227 sg1 version is wrong"
	fi
fi
