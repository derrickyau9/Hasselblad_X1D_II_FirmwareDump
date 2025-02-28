#!/system/bin/sh

echo "<2>KPI_SYSTEM_START_READY" >> /dev/kmsg

# Check partitions, try format it and reboot when failed
#/system/bin/part_check.sh
#start bootlogo_service
start compositor

fsck_dir=/data/dji/fsck
aging_flag=/data/dji
mkdir -p $fsck_dir
mkdir -p /data/dji/log
# Start dji system services
export HOME=/data
setprop dji.monitor_service 1
setprop dji.system_service 1

# start dbus daemons and compositor in sequence
setprop hbl.dbus_service 1
start msg2dbus
setprop dji.mount_filesystem_service 1
start gui
# share modules
insmod /system/lib/modules/icc_chnl.ko
insmod /system/lib/modules/eagle_dsp.ko

# add fc standalone/fullfunction mode switch trigger
# TODO: this flow should be add to icc probe flow later
echo "send 3.0" > /proc/driver/icc

# correct system time before services start
# sync_time.sh &

# start optee client daemon
tee-supplicant &

# camera module
insmod /system/lib/modules/rcam_dji.ko

setprop dji.rcam_service 1
setup_cam_env.sh
setprop dji.camera_service 1

# start odin daemons
# add input device that bodystate requires
insmod /system/lib/modules/uinput.ko
start configstore
start bodystate
start camera_daemon
start metadata_daemon
start audio_daemon
start storage_daemon
# By setting dji.quick_charge_service to 0 before sysman is started
# sysman will be responsible for handling the usb otg state.
setprop dji.quick_charge_service 0
start sysman
start preview_daemon
start upgrade_daemon
setprop ctl.start phocus
setprop ctl.start analytics

# camera input and approximity
insmod /system/lib/modules/adp5589-keys.ko
insmod /system/lib/modules/gpio_keys.ko
insmod /system/lib/modules/sfh7776.ko

# video codec modules
insmod /system/lib/modules/e5010_mod.ko
insmod /system/lib/modules/imgtec/imgvideo.ko
insmod /system/lib/modules/imgtec/vxekm.ko
insmod /system/lib/modules/imgtec/img_mem.ko
insmod /system/lib/modules/imgtec/vxd.ko fw_select=2

# touch panel
insert_tp_mod.sh &

# audio modules
insmod /system/lib/modules/irq-madera-cs47l35.ko
insmod /system/lib/modules/irq-madera.ko
insmod /system/lib/modules/madera-i2c.ko
insmod /system/lib/modules/soundcore.ko
insmod /system/lib/modules/snd.ko
insmod /system/lib/modules/snd-pcm.ko
insmod /system/lib/modules/snd-pcm-dmaengine.ko
insmod /system/lib/modules/snd-compress.ko
insmod /system/lib/modules/snd-soc-core.ko
insmod /system/lib/modules/snd-soc-madera.ko
insmod /system/lib/modules/snd-soc-wm-adsp.ko
insmod /system/lib/modules/snd-soc-simple-card.ko
insmod /system/lib/modules/dji_dw_hdmi_i2s_audio.ko
insmod /system/lib/modules/designware_i2s.ko
insmod /system/lib/modules/snd-soc-cs47l35.ko

setprop ctl.start sutest

##Here we change it to 15s to avoid ssd probe fail issue##
if [ -f /data/dji/cfg/ssd_en ]; then # Disabled by default
	i=0
	while [ $i -lt 25 ]; do
		if [ -b /dev/block/sda1 ]
		then
			mkdir -p /data/image
			mount -t ext4 /dev/block/sda1 /data/image
			break
		fi
		i=`busybox expr $i + 1`
		sleep 1
	done
fi

mkdir -p /data/upgrade/backup
mkdir -p /data/upgrade/signimgs
mkdir -p /data/upgrade/unsignimgs
mkdir -p /data/upgrade/incomptb

# clean liveview dump_enable
rm -rf /data/venc_dump

dji_iosconn &

# run camera service automatically
#setprop dji.network_service 1
setprop dji.wms_service 1
setprop dji.amt_service 1

start dji_system_post

start gpsd

set_sd_autosuspend.sh &

periodic_sync.sh &

#check whether need aging test
if [ -f $aging_flag/aging_test_flag ]; then
	aging_test.sh
    if [ $? -eq 0 ]; then
        while true
        do
            odindb-send -s suc -m set_led E_LedState_On E_LedColor_Green
            sleep 1
            odindb-send -s suc -m set_led E_LedState_Off E_LedColor_NoColor
            sleep 1
        done
    else
        while true
        do
            odindb-send -s suc -m set_led E_LedState_On E_LedColor_Red
        done
    fi
fi
