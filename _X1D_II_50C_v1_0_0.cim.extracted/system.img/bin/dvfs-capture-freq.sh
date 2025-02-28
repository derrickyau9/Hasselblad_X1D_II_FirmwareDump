#!/system/bin/sh

if [ $# != 1 ]
then
    echo "Usage: $0 loop"
exit 1
fi

echo This scrip capture current cpu freq
echo Take about 0.1*$1 seconds
#echo Log path:/data/dvfs-cpufreq-xxxx.log

loop_cnt=0
loop_max="$1"
name=`date +%F-%T`
#echo interactive > /sys/bus/cpu/devices/cpu0/cpufreq/scaling_governor

while [ $loop_cnt -le $loop_max ]
do
    cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_cur_freq
    sleep 0.1
    loop_cnt=`expr $loop_cnt + 1`
done
echo Test Pass!
exit 0
