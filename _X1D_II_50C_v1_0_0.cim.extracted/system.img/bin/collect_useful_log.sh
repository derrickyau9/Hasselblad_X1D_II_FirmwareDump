#########################################################################
# File Name: collect_useful_log.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Thu 22 Nov 2018 10:34:55 AM CST
#########################################################################
#!/bin/bash
collect_useful_log()
{
	echo ----------------- last test app log --------------------
	testlogs=`ls /data/dji/log/test_*`
	for file in $testlogs
	do
		echo ------------------- $file ------------------
		ls -l $file
		cat $file
	done

	echo ----------------- /blackbox --------------------
	ls -l /blackbox

	echo ----------------- /data --------------------
	ls -l /data
	ls -l /data/dji
	ls -l /data/dji/fsck

	echo ----------------- /factory_data --------------------
	ls -l /factory_data

	echo ----------------- crash_counter --------------------
	ls -l /data/dji/log/crash_counter.log
	cat /data/dji/log/crash_counter.log

	echo ----------------- eagle version --------------------
	getprop dji.build.version
	cat /proc/version

	echo ----------------- FARM version --------------------
	upgrade_fw -c -n farmus 2>/blackbox/system/log_tmp
	cat /blackbox/system/log_tmp

	echo ----------------- SPC version --------------------
	upgrade_fw -c -n pwrctrl 2>/blackbox/system/log_tmp
	cat /blackbox/system/log_tmp

	echo ----------------- SUC version --------------------
	upgrade_fw -c -n suc 2>/blackbox/system/log_tmp
	cat /blackbox/system/log_tmp

	echo ----------------- CPLD version --------------------
	test_i2c 4 r 0x20 0 4

	echo ----------------- Touch Panel version --------------------
	cat /proc/android_touch/vendor

	echo ----------------- USB2SD version --------------------
	gl_inquiry
	echo

	echo ----------------- Lens version --------------------
	odindb-send -s suc -m module_firmware_version 2

	echo ----------------- unrd --------------------
	unrd

	echo ----------------- property --------------------
	getprop

	echo ----------------- cmdline --------------------
	cat /proc/cmdline

	echo ----------------- prodconfig --------------------
	prodconfig-tool --print 2>/blackbox/system/log_tmp
	cat /blackbox/system/log_tmp
	rm /blackbox/system/log_tmp

	echo ----------------- memleak --------------------
	cat /sys/kernel/debug/kmemleak

	echo ----------------- thread info --------------------
	top -t -n 1

	echo ----------------- disk usage --------------------
	df
	du /data

	echo ----------------- tombstones --------------------
	tombstones=`ls /data/tombstones`
	for file in $tombstones
	do
		echo ------------------- $file ------------------
		ls -l /data/tombstone/$file
		cat /data/tombstones/$file
	done

	echo ----------------- dmesg --------------------
	dmesg
}

collect_useful_log > /blackbox/system/collect_useful_information.log
