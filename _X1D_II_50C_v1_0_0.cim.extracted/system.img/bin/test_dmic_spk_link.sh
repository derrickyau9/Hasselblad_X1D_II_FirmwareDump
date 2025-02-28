#########################################################################
# File Name: test_dmic_spk_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Wed 28 Mar 2018 09:22:32 PM CST
#########################################################################
#!/bin/bash

BEEPVOL=${1:-190}
PLAYBACKVOL=${2:-190}

#capture audio
capture_audio(){
if [ $# -ne 2 ]; then
    echo "bitwidth or samplerate error"
    return 13
fi

tinycap /data/audio-test-cases/cap-$1b-$2.wav -d 0 -c 2 -b $1 -r $2 -t 10
if [ $? != 0 ]; then
    echo "inter capture audio error"
    return 14
else
    echo "inter capture audio success"
    return 0
fi
}

#display audio
display_audio()
{
    tinyplay /data/audio-test-cases/cap-16b-48000.wav -d 0 -i wav -n 4
    if [ $? != 0 ]; then
        echo "inter spk display audio fail"
        return 15
    fi
    echo "inter spk display audio success"
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
#config inter digital mic
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
tinymix 17 190
if [ $? != 0 ]; then
    echo "config 17 to 190(val) fail"
    return 3
fi
tinymix 18 190
if [ $? != 0 ]; then
    echo "config 18 to 190(val) fail"
    return 4
fi
tinymix 280 Digital
if [ $? != 0 ]; then
    echo "config 280 to Digital fail"
    return 5
fi
#config inter spk
tinymix 171 0 0
if [ $? != 0 ]; then
    echo "config 171 to 0 0 fail"
    return 6
fi
tinymix 172 1
if [ $? != 0 ]; then
    echo "config 172 to 1 fail"
    return 7
fi
tinymix 353 AIF1RX1
if [ $? != 0 ]; then
    echo "config 353 to AIF1RX1 fail"
    return 8
fi
tinymix 17 136
if [ $? != 0 ]; then
    echo "config 17 to 116(val) fail"
    return 9
fi
tinymix  18 136
if [ $? != 0 ]; then
    echo "config 18 to 116(val) fail"
    return 10
fi
tinymix  155 32
if [ $? != 0 ]; then
    echo "config 155 to 32(val) fail"
    return 11
fi
tinymix  175 $BEEPVOL
if [ $? != 0 ]; then
    echo "config 175 to $BEEPVOL(val) fail"
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

#display std audio
display_std_audio
if [ $? != 0 ]; then
    exit $?
fi

# Potentially Raise Volume before playing captured audio
tinymix  175 $PLAYBACKVOL
if [ $? != 0 ]; then
    echo "config 175 to $PLAYBACKVOL(val) fail"
    return 13
fi


#display capture audio
display_audio
exit $?
