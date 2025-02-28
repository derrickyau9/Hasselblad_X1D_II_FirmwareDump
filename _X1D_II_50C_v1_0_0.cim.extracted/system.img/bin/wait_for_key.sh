#
# 2018.09
#

key_name="bodystate-uinput"
key_code="KEY_A"

timeout=10
start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
elapsed()
{
    local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
    local diff=$(($now-$start))
    echo $diff
}

function get_device_by_name()
{
    if [ $# -lt 1 ]; then
        echo "Invalid parameter"
        return 1
    fi

    list=`getevent -S`
    echo "$list" | while read line
    do
        if echo $line | grep \""$*"\" > /dev/null; then
            device=$(echo $last_line | awk '{print $(NF)}')
            echo $device
            return 0
        fi
        last_line="$line"
    done
}

function wait_key()
{
    device=$(get_device_by_name $key_name)
    #echo device=$device

    while true
    do
        timeout 2 getevent -l -c 4 $device | grep $key_code > /dev/null
        if [ $? = 0 ]; then
            return 0
        fi
        if [ $(elapsed) -ge $timeout ]; then
            return 1
        fi
    done
}

function post_test()
{
    if [ $test_id -gt 0 ]; then
        kill $test_id
    fi
}

if [ $# = 2 ]; then
    key_name=$1
    key_code=$2
else
        echo Incorrect amount of parameters.
fi

wait_key

exit $?
