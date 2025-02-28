#########################################################################
# File Name: test_ambient_light_sensor.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 27 Mar 2018 08:24:45 PM CST
#########################################################################
#!/bin/bash

eagle_ambient_light_sensor_link_test()
{
    local r
    local tmp
    local i=1
    #config ambient light sensor
    echo 0.4 > /sys/bus/iio/devices/iio:device0/in_illuminance_integration_time
    r=$?
    if [ $r != 0 ]; then
        echo "config integration time fail"
        return 1
    fi
    #config hardware gain
    echo 128.64 > /sys/bus/iio/devices/iio:device0/in_illuminance_hardwaregain
    r=$?
    if [ $r != 0 ]; then
        echo "config hardware gain fail"
        return 2
    fi
    #get value
    local val=$(cat /sys/bus/iio/devices/iio:device0/in_illuminance_raw | busybox awk '{print $1}')
    r=$?
    if [ $r != 0 ]; then
        echo "get illuminance raw fail"
        return 3
    else
        for i in $(seq 1 5)
        do
            sleep 1
            tmp=$(cat /sys/bus/iio/devices/iio:device0/in_illuminance_raw | busybox awk '{print $1}')
            r=$?
            if [ $r != 0 ]; then
                echo "get illuminance raw fail"
                return 4
            fi
            if [ $tmp != $val ]; then
                echo "ambient light sensor link test pass"
                echo "$tmp!=$val"
                return 0
            fi
        done
    fi
    echo "no illuminance operation"
    return 5
}

eagle_ambient_light_sensor_link_test
exit $?
