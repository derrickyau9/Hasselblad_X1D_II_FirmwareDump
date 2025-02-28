# include the script lib
. lib_test.sh
. lib_test_cases.sh

fpga_ddr_test_time=0
eagle_test_time=3600
#aging work flow
aging_npi_ctrl=18
# test for 1 hours (3600s)
timeout=3600
amt=/data/dji/amt
dir=$amt/aging_test
aging_fail_reason="init unknown"
headtitle=unknown
no_sdcard=0

rm -rf $dir
mkdir -p $dir

sd_dir1=/storage/sdcard0
sd_dir2=/storage/sdcard1
sd_dir=unknown

# err flag
check_link_err=0
ddr_aging_err=0
flag_err=0

# camera store flag in camera partition or sdcard
#stored_camera=1

aging_start=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
aging_elapsed()
{
	local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
	local diff=$(($now-$aging_start))
	echo $diff
}

#led
led_red()
{
    odindb-send -s suc -m set_led E_LedState_On E_LedColor_Red
	if [ $? != 0 ]; then
		echo "display red led fail"
		return 1
	fi
    return 0
}

led_green()
{
    odindb-send -s suc -m set_led E_LedState_On E_LedColor_Green
	if [ $? != 0 ]; then
		echo "display red led fail"
		return 1
	fi
    return 0
}

led_blink()
{
    local i=0
    for i in $(seq 10)
    do
        led_green
        sleep 0.5
		led_red
		sleep 0.5
    done
    led_green
    return 0
}

# aging_test_timeout configure
config_timeout()
{
	if [ -s $amt/aging_test_timeout ]; then
		time=($(cat  $amt/aging_test_timeout))
		if [ $time = 0 ];then
			echo "timeout value should not as 0"
		else
			timeout=$time
		fi
	fi
	echo "aging_test timeout: $timeout"
}

copy_result()
{
    echo try2 copy result for: $1
    link_str="\"aging_test_check_link\""
    bsp_cpu_str="\"bsp_cpu_aging_test\""
    bsp_ddr_str="\"bsp_ddr_aging_test\""
    bsp_emmc_sd_str="\"bsp_emmc_sd_aging_test\""
    camera_str="\"camera_aging_test\""

    if [ $1 = $link_str ]; then
        echo "to get result of link test"
#        copy_gimbal_result
    else
        echo "no need to get result of $1 "
    fi

    # always update the aging_test log
    echo "copy result to" $sd_dir/aging_test
    mkdir -p $sd_dir/aging_test/blackbox
    busybox cp $dir/ $sd_dir/aging_test -rf
    busybox cp /blackbox/ $sd_dir/aging_test/blackbox -rf
    echo "copy finished"
}

get_link_fail_reason()
{
    if [ $1 = 1 ]; then
        aging_fail_reason="link2gimbal"
    elif [ $1 = 2 ]; then
        aging_fail_reason="gimbal_aging"
    elif [ $1 = 3 ]; then
        aging_fail_reason="link2flyctl"
    elif [ $1 = 4 ]; then
        aging_fail_reason="link2esc0"
    elif [ $1 = 5 ]; then
        aging_fail_reason="link2esc1"
    elif [ $1 = 6 ]; then
        aging_fail_reason="link2esc2"
    elif [ $1 = 7 ]; then
        aging_fail_reason="link2esc3"
    elif [ $1 = 7 ]; then
        aging_fail_reason="link2battery"
    else
        aging_fail_reason="unknown"
    fi
}

get_bsp_fail_reason()
{
    if [ $1 = 1 ]; then
        aging_fail_reason="fail: bsp_cpu"
    elif [ $1 = 2 ]; then
        aging_fail_reason="fail: bsp_ddr"
    elif [ $1 = 3 ]; then
        aging_fail_reason="fail: bsp_emmc_dd"
    elif [ $1 = 4 ]; then
        aging_fail_reason="fail: bsp_emmc_write"
    elif [ $1 = 5 ]; then
        aging_fail_reason="fail: bsp_sd_dd"
    elif [ $1 = 6 ]; then
        aging_fail_reason="fail: bsp_sd_write"
    elif [ $1 = 7 ]; then
        aging_fail_reason="fail: bsp_sd_not_found"
    else
        aging_fail_reason="unknown"
    fi
}

