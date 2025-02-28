if [ $# -ne 2 ]
then
printf "Usage: ${0##*/} bitwidth samplerate\n"
exit 1
fi

tinyplay /data/audio-test-cases/48k-800hz-$1bit.raw -d 0 -i raw -c 2 -b $1 -r $2 -n 4 &
tinycap /data/audio-test-cases/cap-$1b-$2.wav -d 0 -c 2 -b $1 -r $2 -t 10 
