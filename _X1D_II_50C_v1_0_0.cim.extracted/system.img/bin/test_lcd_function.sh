#########################################################################
# File Name: test_lcd_function.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 28 Apr 2018 10:20:38 AM CST
#########################################################################
# Author: johnny.du
# mail:johnny.du@dji.com
# modefied Time: 2018/10/10
# version: v1.1
#########################################################################
#!/bin/bash

eagle_button()
{
    local iso_wb_button_keyword="KEY_F5"
    local af_mf_button_keyword="KEY_F4"

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
    #stop preview
    setprop ctl.stop preview_daemon
    if [ $? != 0 ]; then
        echo "stop preview fail"
        return 3
    fi
    #stop compositor
    setprop ctl.stop compositor
    if [ $? != 0 ]; then
        echo "stop compositor fail"
        return 4
    fi
    sleep 2
    return 0
}

eagle_lcd_function()
{
    #needed to have time to close the last test before starting the new one
    sleep 2
    #run test_lcd to test lcd

    if [ $PROD_TYPE = $PROD_TYPE_CFV ]; then
        case $1 in
        1) test_lcd -d 1 -s 36000 -f /data/dji/CHESS5_640x480.RGBA;;
        2) test_lcd -d 1 -s 36000 -f /data/dji/L128_640x480.RGBA;;
        3) test_lcd -d 1 -s 36000 -f /data/dji/7_640x480.RGBA;;
        4) test_lcd -d 1 -s 36000 -f /data/dji/ALL_640x480.RGBA;;
        5) test_lcd -d 1 -s 36000 -f /data/dji/B_640x480.RGBA;;
        6) test_lcd -d 1 -s 36000 -f /data/dji/G_640x480.RGBA;;
        7) test_lcd -d 1 -s 36000 -f /data/dji/G0_640x480.RGBA;;
        8) test_lcd -d 1 -s 36000 -f /data/dji/G64_640x480.RGBA;;
        9) test_lcd -d 1 -s 36000 -f /data/dji/G128_640x480.RGBA;;
        10) test_lcd -d 1 -s 36000 -f /data/dji/G255_640x480.RGBA;;
        11) test_lcd -d 1 -s 36000 -f /data/dji/GSH_640x480.RGBA;;
        12) test_lcd -d 1 -s 36000 -f /data/dji/GSV_640x480.RGBA;;
        13) test_lcd -d 1 -s 36000 -f /data/dji/R_640x480.RGBA;;
        14) test_lcd -d 1 -s 36000 -f /data/dji/CBV_640x480.RGBA;;
        esac
    elif [ $PROD_TYPE = $PROD_TYPE_X1DM2 ]; then
        case $1 in
        1) test_lcd -d 2 -s 36000 -f /data/dji/CHESS5.RGBA;;
        2) test_lcd -d 2 -s 36000 -f /data/dji/L128.RGBA;;
        3) test_lcd -d 2 -s 36000 -f /data/dji/7.RGBA;;
        4) test_lcd -d 2 -s 36000 -f /data/dji/ALL.RGBA;;
        5) test_lcd -d 2 -s 36000 -f /data/dji/B.RGBA;;
        6) test_lcd -d 2 -s 36000 -f /data/dji/G.RGBA;;
        7) test_lcd -d 2 -s 36000 -f /data/dji/G0.RGBA;;
        8) test_lcd -d 2 -s 36000 -f /data/dji/G64.RGBA;;
        9) test_lcd -d 2 -s 36000 -f /data/dji/G128.RGBA;;
        10) test_lcd -d 2 -s 36000 -f /data/dji/G255.RGBA;;
        11) test_lcd -d 2 -s 36000 -f /data/dji/GSH.RGBA;;
        12) test_lcd -d 2 -s 36000 -f /data/dji/GSV.RGBA;;
        13) test_lcd -d 2 -s 36000 -f /data/dji/R.RGBA;;
        14) test_lcd -d 2 -s 36000 -f /data/dji/CBV.RGBA;;
        esac
    fi
#    if [ $? != 0 ]; then
#        echo "test LCD fail"
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
    #start preview
    setprop ctl.start preview_daemon
    if [ $? != 0 ]; then
        echo "start preview fail"
        return 7
    fi
    #start gui
    setprop ctl.start gui
    if [ $? != 0 ]; then
        echo "start gui fail"
        return 8
    fi
    echo "lcd link test pass"
    eagle_lcd_link_test
    return 0
}

choose_picture()
{
    local idx=1
    idx=$1
    echo "lcd test start"
    case $idx in
    1) echo "1"
    eagle_lcd_function $idx &;;
    2) echo "2"
    eagle_lcd_function $idx &;;
    3) echo "3"
    eagle_lcd_function $idx &;;
    4) echo "4"
    eagle_lcd_function $idx &;;
    5) echo "5"
    eagle_lcd_function $idx &;;
    6) echo "6"
    eagle_lcd_function $idx &;;
    7) echo "7"
    eagle_lcd_function $idx &;;
    8) echo "8"
    eagle_lcd_function $idx &;;
    9) echo "9"
    eagle_lcd_function $idx &;;
    10) echo "10"
    eagle_lcd_function $idx &;;
    11) echo "11"
    eagle_lcd_function $idx &;;
    12) echo "12"
    eagle_lcd_function $idx &;;
    13) echo "13"
    eagle_lcd_function $idx &;;
    14) echo "14"
    eagle_lcd_function $idx &;;
    esac
}

local max_val=4
local idx=0
local flag=0
local ret=0
local ID
PROD_TYPE=$(getprop dji.prod_type)
echo "PROD_TYPE is $PROD_TYPE"
PROD_TYPE_X1DM2=12
PROD_TYPE_CFV=14
close_gui
while true; do
    eagle_button
    ret=$?
    echo "key press:$ret"
    if [ $ret = 1 ]; then
        idx=$(($idx+1))
        if [ $flag != 0 ]; then
            ID=$(ps | grep "test_lcd" | grep -v "grep" | busybox awk '{print $2}')
            echo "Old ID of test_lcd is $ID"
            kill -s 2 $ID
        fi
        echo "$ret key number is:$idx"
        choose_picture $idx
        if [ $idx -eq 14 ]; then
            idx=0
        fi
        echo "lcd test end"
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
            echo "Old ID of test_lcd is $ID"
            kill -s 2 $ID
        fi
        echo "$ret key number is:$idx"
        choose_picture $idx
        echo "lcd test end"
        flag=1
    fi
done
