#!/system/bin/sh
#
# Usage: upgrade.sh (path)
#
# Usage:
# upgrade.sh   - upgrade using default firmware path,  /storage/sdcard0/upgrade/
# upgrade.sh path   - upgrade using specific firmware path

#sd card 0 is mounted to /storage/sdcard0 in 1704
fw_path=/storage/sdcard0/upgrade/

#suc, eagle must be upgraded in the end
upgrade_list=("cpld" "fpga" "spc" "suc" "eagle")

#upgrade_eagle_ota
function upgrade_eagle()
{
	if [ -f /cache/update_recovery_start ]; then
		echo "Recovery.img is updating now."
		exit 0
	fi

	if [ -f /cache/ota.zip ]; then
		busybox unzip /cache/ota.zip normal.img -d /tmp
		if [ -f /tmp/normal.img ]; then
			dji_fw_verify -n normal /tmp/normal.img
			if [ $? != 0 ]; then
				echo " "
				echo "**********************************************************************************************"
				echo "dji_fw_verify normal.img failure, please make sure that you've used a right user/prod ota.zip."
				echo "**********************************************************************************************"
				echo " "
				exit 1
			fi
		else
			echo "**************************************"
			echo "unzip normal.img from ota.zip failure."
			echo "**************************************"
			exit 1
		fi
		mkdir -p /cache/recovery
		echo "--update_package=/cache/ota.zip" > /cache/recovery/command
		sync
		unrd -s boot.mode recovery
		echo "reboot for eagle ota upgrade"
		reboot recovery
	else
		echo "********************************************"
		echo "Please push ota.zip to /cache/ota.zip first."
		echo "********************************************"
	fi
}

#upgrade_device
function upgrade_device()
{
	echo "fw_path: $fw_path; module name is: $1"
	device_fw=`busybox find $fw_path -name "$1-*.bin"`
	if [ x"$device_fw" = x ]; then
		echo "module $1 fw should be named as $fw_path/$1-version.bin"
		return 1
	else
		fw_name=`echo ${device_fw##*/}`
		echo "**********************************************"
		echo "found device fw is: $device_fw "
		echo "fw name is $fw_name"
		echo "**********************************************"
	fi
	if [ $1 = eagle ];then
		if [ -f $device_fw ]; then
			busybox cp $device_fw /cache/ota.zip
		else
			echo "input eagle ota zip file not exist"
			exit 1
		fi
		#upgrade eagle ota
		upgrade_eagle
	else
		upgrade_$1.sh $device_fw
	fi
	return $?
}

#sanity check
if [ $# -ge 1 ]; then
	echo "use given fw path: $1"
	fw_path=$1
else
	echo "use default fw path:$fw_path"
fi

if [ ! -d $fw_path ]; then
	echo "$fw_path not exist, please input a valid fw path"
	exit 1
fi

#upgrade device
for module_name in ${upgrade_list[*]}
do
	echo "*******************************"
	echo "upgrading: $module_name"
	echo "*******************************"
	upgrade_device $module_name
	if [ $? -gt 0 ]; then
		echo "$module_name upgrade fail"
		exit 1
	fi
done

