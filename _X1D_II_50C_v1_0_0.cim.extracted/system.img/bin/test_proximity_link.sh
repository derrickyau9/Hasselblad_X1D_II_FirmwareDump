#########################################################################
# File Name: test_proximity_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 27 Mar 2018 07:38:41 PM CST
#########################################################################
#!/bin/bash

eagle_proximity_link_test()
{
    local r
        local i=1
    local tmp
    #config proximity sensor
    echo 0.4 > /sys/bus/iio/devices/iio:device0/in_proximity_integration_time
    r=$?
    if [ $r != 0 ]; then
        echo "config proximity sensor fail"
        return 1
    fi
    #threshold_high
    echo 256 > /sys/bus/iio/devices/iio:device0/events/in_proximity_thresh_either_value
    r=$?
    if [ $r != 0 ]; then
        echo "set threshold_high fail"
        return 2
    fi
    #hysteresis (threshold_low = threshold_high - hysteresis)
    echo 192 > /sys/bus/iio/devices/iio:device0/events/in_proximity_thresh_either_hysteresis
    r=$?
    if [ $r != 0 ]; then
        echo "set threshold_low fail"
        return 3
    fi
    echo 1 > /sys/bus/iio/devices/iio:device0/events/in_proximity_thresh_either_en
    r=$?
    if [ $r != 0 ]; then
        echo "set threshold enable fail"
        return 4
    fi

    local val=$(cat /sys/bus/iio/devices/iio:device0/in_proximity_raw | busybox awk '{print $1}')
    r=$?
    if [ $r != 0 ]; then
        echo "get proximity raw fail"
        return 5
    else
        for i in $(seq 1 10)
        do
            sleep 1
            tmp=$(cat /sys/bus/iio/devices/iio:device0/in_proximity_raw | busybox awk '{print $1}')
            r=$?
            if [ $r != 0 ]; then
                echo "get proximity raw fail"
                return 6
            fi
            if [ $tmp != $val ]; then
                echo "proximity link test pass"
                return 0
            fi
        done
    fi
    echo "no proximity operation"
    return 7
}

eagle_proximity_link_test
exit $?

