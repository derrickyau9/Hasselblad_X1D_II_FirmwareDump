#########################################################################
# File Name: test_touch_panel_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Wed 28 Mar 2018 11:03:30 AM CST
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

eagle_touch_panel_link_test()
{
    local r
    local event="/dev/input/event6"
    local tp_keyword="ABS_MT_POSITION_X"

    #close event2
    echo 0 > /sys/bus/i2c/devices/4-001e/enable_device
    #getevent
    getevent -l -c 8 > /blackbox/system/event.log &

    start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
    while true
    do
        local ID=$(ps | grep "getevent" | grep -v "grep" | busybox awk '{print $2}')
        if [ -z $ID ];then
            if [ -f /blackbox/system/event.log ]; then
                grep "$tp_keyword" /blackbox/system/event.log
                #if it is not tp try again
                if [ $? != 0 ]; then
                    getevent -l -c 8 > /blackbox/system/event.log &
                    continue
                else
                    echo "pass tp link test"
                    #open event2
                    echo 1 > /sys/bus/i2c/devices/4-001e/enable_device
                    return 0
                fi
            else
                getevent -l -c 8 > /blackbox/system/event.log &
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
        grep "$tp_keyword" /blackbox/system/event.log
        r=$?
        if [ $r -ne 0 ]; then
            echo "no touch panel operation"
            rm -r /blackbox/system/event.log
            return 1
        else
            echo "pass touch panel link test"
            rm -r /blackbox/system/event.log
            return 0
        fi
    else
        echo "can not find event.log"
        return 2
    fi
}

eagle_touch_panel_link_test
exit $?
