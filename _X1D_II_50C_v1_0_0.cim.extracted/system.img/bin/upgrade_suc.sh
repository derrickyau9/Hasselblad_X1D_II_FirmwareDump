#!/system/bin/sh
#
# Upgrade SUC
#
# Usage:    upgrade_suc.sh [ path/firmware_name ]
#
# Some Usage Examples:
# upgrade_suc.sh                              - upgrade SUC using default firmware path
# upgrade_suc.sh /data/xsystem-control.bin    - upgrade SUC using specific firmware path
#
# Author:   Cunkui Ye
# Date:     2018/06
# Version:  V1.5
# History:
#	V1.5 2018/06 Support reset and autostart after SUC upgrade
#	V1.4 2018/02 Set default firmware path for multiple boards
#	V1.3 2018/02 Use uniform result show and exit
#	V1.2 2018/01 Stop msg2dbus before upgrade, and start it again after upgrade
# 	V1.1 2018/01 After reboot SUC, add 100ms*5 delay before subsequent operations
#	V1.0 2017/12 Original version
#

# Shared functions
. /system/bin/upgrade_common.sh

upgrade_target=SUC
tty=/dev/ttyS1
baudrate=115200
stm32flash=/system/bin/stm32flash
retry=3

# supported product type
prod_type_X1DM2=12
prod_type_CFV=14
prod_type=`getprop dji.prod_type`

function usage()
{
	echo
	echo Usage: upgrade_suc.sh [ path/firmware_name ]
	echo
	echo Some Usage Examples
	echo 1. Use default firmware path
	echo upgrade_suc.sh
	echo 2. Use specific firmware path
	echo upgrade_suc.sh /data/xsystem-control.bin
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
	if [ ! $firmware ]; then
		case $prod_type in
			$prod_type_X1DM2)
				firmware=/system/etc/firmware/rtnodes/xsystem-control.bin
			;;
			$prod_type_CFV)
				firmware=/system/etc/firmware/rtnodes/cfv-control.bin
			;;
			"")
				echo Error! Failed to get product type
				result_show_and_exit 4
			;;
			*)
				echo Error! Product type not supported: $prod_type
				result_show_and_exit 4
			;;
		esac
	fi

	if [ ! -f $firmware ]; then
		echo Error! Firmware not found: $firmware
		result_show_and_exit 2
	fi

	if [ ! -f $stm32flash ]; then
		echo Error! Flash tool not found: $stm32flash
		result_show_and_exit 2
	fi
}

function pre_operations()
{
	stop_live_view

	# set autostart property of SUC before msg2dbus close
	odindb-send -s suc -p autostart 1
	# set suc_upgrading property of sysman to true so that usb doesn't disconnect and reconnect
	odindb-send -s sysman -p suc_upgrading true
	# msg2dbus may send message using the same tty device, so stop it before upgrade
	setprop ctl.stop msg2dbus

	loop=0
	exitcode=0
	while [ $loop -le 10 ]
	do
		(( loop++ ))
		usleep 100
		ps | grep msg2dbus > /dev/null
		exitcode=$?

		if [ $exitcode = 1 ]; then
			break
		fi
	done

    if [ $exitcode = 0 ]; then
		echo Error! msg2dbus is still running, which may affect SUC upgrade.
		result_show_and_exit 3
	fi

	return 0
}

function upgrade
{
	#firmware_size=`stat -c %s $firmware`

	echo Write firmware to flash
	# Example:
	# stm32flash -i '13&31,-31' -f -v -w /data/xsystem-control.bin -b 115200 /dev/ttyS1
	stm32flash -i '13&31,-31,,,,,' -f -v -w $firmware -b $baudrate $tty
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
	# Start msg2dbus again after upgrade
	# setprop ctl.start msg2dbus

	if [ $# = 1 ]; then
		if [ $1 = 0 ]; then
			echo Will reset device in 3 seconds ...
			(sleep 3; stm32flash -i ':31,-31' $tty) &
		fi
	fi

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
echo Start to upgrade SUC at "`date +%Y/%m/%d\ %H:%M:%S`"
echo firmware: $firmware
echo tty: $tty
pre_operations
operations $retry
result=$?
post_operations $result
echo End at "`date +%Y/%m/%d\ %H:%M:%S`"

result_show_and_exit $result
