#########################################################################
# File Name: test_spk_mic_function.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Mon 04 Jun 2018 02:17:18 PM CST
#########################################################################
#!/bin/bash

#capture audio
capture_audio()
{
local bitwidth
local samplerate
local idx=0
if [ $# != 3 ]; then
    echo "bitwidth or samplerate error"
    return 13
fi
if [ $1 = 0 ]; then
    bitwidth=16
elif [ $1 = 1 ]; then
    bitwidth=24
fi
#  [2:0] 0:16k;1:32k;2:44.1k;3:48k;4:64k;5:96k;6:192k;
case "$2" in
	0) samplerate=16000;;
	1) samplerate=32000;;
	2) samplerate=44100;;
	3) samplerate=48000;;
	4) samplerate=64000;;
	5) samplerate=96000;;
	6) samplerate=192000;;
esac

tinycap /ftp/MicTest$3.wav -d 0 -c 2 -b $bitwidth -r $samplerate -t 60  > /dev/null &
#tinycap /data/MicTest$3.wav -d 0 -c 2 -b $bitwidth -r $samplerate -t 120
#if [ $? != 0 ]; then
#    echo "external mic capture audio error"
#    return 14
#else
#    echo "external mic capture audio success"
#    return 0
#fi

echo "external mic capture start!"
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
config_dmic()
{
local value
if [ $# != 1 ]; then
    echo "the number of parameter is wrong!"
    return 16
fi
volume_set $1
value=$?
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
tinymix 17 $value
if [ $? != 0 ]; then
    echo "config 17 to 136(val) fail"
    return 3
fi
tinymix 18 $value
if [ $? != 0 ]; then
    echo "config 18 to 136(val) fail"
    return 4
fi
tinymix 280 Digital
if [ $? != 0 ]; then
    echo "config 280 to Digital fail"
    return 5
fi
}
config_mic()
{
local value
if [ $# != 1 ]; then
    echo "the number of parameter is wrong!"
    return 15
fi
volume_set $1
value=$?
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
#set "IN1L Digital Volume" to 136
tinymix 17 $value
if [ $? != 0 ]; then
    echo "config 17 to 136(val) fail"
    return 3
fi
#set "IN1R Digital Volume" to 136
tinymix 18 $value
if [ $? != 0 ]; then
    echo "config 18 to 136(val) fail"
    return 4
fi
tinymix 280 Analog
if [ $? != 0 ]; then
    echo "config 280 to Digital fail"
    return 5
fi
}

mic_function_test()
{
if [ $# != 8 ]; then
    echo "the number of parameter is wrong!"
	return 15
fi
if [ $1 = 0 ]; then
    #config inter mic
    config_dmic $7
    local ret=$?
    if [ $ret != 0 ]; then
        echo "config mic error"
        return $ret
    fi
elif [ $1 = 1 ]; then
    #config outside mic
    config_mic $7
    local ret=$?
    if [ $ret != 0 ]; then
        echo "config mic error"
        return $ret
    fi
else
    echo "mic type error:$1 is not 0 or 1"
	return 16
fi
#bitwidth:16 samplerate:48000
#save to /data/audio-test-cases/cap-16b-48000.wav
capture_audio $4 $3 $1
ret=$?
if [ $ret != 0 ]; then
    echo "capture error"
    return $ret
fi
return 0
}

#$1:mic type:    [7:2] reserved
#                [1:0] 0: inside mic;1: outside mic;2: wireless mic
#$2:file type:   [7:1] reserved
#                [0]   0: wav;1: acc;
#$3:samplerate:  [7:3] reserved
#                [2:0] 0:16k;1:32k;2:44.1k;3:48k;4:64k;5:96k;6:192k;
#$4:bitwidth:    [7:1] reserved
#                [0]   0: 16bit;1: 24bit;
#$5:chanel mask: [7:4] reserved
#                [3:0] 0: invalid;1: valid;
#$6:analog gain: [7:4] reserved
#                [3:1] 0: silence;1: 0db-128;2: 3db-134;3: 6db-140;4: 9db-146;5: 12db-152;6: 15db-158; 7: 18db-164;
#                [0] 0: zoom in;1: zoom out;
#$7:digital gain:[7:4] reserved
#                [3:1] 0: silence;1: 0db;2: 3db;3: 6db;4: 9db;5: 12db;6: 15db; 7: 18db;
#                [0] 0: zoom in;1: zoom out;
#$8:processing algorithm:
#                [7:4] reserved
#                [3:1] 0: default;1: group 1;2: group 2;3: group 3;4: group 4;
#                [0]   0: OFF;1: ON
mic_function_test $1 $2 $3 $4 $5 $6 $7 $8
#mic_function_test
exit $?
