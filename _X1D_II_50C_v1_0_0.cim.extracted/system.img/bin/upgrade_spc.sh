#!/system/bin/sh
#
# Upgrade SPC
#
# Usage:    upgrade_spc.sh [ path/firmware_name ]
#
# Some Usage Examples:
# upgrade_spc.sh                           - upgrade SPC using default firmware path
# upgrade_spc.sh /data/power-control.bin   - upgrade SPC using specific firmware path
#
# Author:   Cunkui Ye
# Date:     2018/05
# Version:  V1.2
# History:
#	V1.2 2018/05 Restart msg2dbus in the case of a failure before
#	V1.1 2018/02 Use uniform result show and exit
#	V1.0 2018/01 Original version
#

# Shared functions
. /system/bin/upgrade_common.sh

upgrade_target=SPC
firmware=/system/etc/firmware/rtnodes/power-control.bin
send_fw=/system/bin/send_fw
upgrade_fw=/system/bin/upgrade_fw
remote_path=upgrade://pwrctrl
node=pwrctrl

retry=3

function usage()
{
	echo
	echo Usage: upgrade_spc.sh [ path/firmware_name ]
	echo
	echo Some Usage Examples
	echo 1. Use default firmware path: $firmware
	echo upgrade_spc.sh
	echo 2. Use specific firmware path
	echo upgrade_spc.sh /data/power-control.bin
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
	upgrade_fw -n $node
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
echo Start to upgrade SPC at "`date +%Y/%m/%d\ %H:%M:%S`"
echo firmware: $firmware
pre_operations
operations $retry
result=$?
post_operations
echo End at "`date +%Y/%m/%d\ %H:%M:%S`"

result_show_and_exit $result