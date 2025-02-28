#!/system/bin/sh
#
# Link test for Mode Dial Selector
#
# Usage:    test_mode_dial_link.sh
#
# Author:   Cunkui Ye
# Date:     2018/05
# Version:  V1.0
#

test_target='Mode Dial Selector'

# md for Mode Dial
md_name=(A M MQ C1 C2 C3 Video Rectangle P S)
md_gpio=(268 269 270 271 272 273 274 275 276 277)
md_count=(0 0 0 0 0 0 0 0 0 0)

# timeout setting, which is not so accurate, 100 for ~15s
wait_timeout=0
max_timeout=100

# gpio value when a mode dialed
dialed_value=0

# index (0-9)
last_index=none
current_index=none

# If we had to export the gpio's we will unexport them, but if they were
# already exported we will leave them
gpio_exported=0

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

# Get current index of dialed mode
function get_current_index()
{
	for i in ${!md_gpio[@]}
	do
		gpio_value=`cat /sys/class/gpio/gpio${md_gpio[i]}/value`
		if [ $gpio_value = $dialed_value ]; then
			current_index=$i
			return 0
		fi
	done

	# While dialing the selector, there's some intermediate state that no gpio is of dialed_value
	return 1
}

# Scan dialed mode
function scan_dialed_mode()
{
	get_current_index
	if [ $current_index != $last_index ]; then
		let md_count[current_index]++
		echo Current dialed mode: ${md_name[current_index]} - ${md_count[current_index]} times
		last_index=$current_index
		wait_timeout=0
	fi
}

# Check if all modes have been dialed at least once
function check_all_modes_dialed()
{
	for i in ${!md_count[@]}
	do
		if [ ${md_count[i]} = 0 ]; then
			return 0
		fi
	done

	return 1
}

function pre_test()
{
	for gpio in ${md_gpio[@]}
	do
		if [ ! -e /sys/class/gpio/gpio${gpio} ]; then
			echo $gpio > /sys/class/gpio/export
			gpio_exported=1
		fi
	done
}

function do_test()
{
	get_current_index
	last_index=$current_index
	echo Initial mode: ${md_name[current_index]}
	echo Please rotate the Mode Dial Selector ...

	while true
	do
		scan_dialed_mode
		check_all_modes_dialed
		all_mode_dialed=$?
		if [ $all_mode_dialed = 1 ]; then
			echo All modes dialed.
			return 0
		fi

		let wait_timeout++
		if [ $wait_timeout -gt $max_timeout ]; then
			echo Error! Timeout!
			return 1
		fi

		usleep 100000
	done

	return 1
}

function post_test()
{
	if [ $gpio_exported -ne 0 ]; then
		for gpio in ${md_gpio[@]}
		do
			echo $gpio > /sys/class/gpio/unexport
		done
	fi
}

pre_test
do_test
result=$?
post_test

result_show_and_exit $result
