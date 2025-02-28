#########################################################################
# File Name: test_lcd_test.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 29 Mar 2018 02:41:10 PM CST
#########################################################################
#!/bin/bash

eagle_evf_link_test()
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

    #switch to EVF
    odin-output -o 2 -p 1 -b 128 -t 200
    if [ $? != 0 ]; then
        echo "test EVF fail"
        setprop ctl.start gui
        return 3
    fi

    victory-gui-static -platform wayland --imagetest -w -f /data/dji/timg_1280x960.yuv
    if [ $? != 0 ]; then
        echo "test EVF fail"
        setprop ctl.start gui
        return 4
    fi

    odin-output -o 8 -p 1 -b 128 -t 200

    #start gui
    setprop ctl.start gui
    if [ $? != 0 ]; then
        echo "start gui fail"
        return 5
    fi

    echo "evf link test pass"
    return 0
}

eagle_evf_link_test
exit $?
