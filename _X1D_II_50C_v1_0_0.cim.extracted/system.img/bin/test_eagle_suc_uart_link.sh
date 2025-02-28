#########################################################################
# File Name: test_eagle_suc_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 31 Mar 2018 05:53:59 PM CST
#########################################################################
#!/bin/bash

eagle_suc_uart_link_test()
{
    local keyword="firmware_version :"
    upgrade_fw -c -n suc > /blackbox/system/test_tmp.log 2>&1
    if [ $? != 0 ]; then
        echo "eagle to suc test fail"
        return 1
    else
        if [ -f /blackbox/system/test_tmp.log ]; then
            grep "$keyword" /blackbox/system/test_tmp.log
            if [ $? != 0 ]; then
                echo "eagle to suc test fail"
                return 2
            else
                echo "eagle to suc test pass"
                return 0
            fi
        else
            echo "eagle to suc test fail,no test_tmp.log"
            return 3
        fi
    fi
}

eagle_suc_uart_link_test
exit $?
