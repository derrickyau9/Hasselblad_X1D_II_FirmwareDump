#########################################################################
# File Name: test_Acce_Gyro_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 27 Mar 2018 05:43:42 PM CST
#########################################################################
#!/bin/bash

eagle_acce_gyro_link_test()
{
    #Acce test
    test_STMems_sensors --accel
    local r=$?
    if [ $r != 0 ]; then
        echo "Acce link test fail"
        return 1
    fi

    #gyro test
    test_STMems_sensors --gyro
    r=$?
    if [ $r != 0 ]; then
        echo "Gyro link test fail"
        return 2
    fi
    echo "Acce and Gyro link test pass"
    return 0
}

eagle_acce_gyro_link_test
exit $?
