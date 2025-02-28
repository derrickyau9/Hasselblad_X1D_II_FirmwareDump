#########################################################################
# File Name: test_fpga_spi_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 31 Mar 2018 09:04:59 PM CST
#########################################################################
#!/bin/bash

eagle_fpga_spi_link_test()
{
    time send_fw -p 128 -l /system/bin/unrd -r file://1://test.bin
    if [ $? != 0 ]; then
        echo "eagle to fpga link test fail"
        return 1
    else
        echo "eagle to fpga link test pass"
        return 0
    fi
}

eagle_fpga_spi_link_test
exit $?
