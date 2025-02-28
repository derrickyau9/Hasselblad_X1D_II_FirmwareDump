#!/system/bin/sh


GPS_EN_GPIO_NUM=19
GPIO_SYS_PATH=/sys/class/gpio
TTY_UART=/dev/ttyS2

function legacy_hardware_fix()
{
    PROD_TYPE_X1DM2=12
    PROD_TYPE=`getprop dji.prod_type`
    HW_REV=`getprop dji.hw_rev`

    if [ $PROD_TYPE = $PROD_TYPE_X1DM2 ]; then
        if [ $HW_REV -ge 2 ]; then
            TTY_UART=/dev/ttyS3
        fi
    fi
}

function poweron_gps()
{
    echo ${GPS_EN_GPIO_NUM} > ${GPIO_SYS_PATH}/export
    echo out > ${GPIO_SYS_PATH}/gpio${GPS_EN_GPIO_NUM}/direction
    echo 1 > ${GPIO_SYS_PATH}/gpio${GPS_EN_GPIO_NUM}/value
}

function poweroff_gps()
{
    echo ${GPS_EN_GPIO_NUM} > ${GPIO_SYS_PATH}/export
    echo out > ${GPIO_SYS_PATH}/gpio${GPS_EN_GPIO_NUM}/direction
    echo 0 > ${GPIO_SYS_PATH}/gpio${GPS_EN_GPIO_NUM}/value
    echo ${GPS_EN_GPIO_NUM} > ${GPIO_SYS_PATH}/unexport
}

output_snr()
{
    #get num table
    local num_table=$(busybox grep -nr "SV Num" /blackbox/system/gps.log | busybox awk '{print $4}')
    #convert to array
    tab=($num_table)
    local len=${#tab[@]}
    #get mux num
    local i=1
    local max_idx=0
    local max_num=0
    for i in $(seq $len)
    do
    if [ "$max_num" -lt $((${tab[i]})) ]; then
        max_num=${tab[i]}
        max_idx=$i
    fi
    done
    if [ $max_num = 0 ]; then
         echo "SV Num:0"
         return 1
    fi
    #get the line num of max num
    local line_str=$(busybox grep -nr "SV Num" /blackbox/system/gps.log | busybox awk -F: '{print $1}')
    #convert to array
    line_tab=($line_str)
    local line_len=${#line_tab[@]}
    local stop_line=${line_tab[$(($max_idx))]}
    #output info
    sed -n "$(($stop_line-$max_num)),$(($stop_line-1))p" /blackbox/system/gps.log

    return 0
}

legacy_hardware_fix
poweron_gps
test_gps -s $TTY_UART -t 90000000 -b 9600 > /blackbox/system/gps.log.tmp &
sleep 93
cat -v /blackbox/system/gps.log.tmp | tr -d '^M''^@' > blackbox/system/gps.log
if [ -f /blackbox/system/gps.log.tmp ]; then
   rm /blackbox/system/gps.log.tmp
fi
output_snr
if [ $? != 0 ]; then
    echo "test gps fail"
    poweroff_gps
    exit 1
fi
if [ -f /blackbox/system/gps.log ]; then
    grep "SV info" /blackbox/system/gps.log > /dev/null
    if [ $? != 0 ]; then
        echo "gps test fail"
        poweroff_gps
        exit 1
    else
        echo "gps test pass"
    fi
fi
poweroff_gps
exit 0
