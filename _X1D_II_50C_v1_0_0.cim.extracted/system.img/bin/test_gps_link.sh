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

legacy_hardware_fix
poweron_gps
test_gps -s $TTY_UART -t 5000000 -b 9600 > /blackbox/system/gps.log &
sleep 2
if [ $? != 0 ]; then
    echo "test gps fail"
    poweroff_gps
    exit 1
fi
if [ -f /blackbox/system/gps.log ]; then
    grep "Longitude" /blackbox/system/gps.log > /dev/null
    if [ $? != 0 ]; then
        echo "gps link test fail"
        poweroff_gps
        exit 2
    else
        echo "gps link test pass"
    fi
fi
poweroff_gps
exit 0
