#########################################################################
# File Name: test_dmic_spk_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Wed 28 Mar 2018 09:22:32 PM CST
#########################################################################
#!/bin/bash

#capture audio
capture_audio(){
if [ $# -ne 2 ]; then
    echo "bitwidth or samplerate error"
    return 13
fi

tinycap /data/audio-test-cases/cap-$1b-$2.wav -d 0 -c 2 -b $1 -r $2 -t 10
if [ $? != 0 ]; then
    echo "external mic capture audio error"
    return 14
else
    echo "external mic capture audio success"
    return 0
fi
}

#display audio
display_audio()
{
    tinyplay /data/audio-test-cases/cap-16b-48000.wav -d 0 -i wav -n 4
    if [ $? != 0 ]; then
        echo "external mic display audio fail"
        return 15
    fi
    echo "external mic display audio success"
    return 0
}

#find and kill the pid of $1
get_and_kill_pid()
{
    local id=$(ps | grep "$1" | grep -v "grep" | busybox awk '{print $2}')
    if [ $? != 0 ]; then
        echo "get pid fail"
        return 16
    fi
    kill -9 $id
    if [ $? != 0 ]; then
        echo "kill pid($id) fail"
        return 17
    fi
    return 0
}

#display std audio
display_std_audio()
{
    tinyplay /data/audio-test-cases/48k-800hz-16bit.raw  -i raw -c 2 -b 16 -r 48000 -n 4 &
    if [ $? != 0 ]; then
        echo "display std 48k-800hz-16bit audio fail"
        return 19
    fi
    sleep 1
    get_and_kill_pid "tinyplay"
    tinyplay /data/audio-test-cases/48k-800hz-24bit.raw  -i raw -c 2 -b 24 -r 48000 -n 4 &
    if [ $? != 0 ]; then
        echo "display std 48k-800hz-24bit audio fail"
        return 20
    fi
    sleep 1
    get_and_kill_pid "tinyplay"
    tinyplay /data/audio-test-cases/48k-800hz-32bit.raw  -i raw -c 2 -b 32 -r 48000 -n 4 &
    if [ $? != 0 ]; then
        echo "display std 48k-800hz-32bit audio fail"
        return 21
    fi
    sleep 1
    get_and_kill_pid "tinyplay"
    return 0
}
#config external analog mic
tinymix 365 IN1L
if [ $? != 0 ]; then
    echo "config 365 to IN1L fail"
    return 1
fi
tinymix 369 IN1R
if [ $? != 0 ]; then
    echo "config 369 to IN1R fail"
    return 2
fi
tinymix 17 180
if [ $? != 0 ]; then
    echo "config 17 to 136(val) fail"
    return 3
fi
tinymix 18 180
if [ $? != 0 ]; then
    echo "config 18 to 136(val) fail"
    return 4
fi
tinymix 280 Analog
if [ $? != 0 ]; then
    echo "config 280 to Digital fail"
    return 5
fi
#config external headphone
tinymix 172 0
if [ $? != 0 ]; then
    echo "config 172 to 0 fail"
    return 6
fi
tinymix 171 1 1
if [ $? != 0 ]; then
    echo "config 171 to 1 1 fail"
    return 7
fi
tinymix 345 AIF1RX1
if [ $? != 0 ]; then
    echo "config 345 to AIF1RX1 fail"
    return 8
fi
tinymix 349 AIF1RX2
if [ $? != 0 ]; then
    echo "config 349 to AIF1RX2 fail"
    return 9
fi
tinymix 147 20
if [ $? != 0 ]; then
    echo "config 147 to 20(val) fail"
    return 10
fi
tinymix  151 20
if [ $? != 0 ]; then
    echo "config 151 to 20(val) fail"
    return 11
fi
tinymix  174 128 128
if [ $? != 0 ]; then
    echo "config 174 to 128(left) 128(right) fail"
    return 12
fi
#display std audio
display_std_audio
if [ $? != 0 ]; then
    exit $?
fi
#bitwidth:16 samplerate:48000
#save to /data/audio-test-cases/cap-16b-48000.wav
capture_audio 16 48000
if [ $? != 0 ]; then
    exit $?
fi
#display capture audio
display_audio
exit $?
