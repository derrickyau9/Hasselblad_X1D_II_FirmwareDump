#! /system/bin/sh

RAW_SOURCE_PATH='/data/dcam'

setprop ctl.stop dji_camera2
setprop ctl.stop gui
setprop ctl.stop compositor

# wait for dji_camera2 really stop before triggering F2F test
sleep 2

dji_cam_f2f.sh ${RAW_SOURCE_PATH}/DJI_4056X3040.raw ${RAW_SOURCE_PATH}/DJI_8384X6304.raw -f
