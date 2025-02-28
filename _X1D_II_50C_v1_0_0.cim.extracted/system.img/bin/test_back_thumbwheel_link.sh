#########################################################################
# File Name: test_back_thumbwheel_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Wed 28 Mar 2018 02:22:07 PM CST
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

eagle_back_thumbwheel_link_test()
{
    local event="/dev/input/event1"
    local back_tw_keyword_u="KEY_UP"
    local back_tw_keyword_d="KEY_DOWN"

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
                grep "$back_tw_keyword_u" /blackbox/system/event.log
                if [ $? = 0 ]; then
                    grep "$back_tw_keyword_d" /blackbox/system/event.log
                    if [ $? = 0 ]; then
                        echo "pass back thumbwheel link test"
                        #open event2
                        echo 1 > /sys/bus/i2c/devices/4-001e/enable_device
                        rm -r /blackbox/system/event.log
                        return 0
                    else
                        getevent -l -c 1 >> /blackbox/system/event.log &
                        continue
                    fi
                else
                    grep "$back_tw_keyword_d" /blackbox/system/event.log
                    if [ $? = 0 ]; then
                        grep "$back_tw_keyword_u" /blackbox/system/event.log
                        if [ $? = 0 ]; then
                            echo "pass back thumbwheel link test"
                            #open event2
                            echo 1 > /sys/bus/i2c/devices/4-001e/enable_device
                            rm -r /blackbox/system/event.log
                            return 0
                        else
                            getevent -l -c 1 >> /blackbox/system/event.log &
                            continue
                        fi
                    else
                        getevent -l -c 1 >> /blackbox/system/event.log &
                        continue
                    fi
                fi
            else
                getevent -l -c 1 >> /blackbox/system/event.log &
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
        grep "$back_tw_keyword_u" /blackbox/system/event.log
        if [ $? = 0 ]; then
            grep "$back_tw_keyword_d" /blackbox/system/event.log
            if [ $? = 0 ]; then
                echo "pass back thumbwheel link test"
                rm -r /blackbox/system/event.log
                return 0
            else
                echo "no back thumbwheel down operation"
                rm -r /blackbox/system/event.log
                return 1
            fi
        else
            grep "$back_tw_keyword_d" /blackbox/system/event.log
            if [ $? = 0 ]; then
                grep "$back_tw_keyword_u" /blackbox/system/event.log
                if [ $? = 0 ]; then
                    echo "pass back thumbwheel link test"
                    rm -r /blackbox/system/event.log
                    return 0
                else
                    echo "no back thumbwheel up operation"
                    rm -r /blackbox/system/event.log
                    return 2
                fi
            else
                echo "no back thumbwheel operation"
                rm -r /blackbox/system/event.log
                return 3
            fi
        fi
    else
        echo "can not find event.log"
        return 4
    fi
}

eagle_back_thumbwheel_link_test
exit $?
