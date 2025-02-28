### This script is used to correct system time
### after each reboot. It saves system time every
### second, and load the time once it is started.
### This can avoid jumping back to 1980, which mess
### up sd card data.

#!/system/bin/sh

RecordFile=/data/dji/time_record

# load system time if it exist
if [ -f $RecordFile ]
then
    busybox date -s "$(< $RecordFile)"
fi

while [ 1 ]
do
    busybox date +"%Y-%m-%d %H:%M:%S" > $RecordFile
    echo "<7> `date`" >> /dev/kmsg
    sleep 60
done


