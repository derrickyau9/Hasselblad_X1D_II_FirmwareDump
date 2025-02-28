#!/system/bin/sh
#
# Upgrade Touch Panel
#
# Usage:    upgrade_tp.sh [force]
#
# Some Usage Examples:
# upgrade_tp.sh         - upgrade TP only if the target version is newer
# upgrade_tp.sh force   - upgrade TP by force
#
# Author:   Cunkui Ye
# Date:     2018/08
# Version:  V1.0
# History:
#	V1.0 2018/08 Original version
#

upgrade_target=TP
firmware=/system/etc/firmware/tpfw.bin
touch_dir=/proc/android_touch
force_upgrade=false
retry=3

cfg_ver_from_firmware=0
cfg_ver_from_ic=0
#fw_ver_from_firmware=0
#fw_ver_from_ic=0

function usage()
{
	echo
	echo Usage: upgrade_tp.sh [force]
	echo
}

# result_show
# $1 - upgrade target
# $2 - OK or ERROR
function result_show()
{
	if [ $# != 2 ]; then
		return
	fi

	if [ $2 = OK ]; then
		echo Congratulations. Upgrade $1 succeeded. ^_^
	elif [ $2 = ERROR ]; then
		echo Sorry! Upgrade $1 failed for some reason!!!
	fi
}

# result_show_and_exit
# $1 - exit code
function result_show_and_exit()
{
	if [ $1 = 0 ]; then
		result_show $upgrade_target OK
	elif [ $1 -ge 0 ]; then
		result_show $upgrade_target ERROR
	fi

	exit $1
}

function sanity_check()
{
	if [ ! -f $firmware ]; then
		echo Error! Firmware not found: $firmware
		result_show_and_exit 2
	fi

	if [ ! -d $touch_dir ]; then
		echo Error! Touch directory not found: $touch_dir
		result_show_and_exit 2
	fi
}

# cfg_ver=firmware[132]
function get_cfg_ver_from_firmware
{
	# busybox hexdump -s 128 -n 16 -e '16/1 "%02x " "\n"' tpfw.bin
	# busybox hexdump -s 132 -n 1 -e '16/1 "%d" "\n"' tpfw.bin
	cfg_ver=$(busybox hexdump -s 132 -n 1 -e '16/1 "%d" "\n"' $firmware)
	echo $cfg_ver
}

function get_cfg_ver_from_ic
{
	cfg_ver=$(cat $touch_dir/vendor | grep CONFIG_VER | busybox awk '{print $3}')
	# convert (e.g. 0x02) to a decimal number
	((cfg_ver=$cfg_ver))
	echo $cfg_ver
}

function get_fw_ver_from_firmware
{
	# Currently fw_ver will always remain unchanged
	echo unknown
}

function get_fw_ver_from_ic
{
	# Currently fw_ver will always remain unchanged
	echo unknown
}

function pre_operations()
{
	cfg_ver_from_firmware=$(get_cfg_ver_from_firmware)
	echo cfg_ver_from_firmware=$cfg_ver_from_firmware

	cfg_ver_from_ic=$(get_cfg_ver_from_ic)
	echo cfg_ver_from_ic=$cfg_ver_from_ic

	#fw_ver_from_firmware=$(get_fw_ver_from_firmware)
	#echo fw_ver_from_firmware=$fw_ver_from_firmware

	#fw_ver_from_ic=$(get_fw_ver_from_ic)
	#echo fw_ver_from_ic=$fw_ver_from_ic
}

function upgrade_and_check
{
	#1 Check before upgrade
	echo Check version from ic before upgrade
	cat $touch_dir/vendor

	#2 Upgrade
	echo Start to upgrade firmware, DO NOT operate the touch panel ...

	echo 0 > $touch_dir/diag
	echo 1 > $touch_dir/reset
	sleep 2
	echo t $(basename $firmware) > $touch_dir/debug
	echo 1 > $touch_dir/reset
	# echo 4 > $touch_dir/diag

	echo v > $touch_dir/debug
	cat $touch_dir/debug
	echo r:xb1 > $touch_dir/register
	cat $touch_dir/register
	cat $touch_dir/vendor

	#3 Check after upgrade
	cfg_ver_after_upgrade=$(get_cfg_ver_from_ic)
	if [ $cfg_ver_after_upgrade = $cfg_ver_from_firmware ]; then
		echo Same version between firmware and ic now.
		return 0
	else
		echo cfg_ver_from_firmware=$cfg_ver_from_firmware, but cfg_ver_after_upgrade=$cfg_ver_after_upgrade
		return 1
	fi
}

function operations()
{
	if [ $1 -ge 1 ]; then
		retry=$1
	fi

	if [ $force_upgrade = false ]; then
		if [ $cfg_ver_from_firmware -le $cfg_ver_from_ic ]; then
			echo No need to upgrade!
			echo If you still want to upgrade it, add \'force\' parameter.
			return 0
		fi
	else
		echo Force upgrade!
	fi

	loop=1
	while ((loop <= ${retry}))
	do
		echo ======== Upgrade and check $loop/$retry ========
		upgrade_and_check
		if [ $? = 0 ]; then
			echo Upgrade and check passed
			return 0
		fi
		echo Upgrade and check failed
		let "loop+=1"
	done

	return 1
}

function post_operations()
{
	return 0
}

if [ $# != 0 ]; then
	if [ $1 = force ]; then
		force_upgrade=true
		shift
	fi
fi

if [ $# = 1 ]; then
	if [ $1 = help ]; then
		usage
		exit 0
	else
		echo Error! Invalid parameter.
		usage
		result_show_and_exit 1
	fi
elif [ $# -ge 1 ]; then
	echo Error! Too many parameters.
	usage
	result_show_and_exit 1
fi

sanity_check
echo Start to upgrade $upgrade_target at "`date +%Y/%m/%d\ %H:%M:%S`"
echo firmware: $firmware
pre_operations
operations $retry
result=$?
post_operations
echo End at "`date +%Y/%m/%d\ %H:%M:%S`"

result_show_and_exit $result
