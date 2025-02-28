#!/system/bin/sh
#
# Upgrade CPLD
#
# Usage:    upgrade_cpld.sh [ path/firmware_name ]
#
# Some Usage Examples:
# upgrade_cpld.sh                          - upgrade CPLD using default firmware path
# upgrade_cpld.sh /data/cpld_ver0001.bit   - upgrade CPLD using specific firmware path
#
# Author:   Cunkui Ye
# Date:     2018/06
# Version:  V1.3
# History:
#	V1.3 2018/06 Add compatibility for multiple screens
#	V1.2 2018/02 Add compatibility for multiple boards
#	V1.1 2018/02 Use uniform result show and exit
#	V1.0 2017/12 Original version
#

upgrade_target=CPLD
mtd=/dev/mtd/mtd0
gpio_number=81
spinor_ko=/system/lib/modules/dji-spinor.ko
spinor_ko_rmmod=dji_spinor
firmware=/system/etc/firmware/cpld/display_boe_convertor.bit
blocksize=4096
retry=3

# NOTE: has dependency on android property system
function fix_legacy_hardware()
{
	PROD_TYPE_X1DM2=12
	PROD_TYPE_CFV=14
	PROD_TYPE=`getprop dji.prod_type`
	HW_REV=`getprop dji.hw_rev`

	if [ $PROD_TYPE = $PROD_TYPE_X1DM2 ]; then
		if [ $HW_REV = 1 ]; then
			gpio_number=7
		fi
		if [ $HW_REV -lt 4 ]; then
			firmware=/system/etc/firmware/cpld/display_convertor.bit
		fi
	elif [ $PROD_TYPE = $PROD_TYPE_CFV ]; then
		firmware=/system/etc/firmware/cpld/display_convertor.bit
		if [ $HW_REV = 0 ]; then
			gpio_number=7
		fi
	fi
}

function usage()
{
	echo
	echo Usage: upgrade_cpld.sh [ path/firmware_name ]
	echo
	echo Some Usage Examples
	echo 1. Use default firmware path: $firmware
	echo upgrade_cpld.sh
	echo 2. Use specific firmware path
	echo upgrade_cpld.sh /data/cpld_ver0001.bit
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

	if [ ! -f $spinor_ko ]; then
		echo Error! Kernel module not found: $spinor_ko
		result_show_and_exit 2
	fi
}

function pre_operations()
{
	# GPIO control
	echo $gpio_number > /sys/class/gpio/export
	echo high > /sys/class/gpio/gpio${gpio_number}/direction
	gpio_value=`cat /sys/class/gpio/gpio${gpio_number}/value`
	if [ $gpio_value != 1 ]; then
		echo Error! GPIO control failed: gpio${gpio_number}
		result_show_and_exit 3
	fi

	# Module insert
	insmod $spinor_ko
}

function upgrade_and_check
{
	echo Check firmware version before upgrade
	test_i2c 4 r 0x20 0 4

	firmware_size=`stat -c %s $firmware`
	let block_count=firmware_size/blocksize+4
	#echo block_count=$block_count

	echo Erase flash
	#flash_erase -w $mtd 0 0
	flash_erase $mtd 0 $block_count
	if [ $? != 0 ]; then
		echo Error! Flash erase failed
		return 1
	fi

	echo Write firmware to flash
	cat $firmware > $mtd
	if [ $? != 0 ]; then
		echo Error! Flash write failed
		return 1
	fi

	mtd_read=/data/mtd0_`date +%Y%m%d_%H%M%S`.bin
	echo Read flash to $mtd_read
	dd if=$mtd of=$mtd_read bs=$firmware_size count=1

	echo Compare md5
	firmware_md5=`md5sum -b $firmware`
	mtd_read_md5=`md5sum -b $mtd_read`
	echo firmware_md5=$firmware_md5
	echo mtd_read_md5=$mtd_read_md5

	if [ $firmware_md5 = $mtd_read_md5 ]; then
		echo Same md5
		rm $mtd_read
		return 0
	else
		echo Different md5
		echo Please check $mtd_read
		return 1
	fi
}

function operations()
{
	if [ $1 -ge 1 ]; then
		retry=$1
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
	# GPIO control
	echo low > /sys/class/gpio/gpio${gpio_number}/direction
	echo ${gpio_number} > /sys/class/gpio/unexport

	# Module remove
	rmmod $spinor_ko_rmmod
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

fix_legacy_hardware
sanity_check
echo Start to upgrade CPLD at "`date +%Y/%m/%d\ %H:%M:%S`"
echo firmware: $firmware
echo mtd: $mtd
pre_operations
operations $retry
result=$?
post_operations
echo End at "`date +%Y/%m/%d\ %H:%M:%S`"

result_show_and_exit $result
