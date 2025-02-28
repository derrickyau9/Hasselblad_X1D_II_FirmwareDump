#!/system/bin/sh

if [ $# != 2 ]
then
    echo "Usage: $0 loop interval"
exit 1
fi

echo This scrip switch cpu freq randomly:1363000 1200000 600000 400000 300000
echo Take about $1*$2 seconds

#echo Log Path:/data/dvfs-userspace-random-xxxx.log

loop_cnt=0
time=$2
loop_max="$1"
mode=5
fail_cnt=0
pass_cnt=0
log=`date +%F-%T`

echo userspace > /sys/bus/cpu/devices/cpu0/cpufreq/scaling_governor
cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_governor

rand () {
    min=$1
    max=$(($2-$min+1))
    num=$(date +%sN)
    echo $(($num%$max+$min))
}

freq_switch(){
    curfreq=`cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_cur_freq`

    echo $1 > /sys/bus/cpu/devices/cpu0/cpufreq/scaling_setspeed
    tarfreq=`cat /sys/bus/cpu/devices/cpu0/cpufreq/scaling_cur_freq`

    if [ $1 != $tarfreq ]
    then
        echo $curfreq to $1 Failed
        fail_cnt=`expr $fail_cnt + 1`
    else
        echo $curfreq to $1 Pass
        pass_cnt=`expr $pass_cnt + 1`
    fi

    sleep $time
}

while [ $loop_cnt -lt $loop_max ]
do
    #index=$(rand 1 5)
    index=`expr $RANDOM % 5`

    case $index in
    0)
        freq_switch 300000
    ;;
    1)
        freq_switch 400000
    ;;
    2)
        freq_switch 600000
    ;;
    3)
        freq_switch 1200000
    ;;
    4)
        freq_switch 1363000
    ;;
   esac

    loop_cnt=`expr $loop_cnt + 1`
done

echo dvfs random switch result:Total:$loop_cnt, Fail:$fail_cnt, Pass:$pass_cnt

if [ $fail_cnt != 0 ]
then
    echo Test Fail!
    exit 1
else
    echo Test Pass!
    exit 0
fi
