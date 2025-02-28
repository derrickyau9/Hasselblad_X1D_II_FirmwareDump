#########################################################################
# File Name: test_dmic_spk_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Wed 28 Mar 2018 09:22:32 PM CST
#########################################################################
#!/bin/bash

#find and kill the pid of $1
get_and_kill_pid()
{
    local id=$(ps | grep "$1" | grep -v "grep" | busybox awk '{print $2}')
    if [ $? != 0 ]; then
        echo "get pid fail"
        return 16
    fi
    kill -SIGINT $id
    if [ $? != 0 ]; then
        echo "no pid($id)"
        return 0
    fi
	echo "stop mic sucuessfully"
    return 0
}

#stop spk or mic
spk_mic_stop()
{
    if [ $# != 1 ]; then
        echo "Input should be tinyplay or tinycap"
        return 17
    fi
    if [ $1 -eq "tinyplay" ]; then
        get_and_kill_pid "$1"
    elif [ $1 -eq "tinycap" ]; then
        get_and_kill_pid "$1"
    fi
    return $?
}

spk_mic_stop $1
exit $?
