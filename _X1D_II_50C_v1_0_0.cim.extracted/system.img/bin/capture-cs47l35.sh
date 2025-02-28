if [ $# -ne 2 ]
then
printf "Usage: ${0##*/} bitwidth samplerate\n"
exit 1
fi

tinycap /data/audio-test-cases/cap-$1b-$2.wav -d 0 -c 2 -b $1 -r $2 -t 10
