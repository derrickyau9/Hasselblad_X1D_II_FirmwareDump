#!/system/bin/sh

if [ $# != 2 ]
then
    echo "Usage: $0 loop interval"
exit 1
fi

echo This scrip switch cpu freq one by one:1363000 1200000 600000 400000 300000
echo Take about 10*$1*$2 seconds

loop_max=$1
time=$2
loop_cnt=0
switch_cnt=0
fail_cnt=0
pass_cnt=0
log=`date +%F-%T`

echo userspace > /sys/bus/cpu/devices/cpu0/cpufreq/scaling_governor

freq_judge(){
    pre=$1
    tar=$2

    echo $pre > /sys/bus/cpu/devices/cpu0/cpufreq/scaling_setspeed
    echo $tar > /sys/bus/cpu/devices/cpu0/cpufreq/scaling_setspeed

    curfreq=`cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_cur_freq`
    if [ $curfreq != $tar ]
    then
        echo $pre to $tar Failed
        fail_cnt=`expr $fail_cnt + 1`
    else
        echo $pre to $tar Pass
        pass_cnt=`expr $pass_cnt + 1`
    fi

    sleep $time
    switch_cnt=`expr $switch_cnt + 1`
}

while [ $loop_cnt -lt $loop_max ]
do
    freq_judge 1363000 1200000

    freq_judge 1363000 600000

    freq_judge 1363000 400000

    freq_judge 1363000 300000

    freq_judge 1200000 600000

    freq_judge 1200000 400000

    freq_judge 1200000 300000

    freq_judge 600000 400000

    freq_judge 600000 300000

    freq_judge 400000 300000

    loop_cnt=`expr $loop_cnt + 1`
done

echo dvfs userspace switch result:Total:$switch_cnt, Fail:$fail_cnt, Pass:$pass_cnt

if [ $fail_cnt != 0 ]
then
    echo Test Fail!
    exit 1
else
    echo Test Pass!
    exit 0
fi
