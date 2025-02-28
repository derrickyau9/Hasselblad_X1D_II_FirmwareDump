if [ $# -ne 2 ]
then
printf "Usage: ${0##*/} bitwidth samplerate\n"
exit 1
fi

tinyplay /data/audio-test-cases/48k-800hz-$1bit.raw -d 1 -i raw -c 2 -b $1 -r $2 -n 4
