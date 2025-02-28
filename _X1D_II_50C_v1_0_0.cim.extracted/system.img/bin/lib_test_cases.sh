. lib_test_utils.sh

#
# LED
#

LED_GENERIC_FLAG=01
LED_REQUESTER_ID=0000
LED_IDENTITY_ID=00
LED_REG_BLINK_ACTION0=010a6464
LED_REG_BLINK_ACTION1=000a6464
LED_REG_BLINK_ACTION2=00000000
LED_REG_BLINK_ACTION3=00000000
LED_REG_BLINK_ACTION4=00000000
LED_REG_BLINK_ACTION5=00000000
LED_REG_BLINK_ACTION6=00000000
LED_REG_BLINK_ACTION7=00000000

LED_PRIORITY=01

RED_LED_PRIORITY=02
GREEN_LED_PRIORITY=03
YELLOW_LED_PRIORITY=04

LED_SHOWTIME=00
LED_TYPE=01
LED_TIMEOUT=0111
LED_DESCRIPTION=0102030405060708090a

FC_CMDSET=3
REGISTER_LED_CMDID=0xbc
SET_LED_CMDID=0xbe

LED_YELLOW_BLINK_ACTION0=040a6464
LED_YELLOW_BLINK_ACTION1=000a6464
LED_YELLOW_BLINK_ACTION2=00000000
LED_YELLOW_BLINK_ACTION3=00000000
LED_YELLOW_BLINK_ACTION4=00000000
LED_YELLOW_BLINK_ACTION5=00000000
LED_YELLOW_BLINK_ACTION6=00000000
LED_YELLOW_BLINK_ACTION7=00000000

LED_GREEN_BLINK_ACTION0=020a6464
LED_GREEN_BLINK_ACTION1=000a6464
LED_GREEN_BLINK_ON_ACTION1=020a6464
LED_GREEN_BLINK_ACTION2=00000000
LED_GREEN_BLINK_ACTION3=00000000
LED_GREEN_BLINK_ACTION4=00000000
LED_GREEN_BLINK_ACTION5=00000000
LED_GREEN_BLINK_ACTION6=00000000
LED_GREEN_BLINK_ACTION7=00000000


LED_SET_ACTION_NUM=02
LED_SET_REQUESTER_ID=0000