get_fpga_fail_reason()
{
    if [ $1 = 1 ]; then
        aging_fail_reason="fail: start test fpga ddr error"
    elif [ $1 = 2 ]; then
        aging_fail_reason="fail: check fpga ddr test failed:error info is not:time_ms = 0!"
    elif [ $1 = 3 ]; then
        aging_fail_reason="fail: check fpga ddr test failed:timeout!"
    elif [ $1 = 5 ]; then
        aging_fail_reason="fail: start test fpga emmc error!"
    elif [ $1 = 6 ]; then
        aging_fail_reason="fail: stop test fpga emmc error!"
    else
        aging_fail_reason="unknown"
    fi
}

try2_get_fail_reason()
{
    echo try2 get fail reason. $1 $2
    headtitle=$1
    link_str="\"aging_test_check_link\""
    bsp_cpu_str="\"bsp_cpu_aging_test\""
    bsp_ddr_str="\"bsp_ddr_aging_test\""
    bsp_emmc_sd_str="\"bsp_emmc_sd_aging_test\""
    fpga_ddr_str="\"fpga_ddr_aging_test\""
    fpga_emmc_str="\"fpga_emmc_aging_test\""
    camera_str="\"camera_aging_test\""

    if [ $1 = $link_str ]; then
        echo "to get fail reason of link test"
        get_link_fail_reason $2
#        headtitle="aging_link"
    elif [ $1 = $bsp_cpu_str ]||[ $1 = $bsp_ddr_str ]||[ $1 = $bsp_emmc_sd_str ]; then
        echo "to get fail reason of bsp or codec"
        get_bsp_fail_reason $2
#        headtitle="bsp"
    elif [ $1 = $fpga_emmc_str ]||[ $1 = $fpga_ddr_str ]; then
        echo "to get fail reason of fpga ddr or emmc"
        get_fpga_fail_reason $2
#        headtitle="fpga"
    elif [ $1 = $camera_str ]; then
        echo "to get fail reason of camera capture"
        get_camera_fail_reason $2
#        headtitle="camera_capture"
    else
        echo "fail to get fail reason"
        aging_fail_reason="unknown"
    fi
}

try2_delete_data()
{
    echo try2 delete. $1 $2
    bsp_emmc_sd_str="\"bsp_emmc_sd_aging_test\""

#    if [ $1 = $bsp_emmc_sd_str ]; then
    if [ $1 != "unknown" ]; then
        echo "to delete bsp data"
        rm -rf $amt/sample.data
        if [ -f $dir/eMMC.data ]; then
            rm -f $dir/eMMC.data
        fi
        if [ -f $sd_dir/eMMC.data ]; then
            rm -f $sd_dir/eMMC.data
        fi
        if [ -f $sd_dir/sd.data ]; then
            rm -f $sd_dir/sd.data
        fi
#    elif [[ $1 == *$codec_str* ]]; then
#        echo "to delete codec data"
#        rm -rf /data/dji/amt/codec/in/b3.h264
#        rm -rf /data/dji/amt/codec/in/1.jpg
#        rm -rf /data/dji/amt/codec/out/b3
#        rm -rf /data/dji/amt/codec/out/j
    else
        echo "to delete unknow data"
    fi
}

error_action_log()
{
	collect_useful_log.sh
	cat /blackbox/system/collect_useful_information.log
}

