#########################################################################
# File Name: test_emmc_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 27 Mar 2018 04:46:33 PM CST
#########################################################################
#!/bin/bash

eagle_emmc_link_test()
{
    local std_md5=b79398e97763618b5394558d3d944bf4

    if [ -f /blackbox/system/eMMC.data ]; then
        rm -f /blackbox/system/eMMC.data
    fi

    dd if=/data/dji/test.data of=/blackbox/system/eMMC.data bs=1 count=1024
    local r=$?
    if [ $r != 0 ]; then
        echo "eMMC link test fail, fail to write eMMC"
        return 1
    fi
    local eMMC_MD5=$(md5sum /blackbox/system/eMMC.data | busybox awk '{print $1}')
    if [ $eMMC_MD5 != $std_md5 ]; then
        echo "eMMC link test fail MD5 is $eMMC_MD5"
        return 2
    fi
    echo "eagle emmc link test pass"
    return 0
}

eagle_emmc_link_test
exit $?

