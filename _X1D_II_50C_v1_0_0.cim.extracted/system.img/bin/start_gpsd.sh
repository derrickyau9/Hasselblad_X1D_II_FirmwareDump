#!/system/bin/sh
GPS_EN_GPIO_NUM=19
TTY_UART=/dev/ttyS3

function legacy_hardware_fix()
{
	PROD_TYPE_X1DM2=12
	PROD_TYPE=`getprop dji.prod_type`
	HW_REV=`getprop dji.hw_rev`

	if [ $PROD_TYPE = $PROD_TYPE_X1DM2 ]; then
		if [ $HW_REV = 1 ]; then
			TTY_UART=/dev/ttyS2
		fi
	fi
}

legacy_hardware_fix
/system/bin/gpsd -u $TTY_UART:9600 -g $GPS_EN_GPIO_NUM