# error action
error_action()
{
	echo error_action: \"$2\", error=$1
#	if [ $1 = 0 ]; then
#		echo $2 PASSED >> $dir/result
#		echo $2 aging test passed ---------------------
#	fi
	if [ -f $dir/finished ]; then
		return $1
	else
		# mark as finished
		if [ $1 -eq 0 ]; then
			touch $dir/finished
			sync
		fi
	fi

	# stop blinking, LEDs off
	sync
	sleep 2		# ensure no conflict with led_blink

	if [ $1 -ne 0 ]; then
		#save test result to file

		#$2 is test cmd, $1 is return value
		try2_get_fail_reason $2 $1
		echo aging_test failed, error at case: \"$2\"
		echo "$headtitle: FAIL,reason: $aging_fail_reason, at $(aging_elapsed) seconds, \
			error code:$1" >> $dir/result

		sync
		echo factory > $amt/state
		error_action_log
		sync
		led_blink
		copy_result $2
		sync
	else
		# already get error
		if [ -f $dir/result ]; then
			echo result has been exsisted
			error_action_log
		else
			echo PASSED > $dir/result
			echo aging test passed ---------------------
			led_green
			echo normal > $amt/state
			try2_delete_data $2 $1
		fi
		copy_result $2
		sync
		exit $1
	fi
}

# error action with block
error_action_block()
{
	echo error_action_boocl: \"$2\", error=$1
#	if [ $1 -ne 0 ]; then
#		echo $2 PASSED >> $dir/result
#		echo $2 aging test passed ---------------------
#	fi
#	if [ -f $dir/finished ]; then
#		return $1
#	else
		# mark as finished
#		if [ $1 -eq 0 ]; then
#			touch $dir/finished
#			sync
#		fi
#	fi

	# stop blinking, LEDs off
	sync
	sleep 2		# ensure no conflict with led_blink

	if [ $1 -ne 0 ]; then
		#save test result to file

		#$2 is test cmd, $1 is return value
		try2_get_fail_reason $2 $1
		echo aging_test failed, error at case: \"$2\"
		echo "$headtitle: FAIL,reason: $aging_fail_reason, at $(aging_elapsed) seconds, \
			error code:$1" >> $dir/result

		sync
		echo factory > $amt/state
		error_action_log
		sync
		led_blink
		copy_result $2
		sync
	else
		# already get error
		if [ -f $dir/result ]; then
			echo result has been exsisted
			error_action_log
		else
			led_green
#			echo normal > $amt/state
#			try2_delete_data $2 $1
		fi
		copy_result $2
		sync
#		exit $1
		return $1
	fi
}

bsp_cpu_aging_test()
{
    #CPU compression test
    echo "BSP CPU Aging Test Start"
    dd if=/dev/urandom of=/tmp/testimage bs=524288 count=10
    local r=$?
    if [ $r != 0 ]; then
        echo "CPU aging fail"
        return 1
    fi
    gzip -9 -c /tmp/testimage | gzip -d -c > /dev/null
    r=$?
    if [ $r != 0 ]; then
        echo "CPU aging fail in gzip"
        return 1
    fi
    echo "BSP CPU Aging test End"
    return 0
}

bsp_ddr_codec_aging_test()
{
    ddr_str="\"bsp_ddr_aging_test\""
#    codec_str="codec_aging_test"

    echo "enter ddr and codec serialize test"
    local link_ret=0
    # communication test
    if [ $ddr_aging_err -eq 0 ];then
        bsp_ddr_aging_test
        link_ret=$?
        if [ $link_ret != 0 ]; then
            error_action $link_ret $ddr_str
            ddr_aging_err=1
        fi
        sleep 1
    fi
    echo "seialize ddr and codec finished"
    return 0
}

bsp_ddr_aging_test()
{
    echo "BSP DDR Aging Test Start"
    # memory test
    test_mem -s 0x2000000 -l 8
    local r=$?
    if [ $r != 0 ]; then
        echo "DDR aging fail"
        return 2
    fi
    echo "BSP DDR Aging test End"
    return 0
}

