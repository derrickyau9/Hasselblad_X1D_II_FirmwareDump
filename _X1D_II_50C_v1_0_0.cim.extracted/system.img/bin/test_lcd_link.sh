#########################################################################
# File Name: test_lcd_test.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 29 Mar 2018 02:41:10 PM CST
#
# Author: johnny.du
# Comment: add backlight test
# mail: johnny.du@dji.com
# Modified Time: 2018/12/2

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
    # make sure to enable the back display
    odin-output -o 8 -b 128 -p on -t 200
    if [ $? != 0 ]; then
        echo "Failed to set output"
        setprop ctl.start gui
        return 3
    fi
    #run test_lcd to test LCD
    victory-gui-static -platform wayland --imagetest -f /data/dji/timg_1024x768.rgba.rgb -w
    if [ $? != 0 ]; then
        echo "test LCD&HDMI fail"
        setprop ctl.start gui
        return 4
    fi

    #start gui
    setprop ctl.start gui
    if [ $? != 0 ]; then
        echo "start gui fail"
        return 5
    fi
    echo "lcd link test pass"
    return 0
}

eagle_lcd_hdmi_evf_link_test
exit $?
