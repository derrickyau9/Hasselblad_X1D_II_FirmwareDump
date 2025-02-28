#########################################################################
# File Name: test_lens_button_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 03 Jul 2018 11:53:55 AM CST
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

eagle_lens_button_link_test()
{
    local event="/dev/input/event7"
    local lens_button_keyword="KEY_S"

    #close event2
    echo 0 > /sys/bus/i2c/devices/4-001e/enable_device
    #getevent
    getevent -l -c 1 > /blackbox/system/event.log &

    start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
    while true
    do
        local ID=$(ps | grep "getevent" | grep -v "grep" | busybox awk '{print $2}')
        if [ -z $ID ];then
            if [ -f /blackbox/system/event.log ]; then
                grep "$lens_button_keyword" /blackbox/system/event.log
                #if it is not lens_button try again
                if [ $? != 0 ]; then
                    getevent -l -c 1 > /blackbox/system/event.log &
                    continue
                else
                    echo "pass lens button link test"
                    #open event2
                    echo 1 > /sys/bus/i2c/devices/4-001e/enable_device
                    return 0
                fi
            else
                getevent -l -c 1 > /blackbox/system/event.log &
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
        grep "$lens_button_keyword" /blackbox/system/event.log
        if [ $? != 0 ]; then
            echo "no lens button operation"
            return 1
        else
            echo "pass lens button link test"
            return 0
        fi
    else
        echo "can not find event.log"
        return 2
    fi
}

eagle_lens_button_link_test
exit $?
