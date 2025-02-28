#########################################################################
# File Name: test_spk_mic_function.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Mon 04 Jun 2018 02:17:18 PM CST
#########################################################################
#!/bin/bash

#display audio
display_audio()
{
    if [ $# != 1 ]; then
        echo "The number of parameter is wrong!"
        return 16
    fi
    if [ $1 = 0 ]; then
        tinyplay /ftp/SpeakerTest0.wav -d 0 -i wav -n 4 &
#       tinyplay /data/audio-test-cases/48k-800hz-16bit.raw -i raw -c 2 -b 16 -r 48000 -n 4 &
#        if [ $? != 0 ]; then
#            echo "inter spk display audio fail"
#            return 15
#        fi
	elif [ $1 = 1 ]; then
        tinyplay /ftp/SpeakerTest1.wav -d 0 -i wav -n 4 &
#       tinyplay /data/audio-test-cases/48k-800hz-16bit.raw -i raw -c 2 -b 16 -r 48000 -n 4 &
#        if [ $? != 0 ]; then
#            echo "headphone display audio fail"
#            return 17
#        fi
    else
        echo "spk type is wrong:$1 is not 0 or 1"
        return 18
	fi
    echo "inter spk display audio success"
    return 0
}

# [3:1] 0: silence;1: 0db-128;2: 3db-134;3: 6db-140;4: 9db-146;5: 12db-152;6: 15db-158; 7: 18db-164;
volume_set()
{
local val
if [ $# != 1 ]; then
    echo "the number of parameter is wrong!"
    return 18
fi
case "$1" in
	0) val=0;;
	1) val=128;;
	2) val=134;;
	3) val=140;;
	4) val=146;;
	5) val=152;;
	6) val=158;;
	7) val=164;;
esac
return $val
}
config_spk()
{
local value
if [ $# != 2 ]; then
	echo "the number of parameter is wrong!"
    return 16
fi
#switch on "HPOUT1 Digital Switch"
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
volume_set $2
value=$?
#set "Speaker Digital Volume" to 136
tinymix 175 $value
if [ $? != 0 ]; then
    echo "config 175 to $value fail"
    return 9
fi
tinymix  155 32
if [ $? != 0 ]; then
    echo "config 155 to 32(val) fail"
    return 10
fi
}

config_headphone()
{
if [ $# != 2 ]; then
	echo "the number of parameter is wrong!"
    return 16
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
volume_set $2
value=$?
#set "HDPOUT1 Digital Volume" to 174
tinymix  174 $value $value
if [ $? != 0 ]; then
    echo "config 174 to 128(left) 128(right) fail"
    return 12
fi
}
#$1:spk type:    [7:1] reserved
#                [0] 0: inside spk;1: outside spk;
#$2:file type:   [7:1] reserved
#                [0]   0: wav;1: acc;
#$3:channel:     [7:2] reserved
#                [1:0] 0:channel_1;1:channel_2;3:channel_3;4:channel_4;
#$4:analog gain: [7:4] reserved
#                [3:1] 0: silence;1: 0db-128;2: 3db-134;3: 6db-140;4: 9db-146;5: 12db-152;6: 15db-158; 7: 18db-164;
#                [0] 0: zoom in;1: zoom out;
#$5:digital gain:[7:4] reserved
#                [3:1] 0: silence;1: 0db;2: 3db;3: 6db;4: 9db;5: 12db;6: 15db; 7: 18db;
#                [0] 0: zoom in;1: zoom out;
#$6:processing algorithm:
#                [7:4] reserved
#                [3:1] 0: default;1: group 1;2: group 2;3: group 3;4: group 4;
#                [0]   0: OFF;1: ON
spk_function_test()
{
    local ret
    if [ $# != 6 ]; then
        echo "the number of parameter is wrong!"
		return 13
    fi
    if [ $1 = 0 ]; then
        config_spk $3 $5
        ret=$?
        if [ $ret != 0 ]; then
            echo "config inter spk error"
            return $ret
        fi
    elif [ $1 = 1 ]; then
        config_headphone $3 $5
        ret=$?
        if [ $ret != 0 ]; then
            echo "config headphone error"
            return $ret
        fi
	fi
    #display std audio
    display_audio $1
    ret=$?
    if [ $ret != 0 ]; then
        echo "display std audio error"
        return $ret
    fi
    return $ret
}

#spk_function_test $1 $2 $3 $4 $5 $6
spk_function_test $1 $2 $3 $4 $5 $6
exit $?
