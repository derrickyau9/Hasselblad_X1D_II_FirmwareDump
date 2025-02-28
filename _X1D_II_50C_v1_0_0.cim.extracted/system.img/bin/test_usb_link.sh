#########################################################################
# File Name: test_usb_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 31 Mar 2018 08:54:39 PM CST
#########################################################################
#!/bin/bash

# get elapsed seconds
timeout=10
elapsed()
{
    local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
    local diff=$(($now-$start))
    echo $diff
}

eagle_usb_link_test()
{
    #clear all message in dmesg
#    dmesg -c > /dev/null
#    if [ $? != 0 ]; then
#        echo "clear dmesg fail"
#        return 1
#    fi

    #find usb
#    start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
#    test_hal_storage -c "0 volume detach_pc"
#    test_hal_storage -c "0 volume attach_pc"
#    while true
#    do
        dmesg | grep "USB_STATE=CONNECTED" > /dev/null
        if [ $? = 0 ];then
            echo 0 > /sys/bus/i2c/devices/4-0011/reader
            dmesg | grep "mfi_i2c read result :5 1 2 0" > /dev/null
            if [ $? != 0 ]; then
                echo "mfi chip have problem"
                return 2
            else
                echo "usb link test pass"
                return 0
            fi
        else
            echo "usb link test fail"
            return 1
        fi
#        if [ $(elapsed) -ge $timeout ]; then
#            echo "no usb insert into slot"
#            return 2
#        fi
#    done

}

eagle_usb_link_test
exit $?
