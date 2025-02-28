#!/system/bin/sh

while true
do

	sleep 5

	if [ -f "/data/usb_no_suspend" ]; then
		echo "usb not suspend"
		continue;
	fi
	echo "set usb suspend"

	for loop in `find /sys/bus/scsi/devices/[0-9]:[0-9]:[0-9]:[0-9]/power -name "autosuspend*"`
	do
		#echo "$loop"
		echo 3000 > "$loop"
		#cat "$loop"
	done

	for loop in `find /sys/bus/scsi/devices/[0-9]:[0-9]:[0-9]:[0-9]/power -name "control"`
	do
		#echo "$loop"
		echo auto > "$loop"
		#cat "$loop"
	done

	for loop in `find /sys/bus/usb/devices/[0-9]-[0-9]/power -name "control"`
	do
		#echo "$loop"
		echo auto > "$loop"
		#cat "$loop"
	done

	#for loop in `find /sys/bus/scsi/devices/[0-9]:[0-9]:[0-9]:[0-9]/power -name "runtime_status"`
	#do
	#	echo "$loop"
	#	cat "$loop"
	#done
	#for loop in `find /sys/bus/usb/devices/[0-9]-[0-9]/power -name "runtime_status"`
	#do
	#	echo "$loop"
	#	cat "$loop"
	#done


done
