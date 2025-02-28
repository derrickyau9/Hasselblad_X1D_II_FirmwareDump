#!/system/bin/sh

# Here we update recovery.img since all the service should be started.
# We could make the recovery.img work before this script exit for some
# service not startup.
/system/bin/recovery_update.sh

# For debug
#enable kernel.log and wifi.log
/system/bin/wifi_profiled_debug.sh &
#debuggerd&
### CONFIG_DYNAMIC_FTRACE is set when CONFIG_FUNCTION_TRACER is set.
# Disable ftrace by default and user can enable ftrace when necessary.
echo 0 > /proc/sys/kernel/ftrace_enabled
echo 0 > /sys/kernel/debug/tracing/tracing_on

setprop dji.usb_serial 1

start_time=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
use_time()
{
	local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
	local diff=$(($now-$start_time))
	echo $diff
}
timeout=5
while [ $(use_time) -le $timeout ]
do
	sleep 0.2
	ps | busybox grep dji_sys
	ret_dji_sys=$?
	if [ $ret_dji_sys -ne 0 ]; then
		continue
	fi
	ps | busybox grep dji_monitor
	ret_dji_monitor=$?
	if [ $ret_dji_monitor -ne 0 ]; then
		continue
	fi
	echo "dji_sys and dji_monitor exist,use time:$(use_time)" > /data/dji/log/sys_monitor.log
	break
done
# check system service status and clean up crash counter.
if [ $ret_dji_sys -ne 0 ];then
	echo "crash_counter: dji_sys not exist" > /data/dji/log/crash_counter.log
	sync
	exit -1
fi

if [ $ret_dji_monitor -ne 0 ];then
	echo "crash_counter: dji_monitor not exist" > /data/dji/log/crash_counter.log
	sync
	exit -1
fi

unrd -s wipe_counter 0

# Check whether do auto reboot test
if [ -f /data/dji/cfg/test/reboot ]; then
	sleep 20
	reboot
fi

# Check whether do auto OTA upgrade test
if [ -f /data/dji/cfg/test/ota ]; then
	sleep 10
	/system/bin/test_ota.sh
fi

if [ -f /data/dji/amt/state ]; then
    amt_state=`cat /data/dji/amt/state`
    rm /data/dji/amt/state
    sync
fi

if [ "$amt_state"x == "aging_test"x ]; then
    nice -n 10 /system/bin/aging_test.sh
elif [ "$amt_state"x == "aging_test_local"x ]; then
    nice -n 10 /system/bin/aging_test_local.sh
else
    if [ -f /data/dji/cfg/temp_save_en ]; then
        test_temperature.sh 5 save &
    fi
    if [ -f /data/dji/cfg/perf_save_en ]; then
        test_save_perf.sh &
    fi
fi

# Setup digital microphone and speaker
mic_state=`cat /sys/devices/platform/sound/mic_jack_state`
if [ "$mic_state"x == "removed"x ]; then
	cs47l35-dmic-config.sh
elif [ "$mic_state"x == "inserted"x ]; then
	cs47l35-mic-config.sh
fi

