#! /system/bin/sh

function get_file_cnt()
{
    return `ls -l $1 | grep "^-" | wc -l`
}


get_file_cnt /camera/DCIM/100MEDIA
file_cnt_before=$?
echo "before capture file count: "$file_cnt_before

/system/bin/dbus-send --system --type=method_call --print-reply --dest=com.hasselblad.seq /seq com.hasselblad.seq.do_exposure
sleep 5

get_file_cnt /camera/DCIM/100MEDIA
file_cnt_after=$?

let expect_file_cnt=$file_cnt_before+1

echo "after capture file count: "$file_cnt_after

if [ $file_cnt_after == $expect_file_cnt ]; then
    echo "test pass"
    exit 0
else
    echo "test failed"
    exit 1
fi