bsp_emmc_sd_aging_test()
{
    echo "BSP eMMC Aging Test Start"
    local std_md5=1386d2e6f153f79a954e65b0f60326bf

    if [ -f $dir/eMMC.data ]; then
        rm -f $dir/eMMC.data
    fi

    if [ -f $sd_dir/sd.data ]; then
        rm -f $sd_dir/sd.data
    fi
    SDCARD_DIR=`df | busybox grep "/mnt/media_rw" | busybox awk '{print $1}'`
    SDCARD=`echo ${SDCARD_DIR:0:13}`
    echo $SDCARD
    if [ "$SDCARD" != "/mnt/media_rw" ]; then
        return 7
    fi

    #eMMC
    dd if=$amt/sample.data of=$dir/eMMC.data bs=1024 count=1024
    local r=$?
    if [ $r != 0 ]; then
        echo "eMMC aging fail, fail to write eMMC"
    fi
    eMMC_MD5=`md5sum $dir/eMMC.data | busybox awk '{print $1}'`
    if [ $eMMC_MD5 != $std_md5 ]; then
        echo "eMMC aging fail MD5 is $eMMC_MD5"
        return 4
    fi

    #SD
    dd if=$amt/sample.data of=$sd_dir/sd.data bs=1024 count=1024
    r=$?
    if [ $r != 0 ]; then
        echo "SD aging fail, fail to write SD"
    fi
    SD_MD5=`md5sum $sd_dir/sd.data | busybox awk '{print $1}'`
    if [ $SD_MD5 != $std_md5 ]; then
        echo "SD aging fail MD5 is $SD_MD5"
        return 6
    fi

    echo "BSP eMMC Aging test End"
	sleep 10

    return 0
}

bsp_aging_test()
{
    local std_md5=1386d2e6f153f79a954e65b0f60326bf

    if [ -f $dir/eMMC.data ]; then
        rm -f $dir/eMMC.data
    fi

    if [ -f $sd_dir/sd.data ]; then
        rm -f $sd_dir/sd.data
    fi

    #CPU compression test
    dd if=/dev/urandom of=/tmp/testimage bs=524288 count=10
    gzip -9 -c /tmp/testimage | gzip -d -c > /dev/null
    r=$?
    if [ $r != 0 ]; then
        echo "CPU aging fail MD5 is $eMMC_MD5"
        return 1
    fi

    # memory test
    test_mem -s 0x200000 -l 1
    local r=$?
    if [ $r != 0 ]; then
        echo "DDR aging fail MD5 is $eMMC_MD5"
        return 2
    fi

    #eMMC
    dd if=$amt/sample.data of=$dir/eMMC.data bs=1024 count=1024*50
    r=$?
    if [ $r != 0 ]; then
        echo "eMMC aging fail, fail to write eMMC"
        return 3
    fi
    eMMC_MD5=`md5sum $dir/eMMC.data | busybox awk '{print $1}'`
    if [ $eMMC_MD5 != $std_md5 ]; then
        echo "eMMC aging fail MD5 is $eMMC_MD5"
        return 4
    fi

    #SD
    dd if=$amt/sample.data of=$sd_dir/sd.data bs=1024 count=1024*50
    r=$?
    if [ $r != 0 ]; then
        echo "SD aging fail, fail to write SD"
        return 5
    fi
    SD_MD5=`md5sum $sd_dir/sd.data | busybox awk '{print $1}'`
    if [ $SD_MD5 != $std_md5 ]; then
        echo "SD aging fail MD5 is $SD_MD5"
        return 6
    fi
    return 0

}

fpga_ddr_aging_test()
{
	err_info="Failed to send message"
	err_info="farmus is not available"
	check_info="time_ms = 0"
	local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
	local ddr_test_start=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
	local diff=0
	local ddr_test_timeout=120
	#test ddr
    odindb-send -s farmus -m func_test E_FuncTestModule_Ddr E_FuncTestAction_Start 1 0 0 > /dev/null 2>&1
	local ret=$?
	if [ $ret != 0 ]; then
		echo "start test ddr error"
		return 1
	fi

    sleep 60
    start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
	while true
	do
		test=$(odindb-send -s farmus -m func_test E_FuncTestModule_Ddr E_FuncTestAction_Check 1 0 0)
		ret=$?
		if [ $ret = 0 ]; then
			echo $test | grep "$check_info"
			if [ $? = 0 ]; then
				echo "farm ddr test pass"
                sleep 5
				return 0
			else
				echo "check fpga ddr test failed:$test not is:$check_info!"
                sleep 5
				return 2
			fi
		else
			sleep 5
			now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
			diff=$(($now-$ddr_test_start))
			if [ $diff -ge $ddr_test_timeout ]; then
				echo "check fpga ddr test failed:timeout!"
                sleep 5
				return 3
			fi
			continue
		fi
	done
}

