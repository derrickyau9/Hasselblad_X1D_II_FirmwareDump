#!/system/bin/sh

mkdir -p /data/dji/log
mkdir -p /blackbox

# record fsck log
fsck_dir=/data/dji/fsck
mkdir -p $fsck_dir
time_record=$(busybox date +%Y.%m.%d-%H:%M:%S)

# judge blackbox is formated or not. if not, format it.
mount_dev=/dev/block/platform/soc/f0000000.ahb/f0400000.dwmmc0/by-name/blackbox
e2fsck -y $mount_dev > $fsck_dir/blackbox.fsck
if [ $? -eq 4 -o $? -eq 8 ]; then
# 4: File system errors left uncorrected
# 8: Operational error
    echo $time_record > $fsck_dir/blackbox.fmt
    busybox mke2fs -b 4096 -T ext4 $mount_dev
fi
mount -t ext4 $mount_dev /blackbox

ret=$?
echo $ret
# check blackbox size , if < 50M, then format
check_blackbox.sh > $fsck_dir/blackbox_format.log
ret_bb=$?
if [ $ret -ne 0 ];then
    echo "Start format $mount_dev"
    busybox mke2fs -b 4096 -T ext4 $mount_dev
    mount -t ext4 $mount_dev /blackbox
    echo "Format & mount $mount_dev success"
else
    if [ $ret_bb -ne 0 ];then
        echo "Start format $mount_dev"
        umount /blackbox
        busybox mke2fs -b 4096 -T ext4 $mount_dev
        mount -t ext4 $mount_dev /blackbox
        echo "Format & mount $mount_dev success"
        mkdir -p /blackbox/system
        cp $fsck_dir/blackbox_format.log /blackbox/system/
    fi
fi

if [ ! -e /blackbox/system ];then
    mkdir -p /blackbox/system
fi

# save blackbox.fmt to blackbox/system
if [ ! -e /blackbox/system/blackbox.fmt -a -e $fsck_dir/blackbox.fmt ];then
    mkdir -p /blackbox/system
    cp $fsck_dir/blackbox.fmt /blackbox/system/blackbox.fmt
fi

# judge cache partition is formated or not. if not, format it.
mount_dev=/dev/block/platform/soc/f0000000.ahb/f0400000.dwmmc0/by-name/cache
e2fsck -y $mount_dev > $fsck_dir/cache.fsck
if [ $? -eq 4 -o $? -eq 8 ]; then
# 4: File system errors left uncorrected
# 8: Operational error
    echo $time_record > $fsck_dir/cache.fmt
    busybox mke2fs -b 4096 -T ext4 $mount_dev
fi
mount -t ext4 $mount_dev /cache
ret=$?
mkdir -p /cache/recovery

echo $ret
if [ $ret -ne 0 ];then
    echo "Start format $mount_dev"
    busybox mke2fs -b 4096 -T ext4 $mount_dev
    mount -t ext4 $mount_dev /cache
    mkdir -p /cache/recovery
    echo "Format & mount $mount_dev success"
fi

# judge factory partition is formated or not. if not, format it.
mount_dev=/dev/block/platform/soc/f0000000.ahb/f0400000.dwmmc0/by-name/factory
e2fsck -y $mount_dev > $fsck_dir/factory.fsck
if [ $ret -eq 4 -o $ret -eq 8 ]; then
# 4: File system errors left uncorrected
# 8: Operational error
    echo $time_record > $fsck_dir/factory.fmt
    busybox mke2fs -b 4096 -T ext4 $mount_dev
    if [ $ret -eq 4 ]; then
        echo "File system error in factory_data" >> $fsck_dir/factory.fmt
    else
        echo "Operational system error in factory_data" >> $fsck_dir/factory.fmt
    fi
fi

mount -t ext4 -o ro $mount_dev /factory_data
ret=$?
if [ $ret -ne 0 ];then
    echo "Start format $mount_dev"
    busybox mke2fs -b 4096 -T ext4 $mount_dev
    mount -t ext4 -o ro $mount_dev /factory_data
    echo "Format & mount $mount_dev success" >> $fsck_dir/factory.fmt
fi

# check if cali partition is formated, or format it.
mount_dev=/dev/block/platform/soc/f0000000.ahb/f0400000.dwmmc0/by-name/cali
mkdir /cali
e2fsck -y $mount_dev > $fsck_dir/cali.fsck
if [ $? -eq 4 -o $? -eq 8 ]; then
# 4: File system errors left uncorrected
# 8: Operational error
    echo $time_record > $fsck_dir/cali.fmt
    busybox mke2fs -b 4096 -T ext4 $mount_dev
fi
mount -t ext4 $mount_dev /cali

ret=$?
echo $ret
if [ $ret -ne 0 ];then
    echo "Start format $mount_dev"
    busybox mke2fs -b 4096 -T ext4 $mount_dev
    mount -t ext4 $mount_dev /cali
    echo "Format & mount $mount_dev success"
fi

# clean bb .tmp file
find /blackbox -name "*.tmp" -print0 | xargs -0 rm

setprop dji.blackbox_logs_service 1
