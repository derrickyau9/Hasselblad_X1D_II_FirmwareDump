#########################################################################
# File Name: test_evf_function.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 28 Apr 2018 10:20:38 AM CST
#########################################################################
#!/bin/bash

eagle_button()
{
    local iso_wb_button_keyword="KEY_I"
    local af_mf_button_keyword="KEY_F"

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
                grep "$iso_wb_button_keyword" /blackbox/system/event.log
                #if it is not iso_wb_button try again
                if [ $? != 0 ]; then
                    grep "$af_mf_button_keyword" /blackbox/system/event.log
                    if [ $? != 0 ]; then
                        getevent -l -c 1 > /blackbox/system/event.log
                        continue
                    else
                        echo "pass AF/MF button link test"
                        #open event2
                        echo 1 > /sys/bus/i2c/devices/4-001e/enable_device
                        kill -9 $ID
                        return 2
                    fi
                else
                    echo "pass ISO/WB button link test"
                    #open event2
                    echo 1 > /sys/bus/i2c/devices/4-001e/enable_device
                    kill -9 $ID
                    return 1
                fi
            else
                getevent -l -c 1 > /blackbox/system/event.log
                continue
            fi
        fi
#        if [ $(elapsed) -ge $timeout ]; then
#            kill -9 $ID
#            break
#        fi
    done

    #open event2
    echo 1 > /sys/bus/i2c/devices/4-001e/enable_device
#    if [ -f /blackbox/system/event.log ]; then
#        grep "$iso_wb_button_keyword" /blackbox/system/event.log
#        if [ $? != 0 ]; then
#            echo "no ISO/WB button operation"
#            return 1
#        else
#            echo "pass ISO/WB button link test"
#            return 0
#        fi
#    else
#        echo "can not find event.log"
#        return 2
#    fi
}

close_gui()
{
    #find weston service
    ps | grep weston
    if [ $? != 0 ]; then
        echo "can not find weston"
        return 1
    fi
    #stop gui
    setprop ctl.stop gui
    if [ $? != 0 ]; then
        echo "stop gui fail"
        return 2
    fi
    #stop compositor
    setprop ctl.stop compositor
    if [ $? != 0 ]; then
        echo "stop compositor fail"
        return 3
    fi
    sleep 2
    return 0
}

eagle_evf_function()
{
    #run test_lcd to test evf
    case $1 in
    1) test_lcd -d 0 -s 36000 -f /data/dji/p1.yuv -m 0;;
    2) test_lcd -d 0 -s 36000 -f /data/dji/p2.yuv -m 0;;
    3) test_lcd -d 0 -s 36000 -f /data/dji/p3.yuv -m 0;;
    4) test_lcd -d 0 -s 36000 -f /data/dji/p4.yuv -m 0;;
    5) test_lcd -d 0 -s 36000 -f /data/dji/p5.yuv -m 0;;
    6) test_lcd -d 0 -s 36000 -f /data/dji/p6.yuv -m 0;;
    7) test_lcd -d 0 -s 36000 -f /data/dji/p7.yuv -m 0;;
    8) test_lcd -d 0 -s 36000 -f /data/dji/p8.yuv -m 0;;
    9) test_lcd -d 0 -s 36000 -f /data/dji/p9.yuv -m 0;;
    10) test_lcd -d 0 -s 36000 -f /data/dji/p10.yuv -m 0;;
    11) test_lcd -d 0 -s 36000 -f /data/dji/p11.yuv -m 0;;
    12) test_lcd -d 0 -s 36000 -f /data/dji/p12.yuv -m 0;;
    13) test_lcd -d 0 -s 36000 -f /data/dji/p13.yuv -m 0;;
    14) test_lcd -d 0 -s 36000 -f /data/dji/p14.yuv -m 0;;
    esac
#    if [ $? != 0 ]; then
#        echo "test EVF fail"
#        setprop ctl.start compositor
#        setprop ctl.start gui
#        return 4
#    fi
    return 0
}

open_gui()
{
    #start compositor
    setprop ctl.start compositor
    if [ $? != 0 ]; then
        echo "start compositor fail"
        return 6
    fi
    #start gui
    setprop ctl.start gui
    if [ $? != 0 ]; then
        echo "start gui fail"
        return 7
    fi
    echo "evf link test pass"
    eagle_lcd_link_test
    return 0
}

choose_picture()
{
    local idx=1
    idx=$1
    echo "evf test start"
    case $idx in
    1) echo "1"
    eagle_evf_function $idx &;;
    2) echo "2"
    eagle_evf_function $idx &;;
    3) echo "3"
    eagle_evf_function $idx &;;
    4) echo "4"
    eagle_evf_function $idx &;;
    5) echo "5"
    eagle_evf_function $idx &;;
    6) echo "6"
    eagle_evf_function $idx &;;
    7) echo "7"
    eagle_evf_function $idx &;;
    8) echo "8"
    eagle_evf_function $idx &;;
    9) echo "9"
    eagle_evf_function $idx &;;
    10) echo "10"
    eagle_evf_function $idx &;;
    11) echo "11"
    eagle_evf_function $idx &;;
    12) echo "12"
    eagle_evf_function $idx &;;
    13) echo "13"
    eagle_evf_function $idx &;;
    14) echo "14"
    eagle_evf_function $idx &;;
    esac
}

local max_val=4
local idx=0
local flag=0
local ret=0
local ID
close_gui
while true; do
    eagle_button
    ret=$?
    if [ $ret = 1 ]; then
        idx=$(($idx+1))
        if [ $flag != 0 ]; then
            ID=$(ps | grep "test_lcd" | grep -v "grep" | busybox awk '{print $2}')
            kill -s 2 $ID
            while true; do
                ID=$(ps | grep "test_lcd" | grep -v "grep" | busybox awk '{print $2}')
                if [ -z $ID ]; then
                    break
                fi
            done
        fi
        choose_picture $idx
        if [ $idx -eq 14 ]; then
            idx=0
        fi
        echo "evf test end"
        flag=1
    fi
    if [ $ret = 2 ]; then
        if [ $idx -eq 0 ]; then
            idx=14
        fi
        idx=$(($idx-1))
        if [ $idx -eq 0 ]; then
            idx=14
        fi
        if [ $flag != 0 ]; then
            ID=$(ps | grep "test_lcd" | grep -v "grep" | busybox awk '{print $2}')
            kill -s 2 $ID
            while true; do
                ID=$(ps | grep "test_lcd" | grep -v "grep" | busybox awk '{print $2}')
                if [ -z $ID ]; then
                    break
                fi
            done
        fi
        choose_picture $idx
        echo "evf test end"
        flag=1
    fi
done
