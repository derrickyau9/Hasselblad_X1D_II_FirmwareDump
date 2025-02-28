#########################################################################
# File Name: test_display_led_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Wed 11 Apr 2018 09:57:33 AM CST
#########################################################################
#!/bin/bash

eagle_display_led_test()
{
    local i=0
        for i in $(seq 3)
    do
        #display red led
        odindb-send -s suc -m set_led E_LedState_On E_LedColor_Red
        if [ $? != 0 ]; then
            echo "display red led fail"
            return 1
        fi
        sleep 1
        #display green led
        odindb-send -s suc -m set_led E_LedState_On E_LedColor_Green
        if [ $? != 0 ]; then
            echo "display green led fail"
            return 2
        fi
        sleep 1
        #display orange led
        odindb-send -s suc -m set_led E_LedState_On E_LedColor_Orange
        if [ $? != 0 ]; then
            echo "display orange led fail"
            return 3
        fi
        sleep 1
    done
    #display green led
    odindb-send -s suc -m set_led E_LedState_On E_LedColor_Green
    if [ $? != 0 ]; then
        echo "display green led fail"
        return 4
    fi
    return 0
}

eagle_display_led_test
exit $?
