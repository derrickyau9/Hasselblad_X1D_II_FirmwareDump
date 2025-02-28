#########################################################################
# File Name: setup_factory_rw.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 18 Oct 2018 09:36:24 PM CST
#########################################################################
#!/bin/bash
umount /factory_data
if [ $? -ne 0 ]; then
	echo "umount factory_data failed:$?"
	exit 1
fi
mount_dev=/dev/block/platform/soc/f0000000.ahb/f0400000.dwmmc0/by-name/factory
mount -t ext4 -o rw $mount_dev /factory_data
if [ $? -ne 0 ]; then
	echo "mount factory failed:$?"
	exit 2
fi

exit 0
