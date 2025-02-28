#!/system/bin/sh
#
# Insert Touch Panel Module
#
# Usage: insert_tp_mod.sh
#

ATMEL_TP_MOD=/system/lib/modules/atmel_mxt_ts.ko
HIMAX_TP_MOD=/system/lib/modules/himax_tp.ko

target_mod=$HIMAX_TP_MOD

# NOTE: has dependency on android property system
function fix_legacy_hardware()
{
	PROD_TYPE_X1DM2=12
	PROD_TYPE_CFV=14
	PROD_TYPE=`getprop dji.prod_type`
	HW_REV=`getprop dji.hw_rev`

	if [ $PROD_TYPE = $PROD_TYPE_X1DM2 ]; then
		if [ $HW_REV -lt 4 ]; then
			target_mod=$ATMEL_TP_MOD
		fi
	elif [ $PROD_TYPE = $PROD_TYPE_CFV ]; then
		target_mod=$ATMEL_TP_MOD
	fi
}

fix_legacy_hardware
echo Insert touch panel module: $target_mod
insmod $target_mod