yellow_requester_id=00
yellow_action_id=00
led_yellow_register()
{
    led_reg_ack=`dji_mb_ctrl -S test -R local -g 3 -t 6 -s $FC_CMDSET -c $REGISTER_LED_CMDID ${LED_GENERIC_FLAG}${LED_REQUESTER_ID}${LED_IDENTITY_ID}${LED_YELLOW_BLINK_ACTION0}${LED_YELLOW_BLINK_ACTION1}${LED_YELLOW_BLINK_ACTION2}${LED_YELLOW_BLINK_ACTION3}${LED_YELLOW_BLINK_ACTION4}${LED_YELLOW_BLINK_ACTION5}${LED_YELLOW_BLINK_ACTION6}${LED_YELLOW_BLINK_ACTION7}${YELLOW_LED_PRIORITY}${LED_SHOWTIME}${LED_TYPE}${LED_TIMEOUT}${LED_DESCRIPTION}`
    echo $led_reg_ack

    if [ $? != 0 ]; then
        exit 1;
    fi

    raw_data=${led_reg_ack##*data:}
    result=`echo $raw_data | busybox awk '{printf $1;}'`
    yellow_requester_id=`echo $raw_data | busybox awk '{printf $2$3;}'`
    yellow_action_id=`echo $raw_data | busybox awk '{printf $5;}'`


}

led_yellow_blink()
{
    echo "send yellow blink to FC"
    dji_mb_ctrl -S test -R local -g 3 -t 6 -s 3 -c 0xbe 02${yellow_requester_id}${yellow_action_id}01${yellow_action_id}01
}

green_requester_id=00
green_action_id=00
led_green_register()
{
    led_reg_ack=`dji_mb_ctrl -S test -R local -g 3 -t 6 -s $FC_CMDSET -c $REGISTER_LED_CMDID ${LED_GENERIC_FLAG}${LED_REQUESTER_ID}${LED_IDENTITY_ID}${LED_GREEN_BLINK_ACTION0}${LED_GREEN_BLINK_ON_ACTION1}${LED_GREEN_BLINK_ACTION2}${LED_GREEN_BLINK_ACTION3}${LED_GREEN_BLINK_ACTION4}${LED_GREEN_BLINK_ACTION5}${LED_GREEN_BLINK_ACTION6}${LED_GREEN_BLINK_ACTION7}${GREEN_LED_PRIORITY}${LED_SHOWTIME}${LED_TYPE}${LED_TIMEOUT}${LED_DESCRIPTION}`
    echo $led_reg_ack

    if [ $? != 0 ]; then
        exit 1;
    fi

    raw_data=${led_reg_ack##*data:}
    result=`echo $raw_data | busybox awk '{printf $1;}'`
    green_requester_id=`echo $raw_data | busybox awk '{printf $2$3;}'`
    green_action_id=`echo $raw_data | busybox awk '{printf $5;}'`

}


led_green_on()
{
    dji_mb_ctrl -S test -R local -g 3 -t 6 -s 3 -c 0xbe 02${green_requester_id}${green_action_id}01${green_action_id}01
}


red_requester_id=00
red_action_id=00
led_red_register()
{
    led_reg_ack=`dji_mb_ctrl -S test -R local -g 3 -t 6 -s $FC_CMDSET -c $REGISTER_LED_CMDID ${LED_GENERIC_FLAG}${LED_REQUESTER_ID}${LED_IDENTITY_ID}${LED_REG_BLINK_ACTION0}${LED_REG_BLINK_ACTION1}${LED_REG_BLINK_ACTION2}${LED_REG_BLINK_ACTION3}${LED_REG_BLINK_ACTION4}${LED_REG_BLINK_ACTION5}${LED_REG_BLINK_ACTION6}${LED_REG_BLINK_ACTION7}${RED_LED_PRIORITY}${LED_SHOWTIME}${LED_TYPE}${LED_TIMEOUT}${LED_DESCRIPTION}`

    echo $led_reg_ack

    if [ $? != 0 ]; then
        exit 1;
    fi

    raw_data=${led_reg_ack##*data:}
    result=`echo $raw_data | busybox awk '{printf $1;}'`
    red_requester_id=`echo $raw_data | busybox awk '{printf $2$3;}'`
    red_action_id=`echo $raw_data | busybox awk '{printf $5;}'`

}

led_red_blink()
{
    echo "send red blink to FC"
    dji_mb_ctrl -S test -R local -g 3 -t 6 -s 3 -c 0xbe 02${red_requester_id}${red_action_id}01${red_action_id}01
}

led_green_blink()
{
    echo "send green blink to FC"
    led_reg_ack=`dji_mb_ctrl -S test -R local -g 3 -t 6 -s $FC_CMDSET -c $REGISTER_LED_CMDID ${LED_GENERIC_FLAG}${LED_REQUESTER_ID}${LED_IDENTITY_ID}${LED_GREEN_BLINK_ACTION0}${LED_GREEN_BLINK_ACTION1}${LED_GREEN_BLINK_ACTION2}${LED_GREEN_BLINK_ACTION3}${LED_GREEN_BLINK_ACTION4}${LED_GREEN_BLINK_ACTION5}${LED_GREEN_BLINK_ACTION6}${LED_GREEN_BLINK_ACTION7}${GREEN_LED_PRIORITY}${LED_SHOWTIME}${LED_TYPE}${LED_TIMEOUT}${LED_DESCRIPTION}`
    echo $led_reg_ack

    if [ $? != 0 ]; then
        exit 1;
    fi

    raw_data=${led_reg_ack##*data:}
    result=`echo $raw_data | busybox awk '{printf $1;}'`
    requester_id=`echo $raw_data | busybox awk '{printf $2$3;}'`
    action_id=`echo $raw_data | busybox awk '{printf $5;}'`

    dji_mb_ctrl -S test -R local -g 3 -t 6 -s 3 -c 0xbe 02${requester_id}${action_id}01${action_id}01
}

#
# link path test cases
#

linked_to_camera()
{
	cmd_check_ver camera 1 0
}

linked_to_flyctl()
{
	cmd_check_ver flyctl 3 0
}

linked_to_gimbal()
{
	cmd_check_ver gimbal 4 0
}

linked_to_battery()
{
	cmd_check_ver battery 11 0
}

linked_to_esc()
{
	cmd_check_ver esc 12 $1
}

# 0x1707(dji_vision) is local channel of 1860
# so no need for AMT aging_test
linked_to_mvision()
{
	cmd_check_ver mvision 17 7
}

# ma2100 version is got from the log,
# so we check the USB to decide whether everything works
linked_to_bvision()
{
	busybox lsusb | grep 040e 1>/dev/null
	local r=$?
	if [ $r == 0 ]; then
		echo linked_to_bvision\($1\): PASSED
	else
		echo linked_to_bvision\($1\): FAILED, errno=$r
	fi
	return $r
#	cmd_check_ver ma2100 8 2
#	cmd_check_ver 18 7
}

linked_to_ltc_fpga()
{
	cmd_check_ver ltc_fpga 8 3
}

linked_to_ultrasonic()
{
	cmd_check_ver ultrasonic 8 4
}

check_ultrasonic_reset_pin()
{
	gpio_write $ULTRA_RESET 0
	sleep 1
	cmd_check_ver ultrasonic_rst 8 4 1>/dev/null
	if [ $? == 0 ];then
		echo "FAILED: Still can got version after ultrasonic reset!"
		return 1
	fi

	gpio_write $ULTRA_RESET 1
	sleep 3
	cmd_check_ver ultrasonic_rst 8 4 || return $?
}

factory_out_check_link()
{
	linked_to_ltc_fpga || return $?
	linked_to_camera || return $?
	linked_to_flyctl || return $?
	linked_to_bvision || return $?
}


gimbal_enter_aging_mode()
{
    local n=0
    local retry=3
    while [ $n -lt $retry ]; do
        let n+=1
        dji_mb_ctrl -S test -R diag -g 4 -t 0 -s 0 -c 0xf4 -1 1
        if [ $? == 0 ]; then
            return 0
        fi
    done
    return 1
}

gimbal_exit_aging_mode()
{
    dji_mb_ctrl -S test -R diag -g 4 -t 0 -s 0 -c 0xf5
}


gimbal_aging_check()
{
    local n=0
    local retry=2
    while [ $n -lt $retry ]; do
        let n+=1
        info=`dji_mb_ctrl -S test -R diag -g 4 -t 0 -s 0 -c 0xf6`
        if [ $? != 0 ]; then
            sleep 1
            continue
        fi
        #echo $info
        echo $info
        resp_data=${info##*data:}
        result=`echo $resp_data | busybox awk '{print $2}'`
        val=`echo $resp_data | busybox awk '{print $3}'`
        if [ $result != "00" ]; then
            echo gimbal aging failed, resp data: $resp_data
            return 1
        else
            return 0
        fi
    done
    return 1


}

aging_test_check_link()
{
	#linked_to_bvision || return $?
	#linked_to_ultrasonic || return $?
	#linked_to_gimbal || return $?
	#linked_to_flyctl || return $?

    linked_to_gimbal
    if [ $? != 0 ]; then
        return 1
    fi

    gimbal_aging_check
    if [ $? != 0 ]; then
        return 2
    fi

    linked_to_flyctl
    if [ $? != 0 ]; then
        return 3
    fi

    linked_to_esc 0
    if [ $? != 0 ]; then
        return 4
    fi

    linked_to_esc 1
    if [ $? != 0 ]; then
        return 5
    fi

    linked_to_esc 2
    if [ $? != 0 ]; then
        return 6
    fi

    linked_to_esc 3
    if [ $? != 0 ]; then
        return 7
    fi

    linked_to_battery
    if [ $? != 0 ]; then
        return 8
    fi

    echo aging test check link ok
    return 0
}

# program fpga
program_fpga()
{
	cpld_dir=/data/dji/amt/factory_out/cpld
	mkdir -p $cpld_dir
	rm -rf $cpld_dir/log.txt
	local r=0
	local n=0
	while [ $n -lt 3 ]; do
		let n+=1
		test_fpga /dev/i2c-1 /dev/i2c-1 64 400000 /vendor/firmware/cpld_v4a.fw >> $cpld_dir/log.txt
		r=$?
		if [ $r == 0 ]; then
#			boot.mode will be remove in the ENC step
#			env -d boot.mode
			#echo factory > /data/dji/amt/state
			break
		fi
	done
	echo $r > $cpld_dir/result
}

# check a9s LCD path
check_camera_data()
{
#	test_encoding
}

# check flyctl USB
# can be ttyACM# or others

# factory test state control
switch_test_state()
{
	echo $1 > /data/dji/amt/state
}
