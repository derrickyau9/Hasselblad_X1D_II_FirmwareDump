#!/bin/sh
###################################################
# $Version:  V2.0
# $Function: monkey test entrance
# $Author:   elsas.liu
# $Date:     2018-11-16
###################################################

if [ -z "$1" ]
then
    echo "Usage:    monkey_test.sh keyevent   <loop_number>"
    echo "          monkey_test.sh touchevent <loop_number>"
    echo "          monkey_test.sh allevent   <loop_number> <LCD>"
    echo "          monkey_test.sh debug"
    echo "Attention:1. allevent means keyevent and touchevent and lcd <-> evf"
    echo "          2. LCD=1, LCD only monkey test; LCD=2, monkey test include evf and lcd switch test"
    echo "             if you choose LCD=2, you need cover the EVF before monkey test"
    echo "          3. debug function is not ready now"
    exit 1
fi

# include monkey test lib
. vinput_monkey_lib.sh

# switch to LCD
odindb-send -s bodystate -p screens_active 1
sleep 1

if [ $1 == keyevent ]
then
    if [ "$2" -gt 0 ] 2>/dev/null
    then
        echo "Enter keyevent monkey test..."
        keyevent_monkey_test $2
    else
        echo "monkey_test.sh keyevent <loop_number>"
    fi
elif [ $1 == touchevent ]
then
    if [ "$2" -gt 0 ] 2>/dev/null
    then
        echo "Enter touchevent monkey test..."
        monkey_touch_event_test $2
    else
        echo "monkey_test.sh touchevent <loop_number>"
    fi
elif [ $1 == allevent ]
then
    if [ "$2" -gt 0 ] 2>/dev/null
    then
        if [ "$3" -gt 0 ] 2>/dev/null
        then
            if [ "$3" -eq 1 ]
            then
                echo "Enter LCD only key and touch event monkey test..."
                monkey_all_event_test_lcd $2
            elif [ "$3" -eq 2 ]
            then
                echo "Enter key, touch event and lcd<->evf monkey test..."
                monkey_all_event_test $2
            else
                echo "monkey_test.sh allevent <loop_number> <LCD>"
            fi
        else
            echo "monkey_test.sh allevent <loop_number> <LCD>"
        fi
    else
        echo "monkey_test.sh allevent <loop_number> <LCD>"
    fi
else
    echo "Usage:    monkey_test.sh keyevent   <loop_number>"
    echo "          monkey_test.sh touchevent <loop_number>"
    echo "          monkey_test.sh allevent   <loop_number> <LCD>"
    echo "          monkey_test.sh debug"
    echo "Attention:1.allevent means keyevent and touchevent and lcd <-> evf"
    echo "          2. LCD=1, LCD only monkey test; LCD=2, monkey test include evf and lcd switch test"
    echo "             if you choose LCD=2, you need cover the EVF before monkey test"
    echo "          3. debug function is not ready now"
    exit 1
fi
