#!/system/bin/sh
#
# Upgrade FPGA
#
# Usage:    upgrade_fpga.sh [recovery] [path/firmware_name]
#
# Some Usage Examples:
# upgrade_fpga.sh                  - upgrade FPGA using default firmware path
# upgrade_fpga.sh /data/all.bin    - upgrade FPGA using specific firmware path
# upgrade_fpga.sh recovery                  - upgrade FPGA recovery image using default firmware path
# upgrade_fpga.sh recovery /data/all.bin    - upgrade FPGA recovery image using specific firmware path
#
# Author:   Cunkui Ye
# Date:     2018/09
# Version:  V1.3
# History:
#	V1.3 2018/09 Support upgrade recovery image
#	V1.2 2018/05 Restart msg2dbus in the case of a failure before
#	V1.1 2018/02 Use uniform result show and exit
#	V1.0 2018/01 Original version
#

# Shared functions
. /system/bin/upgrade_common.sh

upgrade_target=FPGA
firmware=/system/etc/firmware/rtnodes/fpga_all.bin
send_fw=/system/bin/send_fw
upgrade_fw=/system/bin/upgrade_fw
remote_path=upgrade://farmus
node=farmus
node_recovery=farmus_recovery
upgrade_recovery=false

retry=3

function usage()
{
	echo
	echo Usage: upgrade_fpga.sh [recovery] [path/firmware_name]
	echo
	echo Some Usage Examples
	echo 1. Use default firmware path: $firmware
	echo upgrade_fpga.sh
	echo 2. Use specific firmware path
	echo upgrade_fpga.sh /data/all.bin
	echo 3. Use default firmware path to upgrade recovery image
	echo upgrade_fpga.sh recovery
	echo 4. Use specific firmware path to upgrade recovery image
	echo upgrade_fpga.sh recovery /data/all.bin
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
	if [ ! -f $send_fw ]; then
		echo Error! Upgrade tool not found: $send_fw
		result_show_and_exit 2
	fi

	if [ ! -f $upgrade_fw ]; then
		echo Error! Upgrade tool not found: $upgrade_fw
		result_show_and_exit 2
	fi

	if [ ! -f $firmware ]; then
		echo Error! Firmware not found: $firmware
		result_show_and_exit 2
	fi

	ps | grep msg2dbus > /dev/null
	if [ $? != 0 ]; then
		echo Error! msg2dbus not running.
		result_show_and_exit 3
	fi
}

function pre_operations()
{
	stop_live_view
	return 0
}

function upgrade
{
	echo Send firmware: $firmware
	send_fw -l $firmware -r $remote_path
	if [ $? != 0 ]; then
		echo Error! Failed to send firmware.
		return 1
	fi

	echo Check firmware version before upgrade
	upgrade_fw -c -n $node
	if [ $? != 0 ]; then
		echo Warning! Failed to check firmware version before upgrade.
	fi

	echo Request the remote node to upgrade
	if [ $upgrade_recovery = true ]; then
		upgrade_fw -n $node_recovery
	else
		upgrade_fw -n $node
	fi
	if [ $? != 0 ]; then
		echo Error! Failed to upgrade firmware.
		return 1
	fi

	return 0
}

function operations()
{
	if [ $1 -ge 1 ]; then
		retry=$1
	fi

	loop=1
	while ((loop <= ${retry}))
	do
		echo ======== Upgrade $loop/$retry ========
		if [ $loop != 1 ]; then
			echo Restart msg2dbus in the case of a failure before ...
			setprop ctl.restart msg2dbus
			sleep 3
			echo Check msg2dbus
			ps | grep msg2dbus
		fi
		upgrade
		if [ $? = 0 ]; then
			echo Upgrade finished
			return 0
		fi
		echo Upgrade failed
		let "loop+=1"
	done

	return 1
}

function post_operations()
{
	return 0
}

if [ $# != 0 ]; then
	if [ $1 = recovery ]; then
		upgrade_recovery=true
		shift
	fi
fi

if [ $# = 1 ]; then
	if [ $1 = help ]; then
		usage
		exit 0
	else
		firmware=$1
	fi
elif [ $# -ge 1 ]; then
	echo Error! Too many parameters.
	usage
	result_show_and_exit 1
fi

sanity_check
echo Start to upgrade FPGA at "`date +%Y/%m/%d\ %H:%M:%S`"
echo firmware: $firmware
pre_operations
operations $retry
result=$?
post_operations
echo End at "`date +%Y/%m/%d\ %H:%M:%S`"

result_show_and_exit $result