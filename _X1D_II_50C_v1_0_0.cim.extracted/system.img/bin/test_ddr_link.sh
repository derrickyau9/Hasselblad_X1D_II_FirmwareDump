#########################################################################
# File Name: ddr_test.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 27 Mar 2018 03:08:05 PM CST
#########################################################################
#!/bin/bash

eagle_ddr_link_test()
{

    echo "EAGLE DDR Link Test Start"
    # memory test
    test_mem -s 0x2000 -l 1
    local r=$?
    if [ $r != 0 ]; then
        echo "DDR link test fail"
        return 1
    fi
    echo "EAGLE DDR Link test pass"
    return 0
}

eagle_ddr_link_test
exit $?
