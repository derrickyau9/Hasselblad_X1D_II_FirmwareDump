#! /system/bin/sh

setprop ctl.start compositor
setprop ctl.stop dji_camera2
sleep 2
dji_cht -f -d 3 -e wayland -g emmc -F /system/etc/cht_cases.conf
dji_cht -e null -c x1dm2_raw_liveivew
