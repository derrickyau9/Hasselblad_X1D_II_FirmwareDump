#########################################################################
# File Name: test_rtc_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 27 Mar 2018 08:44:36 PM CST
#########################################################################
#!/bin/bash

eagle_rtc_link_test()
{
    local r
    #get system clock
    local system_date=$(busybox date +%Y.%m.%d-%H:%M:%S)
    r=$?
    if [ $r != 0 ]; then
        echo "get system clock fail"
        return 1
    fi
    #set system clock:2000.01.01 00:00:00
    busybox date -s 2000.01.01-00:00:00
    r=$?
    if [ $r != 0 ]; then
        echo "set system clock fail"
        return 2
    fi
    #get RTC clock
    local rtc_date=$(busybox hwclock -r)
    r=$?
    if [ $r != 0 ]; then
        echo "get RTC clock fail"
        return 4
    fi

    local date_tmp=$(echo $rtc_date | busybox awk '{print $5}')
    r=$?
    if [ $r != 0 ]; then
        echo "get year of RTC clock fail"
        return 5
    fi
    if [ $date_tmp = "2000" ];then
        echo "RTC link is ok"
    fi
    #set system clock
    busybox date -s $system_date
    r=$?
    if [ $r != 0 ]; then
        echo "set system clock fail"
        return 6
    fi
    #set system clock to RTC
    busybox hwclock -w
    r=$?
    if [ $r != 0 ]; then
        echo "set system clock to RTC fail"
        return 3
    fi

    return 0
}

eagle_rtc_link_test
exit $?
