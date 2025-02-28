#!/bin/sh

if [ -z "$1" ]
then
	echo "Usage: af.sh <loop_number> <duration> <interval>"
fi


vinput_daemon &
sleep 1

vinput2 keyevent half_press
sleep 1

loop=$1

while [ $loop -gt 0 ]
do
vinput2 keyevent af_d true false
sleep $2
vinput2 keyevent af_d false false
sleep $3
loop=$(($loop-1))
done