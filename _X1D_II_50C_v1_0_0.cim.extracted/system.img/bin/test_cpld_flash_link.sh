#!/system/bin/sh
#
# Link test for CPLD flash
#
# Usage:    test_cpld_flash_link.sh
#
# Author:   Cunkui Ye
# Date:     2018/05
# Version:  V1.0
#

test_target='CPLD flash'

mtd=/dev/mtd/mtd0
gpio_number=81
spinor_ko=/system/lib/modules/dji-spinor.ko
spinor_ko_rmmod=dji_spinor

# NOTE: Dependent on android property system
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
	elif [ $PROD_TYPE = $PROD_TYPE_CFV ]; then
		if [ $HW_REV = 0 ]; then
			gpio_number=7
		fi
	fi
}

# result_show_and_exit
# $1 - exit code
function result_show_and_exit()
{
	if [ $1 = 0 ]; then
		echo Congratulations. Link test for $test_target succeeded. ^_^
	elif [ $1 -ge 0 ]; then
		echo Sorry! Link test for $test_target failed!!!
	fi

	exit $1
}

function sanity_check()
{
	if [ ! -f $spinor_ko ]; then
		echo Error! Kernel module not found: $spinor_ko
		result_show_and_exit 2
	fi
}

function pre_test()
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

# cpld flash link test
function do_test()
{
	ls -all $mtd
	if [ $? != 0 ]; then
		echo Error! List file $mtd failed
		return 1
	fi

	mtd_read=/data/mtd0_`date +%Y%m%d_%H%M%S`.bin
	echo Read flash to $mtd_read
	dd if=$mtd of=$mtd_read bs=1024 count=256
	if [ $? != 0 ]; then
		echo Read flash failed
		return 1
	fi
	rm $mtd_read

	return 0
}

function post_test()
{
	# GPIO control
	echo low > /sys/class/gpio/gpio${gpio_number}/direction
	echo ${gpio_number} > /sys/class/gpio/unexport

	# Module remove
	rmmod $spinor_ko_rmmod
}

fix_legacy_hardware
sanity_check
echo mtd: $mtd
echo gpio: $gpio_number
pre_test
do_test
result=$?
post_test

result_show_and_exit $result
