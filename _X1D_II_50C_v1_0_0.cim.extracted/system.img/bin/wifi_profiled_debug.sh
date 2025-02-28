#! /system/bin/sh

### BEGIN INFO
# Used to capture profiled wifi log
# ath6kl_usb device.
# Provides:    Gannicus Guo
### END INFO

kill_sync()
{
    echo "Request to kill: $1"
    kill -9 $1
    ps $1 | busybox grep "logcat"
    while [ $? == 0 ]
    do
        ps $1 | busybox grep "logcat"
        if [ $? != 0 ]
        then
            echo "target process: $1 killed"
            break
        else
            kill -9 $1
            sleep 0.1
        fi
    done
}

FILE_SIZE=10485760

# Wifi log
echo -e "\n\n!!!New file start!!!\n" >> /blackbox/system/wifi00.log
logcat -v time *:W |stdbuf -oL  busybox grep -e hostapd -e "DUSS&5c" >> /blackbox/system/wifi00.log &
#logcat -v time | grep hostapd >> /blackbox/system/wifi00.log &
JOBPPID=$$
while true
do
    wifi_logfile_size=`busybox wc -c < /blackbox/system/wifi00.log`
    if [ $wifi_logfile_size -gt $FILE_SIZE ]; then
        LOGCATPID=`busybox pgrep -l -P ${JOBPPID} | busybox grep logcat | busybox awk '{print $1}'`
        echo "Kill current job: ${LOGCATPID}" >> /blackbox/system/wifi00.log
#the grep process automatically exit after killing logcat
        kill_sync $LOGCATPID
        mv /blackbox/system/wifi08.log /blackbox/system/wifi09.log
        mv /blackbox/system/wifi07.log /blackbox/system/wifi08.log
        mv /blackbox/system/wifi06.log /blackbox/system/wifi07.log
        mv /blackbox/system/wifi05.log /blackbox/system/wifi06.log
        mv /blackbox/system/wifi04.log /blackbox/system/wifi05.log
        mv /blackbox/system/wifi03.log /blackbox/system/wifi04.log
        mv /blackbox/system/wifi02.log /blackbox/system/wifi03.log
        mv /blackbox/system/wifi01.log /blackbox/system/wifi02.log
        mv /blackbox/system/wifi00.log /blackbox/system/wifi01.log
        logcat -v time *:W |stdbuf -oL busybox grep -e hostapd -e "DUSS&5c" >> /blackbox/system/wifi00.log &
        echo "New wifi job" >> /blackbox/system/wifi00.log
    fi
    sleep 5
done