fpga_emmc_aging_test()
{
	#test emmc
    odindb-send -s farmus -m func_test E_FuncTestModule_Emmc E_FuncTestAction_Start 1 0 0 > /dev/null 2>&1
	local ret=$?
	if [ $ret != 0 ]; then
		echo "start test fpga emmc error"
		return 5
	fi

	while true
	do
		odindb-send -s farmus -m func_test E_FuncTestModule_Emmc E_FuncTestAction_Check 1 0 0 > /dev/null 2>&1
		ret=$?
		if [ $ret = 0 ]; then
			#stop emmc test,which is needed
			odindb-send -s farmus -m func_test E_FuncTestModule_Emmc E_FuncTestAction_Stop 1 0 0 > /dev/null 2>&1
			ret=$?
			if [ $ret != 0 ]; then
				echo "stop test fpga emmc error"
				return 6
			fi
			break
		fi
		sleep 2
	done
	sleep 10
	echo "farm emmc test pass"
	return 0
}

camera_close_gui_server()
{
    #stop compositor
    setprop ctl.stop compositor
    if [ $? != 0 ]; then
        echo "capture fail:stop compositor fail"
        return 1
    fi

    #stop gui
    setprop ctl.stop gui
    if [ $? != 0 ]; then
        echo "capture fail:stop gui fail"
        return 2
    fi

    #stop dji_camera2
    setprop ctl.stop dji_camera2
    if [ $? != 0 ]; then
        echo "capture fail:stop dji_camera2 fail"
        return 3
    fi
}

camera_start_gui_server()
{
	setprop ctl.start dji_camera2
	if [ $? != 0 ]; then
		echo "capture fail:start dji_camera2 fail"
		return 4
	fi
	setprop ctl.start gui
	if [ $? != 0 ]; then
		echo "capture fail:start gui fail"
		return 5
	fi
	setprop ctl.start compositor
	if [ $? != 0 ]; then
		echo "capture fail:start compositor fail"
		return 6
	fi
}

check_sdcard()
{
    #disconnect usb
    test_hal_storage -c "0 volume detach_pc"
	ls $sd_dir1
	local ret1=$?
	ls $sd_dir2
	local ret2=$?
	if [ $ret1 = 0 ] || [ $ret2 = 0 ]; then
		echo "have sdcard in camera"
		return 0
	fi
	return 1
}

which_sdcard()
{
    test_hal_storage -c "0 volume detach_pc"
	ls $sd_dir1
	local ret1=$?
	ls $sd_dir2
	local ret2=$?
	if [ $ret1 -eq 0 -a $ret2 -eq 0 ]; then
		echo "current sd is sdcard0 and sdcard1"
		return 0
	fi
	if [ $ret1 -eq 0 ]; then
		echo "current sd is sdcard0"
		return 1
	fi
	if [ $ret2 -eq 0 ]; then
		echo "current sd is sdcard1"
		return 2
	fi
	return 3
}

