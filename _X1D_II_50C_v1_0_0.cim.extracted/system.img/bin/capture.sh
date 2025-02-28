#!/bin/sh

vinput_daemon&

i=1
num=1000
while [ $i -le $num ]
do
    vinput2 keyevent half_press
    sleep 1
    vinput2 keyevent half_press true false
    sleep 2
    vinput2 keyevent full_press
    sleep 0.5
    vinput2 keyevent half_press false false
    sleep 0.5
    echo "################## continuous capture test: $i "##################

    let i++
done
