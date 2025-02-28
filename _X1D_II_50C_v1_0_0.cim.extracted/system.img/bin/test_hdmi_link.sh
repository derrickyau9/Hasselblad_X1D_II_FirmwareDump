#########################################################################
# File Name: test_lcd_test.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 29 Mar 2018 02:41:10 PM CST
#########################################################################
#!/bin/bash

eagle_lcd_hdmi_evf_link_test()
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
    sleep 1
    #run test_lcd to test LCD&HDMI
    test_lcd -d 2 -p 0 -m 1 -s 6
    if [ $? != 0 ]; then
        echo "test LCD&HDMI fail"
        setprop ctl.start compositor
        setprop ctl.start gui
        return 4
    fi
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
    echo "hdmi link test pass"
    return 0
}

eagle_lcd_hdmi_evf_link_test
exit $?
