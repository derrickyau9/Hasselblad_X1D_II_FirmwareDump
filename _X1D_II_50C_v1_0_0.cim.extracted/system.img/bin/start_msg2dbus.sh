#!/system/bin/sh

SUC_UART=/dev/ttyS1
FPGA_UART=/dev/ttyS2

PROD_TYPE_X1DM2=12
PROD_TYPE_CFV=14

PROD_TYPE=`getprop dji.prod_type`
HW_REV=`getprop dji.hw_rev`
if [ $PROD_TYPE = $PROD_TYPE_X1DM2 ]; then
	if [ $HW_REV = 1 ]; then
		FPGA_UART=/dev/ttyS3
	fi
elif [ $PROD_TYPE = $PROD_TYPE_CFV ]; then
	if [ $HW_REV = 0 ]; then
		FPGA_UART=/dev/ttyS3
	fi
fi

/system/bin/msg2dbus -u $FPGA_UART:921600:1,2 -u $SUC_UART:460800:3 -b /dev/usb-ffs/bulk/
