#!/system/bin/sh

prod_type_CFV=14
prod_type=`getprop dji.prod_type`

function do_configure() {
        echo  "Start configuring touch controller"
	rmmod atmel_mxt_ts
	mxt-app -v 9 -d i2c-dev:5-004a -W -T 100 -n 60 0380000000000200000F0000007F0200000000000B000000DF0100000B0050002400000F000500021100001208DC3C04000100000005000000000000
	sleep 1
	mxt-app -v 9 -d i2c-dev:5-004a -W -T 7 -n 5 2006320000
	sleep 1
	mxt-app -v 9 -d i2c-dev:5-004a --backup
	sleep 1
	insmod /system/lib/modules/atmel_mxt_ts.ko
        echo  "Done configuring touch controller"
}

function do_check_product_type() {
	case $prod_type in	
		$prod_type_CFV)
			do_configure
		;;
		*)
			echo "Product type not supported: $prod_type"
		;;
	esac
}

do_check_product_type
