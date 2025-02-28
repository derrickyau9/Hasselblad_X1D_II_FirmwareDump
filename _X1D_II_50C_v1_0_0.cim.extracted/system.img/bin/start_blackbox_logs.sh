#!/system/bin/sh
fsck_dir=/data/dji/fsck

mkdir -p /blackbox/upgrade/signimgs
mkdir -p /blackbox/camera/log
mkdir -p /blackbox/system

cp -rf $fsck_dir /blackbox/system/

# Auto save logcat to flash to help trace issues
if [ -f $fsck_dir/cfg/field_trail ]; then
    # Up to 5 files, each file upto 32MB
    logcat -f /blackbox/system/logcat.log -r32768 -n2 *:I &
fi

# for fatal errors, up to 32MB
logcat -v time -f /blackbox/system/fatal.log -r32768 -n2 *:E &

# for ec1704 upgraded log, up to 2MB
logcat -v time -f /blackbox/system/cim_upgrade.log -r2048 -n8 upgraded:D victory-gui:D *:S &
logcat -v threadtime -f /blackbox/system/dji_upgrade.log -r2048 -n8 DUSS63:I *:S &

# do kmsg collection
dji_kmsg -l 10M -d /blackbox/system/ -n 8 &

# to collect crash dump info
dji_crashdump.sh &

# to collect tombstone
dji_tombstone.sh &

# Main log for all daemons
logcat -f /blackbox/camera/log/cam.log -r16384 -n8 \
                                          DUSS51:I \
                                          DUSS58:I \
                                          bodystate:D \
                                          camera:D \
                                          camservice:D \
                                          configstore:D \
                                          gpsd:D \
                                          metadata:D \
                                          msg2dbus:D \
                                          phocus:D \
                                          preview:D \
                                          send_fw:D \
                                          storage:D \
                                          sutest:D \
                                          sysman:D \
                                          upgraded:D \
                                          victory-gui-static:D \
                                          weston:D \
                                          *:S


# NOTE: The script must keep running for init service to work properly
#       Therefore, the last call must NOT exit