camera_capture_aging_test()
{
	storage_keyword="save one dng done:"
	local storage
	local storage_tmp
	local storage_file
	sleep 10
	check_sdcard
	if [ $? = 0 ]; then
		camera_close_gui_server
		if [ -f /blackbox/tmp_capture.log ]; then
			rm -f /blackbox/tmp_capture.log
		fi
		sleep 10
		dji_cht -c x1dm2_still_r_4x3 -d 3 -f -g sdcard > /blackbox/tmp_capture.log
		if [ $? != 0 ]; then
			echo "capture fail:dji_cht capture failed!"
			camera_start_gui_server
			return 7
		fi
		#save log
		cat  /blackbox/tmp_capture.log

		cat /blackbox/tmp_capture.log | grep "PASSED" > /dev/null
		if [ $? != 0 ]; then
			echo "capture fail:dji_cht failed:capture failed!"
			camera_start_gui_server
			return 8
		fi
		camera_start_gui_server
		storage=$(cat /blackbox/tmp_capture.log | grep "$storage_keyword")
		if [ $? != 0 ]; then
			echo "capture fail:tmp:can not find keyword of storage file"
			return 9
		fi
		storage_tmp=$(echo $storage | busybox awk -F: '{print $4}')
		if [ $? != 0 ]; then
			echo "capture fail:can not find keyword of storage file"
			return 10
		fi
		rm -f /blackbox/tmp_capture.log
		storage_file=$(echo $storage_tmp | busybox awk -F, '{print $1}')
		if [ $? != 0 ]; then
			echo "capture fail:can not find storage file"
			return 11
		fi
		ls $storage_file
		if [ $? != 0 ]; then
			echo "capture file fail:no capture file in sdcard"
			return 12
		else
			rm -f $storage_file
		fi

		echo "capture test pass!"
		sleep 10
		return 0
	else
		echo "capture fail :no sdcard in camera"
		return 13
	fi
}

get_camera_fail_reason()
{
    if [ $1 = 1 ]; then
        aging_fail_reason="capture fail:stop compositor fail"
    elif [ $1 = 2 ]; then
        aging_fail_reason="capture fail:stop gui fail"
    elif [ $1 = 3 ]; then
        aging_fail_reason="capture fail:stop dji_camera2 fail"
    elif [ $1 = 4 ]; then
        aging_fail_reason="capture fail:start dji_camera2 fail"
    elif [ $1 = 5 ]; then
        aging_fail_reason="capture fail:start gui fail"
    elif [ $1 = 6 ]; then
        aging_fail_reason="capture fail:start compositor fail"
    elif [ $1 = 7 ]; then
        aging_fail_reason="capture fail:dji_cht capture failed!"
    elif [ $1 = 8 ]; then
        aging_fail_reason="capture fail:dji_cht failed:capture failed!"
    elif [ $1 = 9 ]; then
        aging_fail_reason="capture fail:tmp:can not find keyword of storage file!"
    elif [ $1 = 10 ]; then
        aging_fail_reason="capture fail:can not find keyword of storage file!"
    elif [ $1 = 11 ]; then
        aging_fail_reason="capture fail:can not find storage file!"
    elif [ $1 = 12 ]; then
        aging_fail_reason="capture file fail:no capture file in sdcard!"
    elif [ $1 = 13 ]; then
        aging_fail_reason="capture fail:no sdcard in camera!"

    elif [ $1 = 14 ]; then
        aging_fail_reason="record fail:stop compositor fail"
    elif [ $1 = 15 ]; then
        aging_fail_reason="record fail:stop gui fail"
    elif [ $1 = 16 ]; then
        aging_fail_reason="record fail:stop camera_service fail"
    elif [ $1 = 17 ]; then
        aging_fail_reason="record fail:start camera_service fail"
    elif [ $1 = 18 ]; then
        aging_fail_reason="record fail:start gui fail"
    elif [ $1 = 19 ]; then
        aging_fail_reason="record fail:start compositor fail"
    elif [ $1 = 20 ]; then
        aging_fail_reason="record fail:dji_cht recording failed!"
    elif [ $1 = 21 ]; then
        aging_fail_reason="record fail:dji_cht failed:recording failed!"
    elif [ $1 = 22 ]; then
        aging_fail_reason="record fail:can not find keyword of storage file"
    elif [ $1 = 23 ]; then
        aging_fail_reason="record fail:can not find storage file!"
    elif [ $1 = 24 ]; then
        aging_fail_reason="record fail: no recording file in sdcard!"
    elif [ $1 = 25 ]; then
        aging_fail_reason="record fail:no sdcard in camera!"
    else
        aging_fail_reason="unknown"
    fi
}

