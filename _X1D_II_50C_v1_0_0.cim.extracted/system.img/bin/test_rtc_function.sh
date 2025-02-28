#########################################################################
# File Name: test_rtc_function.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 21 Jun 2018 21:10:36 PM CST
#########################################################################
#!/bin/bash

month_tab=(00 Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
num_tab=(00 01 02 03 04 05 06 07 08 09 10 11 12)
day_tab=(00 01 02 03 04 05 06 07 08 09)
g_month=0
g_day=0
day_switch()
{
    if [ $# != 1 ]; then
        echo "the number of day parameters is error!"
        return 22
    fi
    if [ $1 -ge 1 -a $1 -le 9 ]; then
        g_day=${day_tab[$1]}
        echo "day is ${day_tab[$1]}"
    elif [ $1 -ge 10 -a $1 -le 31 ]; then
        g_day=$1
        echo "day is $g_day"
    else
        echo "the parameter of day has error:$1"
        return 23
    fi
}
month_switch()
{
    local idx=1
    if [ $# -ne 1 ]; then
        echo "parameter error!"
        return 0
    fi
    for idx in $(seq 12)
    do
        if [ "${month_tab[$idx]}" = "$1" ]; then
            g_month=${num_tab[$idx]}
            return $idx
        fi
        idx=$(($idx+1))
    done
    echo "month switch error:$1!"
    return 0
}
#$1:set/get
#$2:time string
eagle_rtc_function()
{
    local r
    local system_date
    local rtc_date
    local rtc_year
    local rtc_month_tmp
    local rtc_month
    local rtc_day
    local rtc_time
    local rtc_hour
    local rtc_minute
    local rtc_second
    local pc_year_month_day
    local pc_time
    local pc_hour
    local pc_minute
    local pc_second
    local diff_time
    local second_rtc
    local second_pc
    local diff_val=60

    if [ $# != 2 ]; then
        echo "parameter number error!"
        return 1
    fi
    if [ "$1" = "get" ]; then
        #get RTC clock
        rtc_date=$(busybox hwclock -r)
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC clock fail"
            return 2
        fi
        rtc_year=$(echo $rtc_date | busybox awk '{print $5}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC year fail"
            return 3
        fi
        rtc_month_tmp=$(echo $rtc_date | busybox awk '{print $2}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC month fail"
            return 4
        fi
        echo "month before switch:$rtc_month_tmp"
        month_switch $rtc_month_tmp
        r=$?
        if [ $r -eq 0 ]; then
            return 5
        fi
        echo "rtc_date:$rtc_date"
        echo "month after switch:r=$r,g_month=$g_month"
        rtc_month=$g_month
        rtc_day=$(echo $rtc_date | busybox awk '{print $3}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC day fail"
            return 6
        fi
        echo "day before switch:$rtc_day"
        day_switch $rtc_day
        echo "rtc_date:$rtc_date"
        echo "day after switch:rtc_day=$rtc_day,g_day=$g_day"
        rtc_day=$g_day

        rtc_time=$(echo $rtc_date | busybox awk '{print $4}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC time fail"
            return 7
        fi
        rtc_hour=$(echo $rtc_time | busybox awk -F: '{print $1}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC hour fail"
            return 8
        fi
        rtc_minute=$(echo $rtc_time | busybox awk -F: '{print $2}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC minute fail"
            return 9
        fi
        rtc_second=$(echo $rtc_time | busybox awk -F: '{print $3}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC second fail"
            return 10
        fi

        pc_year_month_day=$(echo $2 | busybox awk -F- '{print $1}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC year.month.day fail"
            return 11
        fi
        pc_time=$(echo $2 | busybox awk -F- '{print $2}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC hour:minute:second fail"
            return 12
        fi
        pc_hour=$(echo $pc_time | busybox awk -F: '{print $1}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC hour fail"
            return 13
        fi
        pc_minute=$(echo $pc_time | busybox awk -F: '{print $2}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC minute fail"
            return 14
        fi
        pc_second=$(echo $pc_time | busybox awk -F: '{print $3}')
        r=$?
        if [ $r != 0 ]; then
            echo "get RTC second fail"
            return 15
        fi

        if [ "$pc_year_month_day" != "$rtc_year.$rtc_month.$rtc_day" ]; then
            echo "year or month or day is different:"
            echo "PC:$pc_year_month_day"
            echo "RTC:$rtc_year.$rtc_month.$rtc_day"
            echo "rtc_date:$rtc_date"
            echo "pc_date:$2"
            return 16
        fi
        if [ $rtc_hour -eq $pc_hour ]; then
            second_rtc=$(($(expr $rtc_minute \* 60)+$rtc_second))
            second_pc=$(($(expr $pc_minute \* 60)+$pc_second))
            diff_time=$(($second_rtc-$second_pc))
            if [ $diff_time -lt $diff_val ] && [ $diff_time -gt -$diff_val ]; then
                echo "RTC function test pass!^_^!"
                return 0
            else
                echo "minute or second is different:"
                echo "PC:$pc_hour.$pc_minute.$pc_second"
                echo "RTC:$rtc_hour.$rtc_minute.$rtc_second"
                echo "rtc_date:$rtc_date"
                echo "pc_date:$2"
                return 17
            fi
        else
            echo "hour is different:"
            echo "PC:$pc_hour"
            echo "RTC:$rtc_hour"
            echo "rtc_date:$rtc_date"
            echo "pc_date:$2"
            return 18
        fi
        #get system clock
#        system_date=$(busybox date +%Y.%m.%d-%H:%M:%S)
#        r=$?
#        if [ $r != 0 ]; then
#            echo "get system clock fail"
#            return 1
#        fi
    elif [ "$1" = "set" ]; then
        #set system clock $2:2000.01.01-00:00:00
        busybox date -s $2
        r=$?
        if [ $r != 0 ]; then
            echo "set system clock fail"
            return 19
        fi
        #set system clock to RTC
        busybox hwclock -w
        r=$?
        if [ $r != 0 ]; then
            echo "set system clock to RTC fail"
            return 20
        fi
        echo "set rtc clock success!"
        return 0
    fi

    echo "can not reach here!"
    return 21
}

#$1:set/get
#$2:time string
eagle_rtc_function $1 $2
exit $?
