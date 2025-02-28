#########################################################################
# File Name: test_sd_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 27 Mar 2018 05:00:27 PM CST
#########################################################################
#!/bin/bash

eagle_sd_link_test()
{
    local sda_keyword="/storage/sdcard0"
    local sdb_keyword="/storage/sdcard1"

    if [ $# != 1 ]; then
        echo "the number of parameter is error:$#"
        return 3
    fi
    #disconnect usb
    test_hal_storage -c "0 volume detach_pc"
    if [ $1 = 1 ]; then
        ls $sda_keyword
        if [ $? != 0 ]; then
            echo "sd card in slot 1 link test fail"
            return 1
        else
            echo "sd card in slot 1 link test pass"
            return 0
        fi
    fi
    if [ $1 = 2 ]; then
        ls $sdb_keyword
        if [ $? != 0 ]; then
            echo "sd card in slot 2 link test fail"
            #disconnect usb
            test_hal_storage -c "0 volume attach_pc"
            return 2
        else
            echo "sd card in slot 2 link test pass"
            #disconnect usb
            test_hal_storage -c "0 volume attach_pc"
            return 0
        fi
    fi
    echo "sdcard num error"
    #disconnect usb
    test_hal_storage -c "0 volume attach_pc"
    return 4
}

eagle_sd_link_test $1
exit $?