recording_close_gui_server()
{
    #stop compositor
    setprop ctl.stop compositor
    if [ $? != 0 ]; then
        echo "record fail:stop compositor fail"
        return 14
    fi

    #stop gui
    setprop ctl.stop gui
    if [ $? != 0 ]; then
        echo "record fail:stop gui fail"
        return 15
    fi

    #stop camera_service
	setprop dji.camera_service 0
    if [ $? != 0 ]; then
        echo "record fail:stop camera_service fail"
        return 16
    fi
}

recording_start_gui_server()
{
	setprop dji.camera_service 1
	if [ $? != 0 ]; then
		echo "record fail:start camera_service fail"
		return 17
	fi
	setprop ctl.start gui
	if [ $? != 0 ]; then
		echo "record fail:start gui fail"
		return 18
	fi
	setprop ctl.start compositor
	if [ $? != 0 ]; then
		echo "record fail:start compositor fail"
		return 19
	fi
}

camera_record_aging_test()
{
	storage_keyword="record file:"
	local storage
	local storage_file
	sleep 10
	check_sdcard
	if [ $? = 0 ]; then
		recording_close_gui_server
		if [ -f /blackbox/tmp_recording.log ]; then
			rm -f /blackbox/tmp_recording.log
		fi
		sleep 5
		dji_cht -c x1dm2_recording_h264_audio -e ec1704 -f > /blackbox/tmp_recording.log
		if [ $? != 0 ]; then
			echo "record fail:dji_cht recording failed!"
			recording_start_gui_server
			return 20
		fi
		#save log
		cat  /blackbox/tmp_recording.log

		cat /blackbox/tmp_recording.log | grep "PASSED" > /dev/null
		if [ $? != 0 ]; then
			echo "record fail:dji_cht failed:recording failed!"
			recording_start_gui_server
			return 21
		fi
		recording_start_gui_server
		storage=$(cat /blackbox/tmp_recording.log | grep "$storage_keyword")
		if [ $? != 0 ]; then
			echo "record fail:can not find keyword of storage file"
			return 22
		fi
		rm -f /blackbox/tmp_recording.log
		storage_file=$(echo $storage | busybox awk -F: '{print $4}')
		if [ $? != 0 ]; then
			echo "record fail:can not find storage file"
			return 23
		fi
		ls $storage_file
		if [ $? != 0 ]; then
			echo "record fail: no recording file in sdcard"
			return 24
		else
			rm -f $storage_file
		fi

		echo "recording test pass!"
		return 0
	else
		echo "record fail:no sdcard in camera"
		return 25
	fi
}

camera_aging_test()
{
	local ret=0

	camera_capture_aging_test
	ret=$?
	if [ ret != 0 ]; then
		return $ret
	fi
	sleep 10
	camera_record_aging_test
	ret=$?
	return $ret
}

# run until timeout, if get error, take action
# same format as run_timeout
run_timeout_error_action()
{
	echo run_timeout_error_stop: $*
	while [ $(aging_elapsed) -le $timeout ]
	do
		eval $*
		local r=$?
		if [ $r != 0 ]; then
			echo chip $chip_id run \"$*\" get error $r
			error_action $r \"$*\"
			return $r
		fi
	done
	echo "timeout bsp_ddr_test"
	error_action $? \"$*\"
}

# run until timeout, if get error, take action
# same format as run_timeout
run_timeout_error_action_block()
{
	echo run_timeout_error_stop: $*
	while [ $(aging_elapsed) -le $timeout ]
	do
		eval $*
		local r=$?
		if [ $r != 0 ]; then
			echo chip $chip_id run \"$*\" get error $r
			error_action_block $r \"$*\"
			return $r
		fi
	done
	error_action_block $? \"$*\"
}

