#!/system/bin/sh

DBUS_NODES="ae af awb bodystate cambody camera camservice config error farmus flash metadata lens profiles pwrctrl seq storage suc sysman"
LOG_PATH=${1:-/blackbox}
LOG_NAME=${2:-hbl-logs.tar.gz}
TMP_DIR=/blackbox/tmp
TS=$TMP_DIR/$(date +%s)
dir_tab=(blackbox/system blackbox/camera blackbox/upgrade blackbox/storage blackbox/tmp)
tar_dir=(0)

sd_dir1=/storage/sdcard0
sd_dir2=/storage/sdcard1
sd_dir=unknown
SD_DIR=unknown
FILE_NAME=${LOG_NAME%%.tar.gz}
ENC_NAME=$FILE_NAME.log.enc

function choose_sdcard()
{
	#disconnect usb
	test_hal_storage -c "0 volume detach_pc"
	ls $sd_dir1
	local ret1=$?
	ls $sd_dir2
	local ret2=$?
	if [ $ret1 = 0 ] || [ $ret2 = 0 ]; then
		if [ $ret1 = 0 ]; then
			SD_DIR=$sd_dir1;
		elif [ $ret2 = 0 ]; then
			SD_DIR=$sd_dir2;
		fi
		mkdir -p $SD_DIR/data
		echo "have sdcard in camera"
		return 0
	fi
	return 1
}

mkdir -p $TS

logcat -d > $TS/logcat.txt
logcat -B -d > $TS/logcat.bin
getprop > $TS/getprop.txt
#cp -r /data/logs/error $TS/logs_error
#cp -r /data/tombstones $TS/tombstones
#cp -r /blackbox/camera $TS/blackbox_camera
#cp /data/configstore/configstore.sql $TS

choose_sdcard
if [ $? -ne 0 ]; then
	echo "No SD card"
	return 1
fi
for n in $DBUS_NODES; do
	dbus-send --system --print-reply \
	    --dest=com.hasselblad.$n /$n org.freedesktop.DBus.Properties.GetAll \
	    string:com.hasselblad.$n > $TS/$f.properties
done
local idx=1
local count=0
for idx in $(seq ${#dir_tab[*]}); do
	if [ -d /${dir_tab[$((idx-1))]} ]; then
		tar_dir[$((count))]=${dir_tab[$((idx-1))]}
		count=$((count+1))
	fi
	idx=$((idx+1))
done
if [ ${tar_dir[0]} == '0' ]; then
	echo "no log dir"
	exit 1
fi
tar cfz $TMP_DIR/$LOG_NAME ${tar_dir[*]}
cd $TMP_DIR
aes_cbc $LOG_NAME enc
cp /blackbox/$ENC_NAME $SD_DIR/data
rm -f $TMP_DIR/$LOG_NAME
rm -f /blackbox/$ENC_NAME
exit 0
