#! /system/bin/sh

setprop ctl.start compositor
setprop ctl.stop dji_camera2
sleep 2
dji_cht -f -d 3 -e wayland -g emmc -C 4,5
