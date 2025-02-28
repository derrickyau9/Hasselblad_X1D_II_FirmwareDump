#!/system/bin/sh

DBUS_NODES="ae af awb bodystate cambody camera camservice config error farmus flash metadata lens profiles pwrctrl seq storage suc sysman"
LOG_PATH=${1}
LOG_NAME=${2:-hbl-logs.tar.gz}
ENCRYPT=${3}
TMP_DIR=/blackbox/tmp
TS=$TMP_DIR/$(date +%s)
dir_tab=(blackbox/system blackbox/camera blackbox/upgrade blackbox/data blackbox/storage)
tar_dir=(0)

FILE_NAME=${LOG_NAME%%.tar.gz}
ENC_NAME=$FILE_NAME.log.enc

mkdir -p $TS

# Script that collects miscellaneous useful log data and saves it to blackbox
collect_useful_log.sh

logcat -d > $TS/logcat.txt
logcat -B -d > $TS/logcat.bin
getprop > $TS/getprop.txt
#cp -r /data/logs/error $TS/logs_error
#cp -r /data/tombstones $TS/tombstones
#cp -r /blackbox/camera $TS/blackbox_camera
#cp /data/configstore/configstore.sql $TS

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

if [ ! -d $LOG_PATH/data ]; then
	mkdir -p $LOG_PATH/data
fi

if [ $ENCRYPT = false ]; then
    mv $TMP_DIR/$LOG_NAME $LOG_PATH/data
else
    dji_log_encrypt $LOG_NAME enc
    mv /blackbox/$ENC_NAME $LOG_PATH/data
fi

rm -f $TMP_DIR/$LOG_NAME
