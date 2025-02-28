#!/system/bin/sh
#
# Upgrade GL3227
#
# Usage:    upgrade_gl3227.sh
#
# Author:   Philip.Liu
# Date:     2018/10
# Version:  V1.0
# History:
#       V1.0 2018/10 Original version
#
echo 1 > /sys/bus/platform/drivers/sd_reset/f0a00000.apb:sd_reset/phypwr
echo "waiting for adding hcd ..."
sleep 10
echo "hcd added"

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
ret=0
if [ $ver == 3230303032303030 ]; then
	echo "3227 version is right"
else
	echo "3227 version is wrong. upgrade it"
	#check if upgrade success, and verify return value
	gl_flash /dev/sg0
	v1=$?
	if [ $v1 != 0 ]; then
		ret=$v1
	else
		gl_flash /dev/sg1
		v2=$?
		if [ $v2 == 0 ]; then
			echo "upgrade done"
		fi
		ret=$v2
	fi
fi

rm /data/usb_no_suspend
#there's bug
#echo 0 > /sys/bus/platform/drivers/sd_reset/f0a00000.apb:sd_reset/phypwr
echo ret=$ret
exit $ret