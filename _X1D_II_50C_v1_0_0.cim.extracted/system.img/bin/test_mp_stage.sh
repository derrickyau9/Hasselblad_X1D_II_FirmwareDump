
stop_all_services()
{
    setprop dji.blackbox_service 0
    setprop dji.monitor_service 0
    #setprop dji.system_service 0
    #setprop dji.vtwo_sdk_service 0
    setprop dji.perception_service 0
    setprop dji.navigation_service 0
    setprop dji.camera_service 0
    setprop dji.rcam_service 0
    setprop dji.flight_service 0
    #setprop dji.amt_service 0
    setprop dji.sec_service 0
    echo "All dji services stopped!"
}

clear_all_logs()
{
    echo "Tell 1860 to clear blackbox"
    # call 1860 clear_blackbox.sh
    local r=`dji_mb_ctrl -S test -R diag -g 9 -t 1 -s 0 -c 0xf4  550000000000`
    if [ $? != 0 ]; then
        echo "mb_ctrl returns error $r"
        return 2
    fi

    raw_data=${r##*data:}

    result=`echo $raw_data | busybox awk '{printf $1}'`
    if [ x"$result" != x"00" ]; then
        echo "clear 1860 log error return"
        return 3
    fi

    echo "Stop all services...."
    stop_all_services
    echo "Start to clear all logs on board, wait..."
    rm -rf /blackbox/system/*
    rm -rf /blackbox/navigation/*
    rm -rf /blackbox/gimbal/*
    rm -rf /blackbox/camera/*
    rm -rf /blackbox/flyctrl/*
    rm -rf /blackbox/dji_flight/*
    rm -rf /blackbox/dji_perception/*
    rm -rf /blackbox/autotest/*
    rm -rf /data/tombstones/*
    rm -rf /data/dji/amt/*
    rm -rf /data/coredump
    rm -rf /cache/*

    setprop persist.dji.storage.exportable 1

    echo "Clear_all_logs done at `date`, reboot your aircraft before use it again!"
    sync
    return 0
}

mkdir -p /data/dji/amt

echo test_mp_stage.sh $*

if [ -f /data/dji/autotest_on ];then
    rm /data/dji/autotest_on
    sync
fi

if [ "aging_test"x != "$1"x -a "aging_test_local"x != "$1"x -a "aging_test_full_cam"x != "$1"x -a "erase"x != "$1"x ]; then
    echo "You input test_mp_stage.sh $1, please input a right para!"
    echo "Failure, should be aging_test or erase, thanks!"
    exit 1;
else
    echo "You input test_mp_stage.sh $1."
    if [ "aging_test" == "$1" -o "aging_test_local"x == "$1"x -o "aging_test_full_cam"x == "$1"x ]; then
        echo "$1" > /data/dji/amt/state
        #disable sd card mount to pc from next boot up
        setprop persist.dji.storage.exportable 0
    fi

    sync

    if [ "$1"x == "aging_test"x -o "$1"x == "aging_test_local"x -o "$1"x == "aging_test_full_cam"x ] && [ $# == 2 ]; then
        echo $2 > /data/dji/amt/aging_test_timeout
    fi

    if [ "$1"x == "erase"x ]; then
        clear_all_logs
        local r=$?
        echo normal > /data/dji/amt/state
        sync
        exit $r
    fi

    sync

    local stat=`cat /data/dji/amt/state`
    if [ "$1"x != "$stat"x ]; then
        echo "Failure, should get $1, but get $stat."
        exit 1
    else
        echo "Success"
    fi

fi

exit 0