# start several applications, which run until timeout or get error then take action
#   start_timeout_error_action <instances> "expression"
# example: start_timeout_error_action 4 "echo 111 && sleep 5 && echo 222"
start_timeout_error_action_block()
{
	echo start_timeout_error_action: $*
	local n=0
	while [ $n -lt $1 ]; do
		let n+=1
		run_timeout_error_action_block $2
	done
}

# start several applications, which run until timeout or get error then take action
#   start_timeout_error_action <instances> "expression"
# example: start_timeout_error_action 4 "echo 111 && sleep 5 && echo 222"
start_timeout_error_action()
{
	echo start_timeout_error_action: $*
	local n=0
	while [ $n -lt $1 ]; do
		let n+=1
		run_timeout_error_action $2 &
	done
}

aging_test()
{
	if [ $# != 1 ]; then
		echo "The number of parameters is error:$#,should be 1!"
	fi
    #####################################################################################################
    #              Eagle Platform aging test
    #####################################################################################################

    echo "running aging_test simple version!!"
    ##aging test start, send v1 0xf4 command

	aging_start=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
	timeout=$1
	# fpga emmc aging test
	start_timeout_error_action_block 1 "fpga_emmc_aging_test"
	# TODO: add some suitiable cpu test according to cpu load
	start_timeout_error_action_block 1 "bsp_cpu_aging_test"

	# bsp ddr aging test
	start_timeout_error_action_block 4 "bsp_ddr_codec_aging_test"

	# bsp emmc sd aging test
	start_timeout_error_action_block 1 "bsp_emmc_sd_aging_test"

	# camera aging test
	start_timeout_error_action_block 1 "camera_aging_test"
	sleep 5

	# Copy results to SD card
	error_action 0 "All tests finished!"

    #####################################################################################################
}

main_aging_test()
{
#	if [ $# != 2 ]; then
#		echo "The number of parameters is error:$#,should be 2!"
#		echo "aging_test.sh [fpga ddr test time] [system test time]"
#		echo "all time should be 1h"
#		exit 1
#	fi

	#close auto suspend and auto power down
	odindb-send -s config -p gui_idle_timeout 0
	odindb-send -s config -p sys_standby_idle_timeout 0

	sleep 1
	led_red
	sleep 1
	led_green
	sleep 1

	led_blink

	rm -f /data/dji/aging_test_flag

	#As sdcard need test, need to detach sdcard from PC
	usb_conn=`cat /sys/class/android_usb/android0/state`
	if [ $usb_conn = "CONFIGURED" ];then
		echo "detach sd from PC"
		test_hal_storage -c "0 volume detach_pc"
	fi

	sleep 1
	which_sdcard
	local ret=$?
	if [ $ret -eq 1 ]; then
		sd_dir=$sd_dir1
		test_hal_storage -c "0 volume format public0 exfat"
	elif [ $ret -eq 2 ]; then
		sd_dir=$sd_dir2
		test_hal_storage -c "0 volume format public1 exfat"
	elif [ $ret -eq 0 ];then
		sd_dir=$sd_dir1
		test_hal_storage -c "0 volume format public0 exfat"
	else
		echo "no sdcard!"
		return 1
	fi

	sleep 2
	#echo "return val is $ret,sd_dir:$sd_dir"
	if [ -e $sd_dir ];then
		if [ -e $sd_dir/aging_test ];then
			# remove last aging test result
			rm -rf $sd_dir/aging_test
		fi
		mkdir $sd_dir/aging_test
	#echo "make $sd_dir"
	else
		echo "error: No sdcard to store aging result!!"
		no_sdcard=1
	fi

	busybox cp -f /data/dji/sample.data $amt

	fpga_ddr_test_time=${1:-600}
	eagle_test_time=${2:-3000}
	if [ $fpga_ddr_test_time -ne 0 ]; then
		# fpga ddr aging test
		timeout=$fpga_ddr_test_time
		start_timeout_error_action_block 1 "fpga_ddr_aging_test"  >> $amt/aging_test/log.txt
		sleep 10
	fi

	aging_test $eagle_test_time >> $amt/aging_test/log.txt
}

main_aging_test $1 $2
