#########################################################################
# File Name: test_eagle_uart_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 29 Mar 2018 04:53:35 PM CST
#########################################################################
#!/bin/bash

eagle_af_led_test()
{
    #open af led
    echo 255 > /sys/class/leds/assist-led/brightness
    if [ $? != 0 ]; then
        echo "open af led fail"
        return 1
    fi
    sleep 2
    #close af led
    echo 0 > /sys/class/leds/assist-led/brightness
    if [ $? != 0 ]; then
        echo "close af led fail"
        return 2
    fi
    return 0
}

eagle_af_led_test
exit $?
