#########################################################################
# File Name: test_mic_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Wed 28 Mar 2018 02:48:38 PM CST
#########################################################################
#!/bin/bash

# get elapsed seconds
timeout=10
elapsed()
{
    local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
    local diff=$(($now-$start))
    echo $diff
}

# run ultil timeout defined by $TIMEOUT
#   run_timeout <expression>
# example 1: run_timeout "echo 111 && sleep 5 && echo 222"
# example 2: run_timeout test_mem -s 0x800000
run_timeout()
{
    echo run_timeout: $*
    while [ $(elapsed) -le $timeout ]
    do
        eval $*
    done
}

eagle_photo_button_link_test()
{
    local event="/dev/input/event5"
    local photo_button_keyword="KEY_A"
    local photo_button_keyword_E="KEY_E"

    #close event2
    echo 0 > /sys/bus/i2c/devices/4-001e/enable_device
    #getevent
    getevent -l -c 4 > /blackbox/system/event.log &

    start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
    while true
    do
        local ID=$(ps | grep "getevent" | grep -v "grep" | busybox awk '{print $2}')
        if [ -z $ID ];then
            if [ -f /blackbox/system/event.log ]; then
                grep "$photo_button_keyword" /blackbox/system/event.log
                #if it is not photo_button try again
                if [ $? != 0 ]; then
                    getevent -l -c 4 > /blackbox/system/event.log &
                    continue
                else
                    grep "$photo_button_keyword_E" /blackbox/system/event.log
                    #if it is not photo_button try again
                    if [ $? != 0 ]; then
                        getevent -l -c 4 > /blackbox/system/event.log &
                        continue
                    else
                        echo "pass photo button link test"
                        #open event2
                        echo 1 > /sys/bus/i2c/devices/4-001e/enable_device
                        return 0
                    fi
                fi
            else
                getevent -l -c 4 > /blackbox/system/event.log &
                continue
            fi
        fi
        if [ $(elapsed) -ge $timeout ]; then
            kill -9 $ID
            break
        fi
    done

    #open event2
    echo 1 > /sys/bus/i2c/devices/4-001e/enable_device

    if [ -f /blackbox/system/event.log ]; then
        grep "$photo_button_keyword" /blackbox/system/event.log
        if [ $? != 0 ]; then
            echo "no photo button operation"
            return 1
        else
            grep "$photo_button_keyword_E" /blackbox/system/event.log
            if [ $? != 0 ]; then
                echo "no photo button operation"
                return 2
            else
                echo "pass photo button link test"
                return 0
            fi
        fi
    else
        echo "can not find event.log"
        return 2
    fi
}

eagle_photo_button_link_test
exit $?
