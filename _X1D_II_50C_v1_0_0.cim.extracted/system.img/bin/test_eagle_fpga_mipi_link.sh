#########################################################################
# File Name: test_eagle_fpga_mipi_link.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Sat 26 May 2018 06:22:05 PM CST
#########################################################################
#!/bin/bash
prepare()
{
	#stop gui
	setprop ctl.stop gui
	if [ $? != 0 ]; then
		echo "stop gui fail"
		return 1
	fi

	#stop dji_camera2
	setprop ctl.stop dji_camera2
	if [ $? != 0 ]; then
		echo "stop dji_camera2 fail"
		return 2
	fi

	# Use e-shutter to avoid any lens dependencies
	odindb-send -s camera -p eshutter_current true
	if [ $? != 0 ]; then
		echo "Enable e-shutter failed"
		return 3
	fi
}

restore()
{
	setprop ctl.start dji_camera2
	if [ $? != 0 ]; then
		echo "start dji_camera2 fail"
		return 3
	fi
	setprop ctl.start gui
	if [ $? != 0 ]; then
		echo "start gui fail"
		return 4
	fi

	odindb-send -s camera -p eshutter_current false
	if [ $? != 0 ]; then
		echo "Enable e-shutter failed"
		return 3
	fi
}

eagle_fpga_mipi_test()
{
	prepare
	sleep 2
	val=$(dji_cht -f -d 3 -c x1dm2_cap -g sdcard)
	if [ $? != 0 ]; then
		echo "dji_cht failed"
		restore
		return 5
	fi
	restore
	echo "eagle fpga mipi test pass!"
	return 0
}

eagle_fpga_mipi_test
echo $?
