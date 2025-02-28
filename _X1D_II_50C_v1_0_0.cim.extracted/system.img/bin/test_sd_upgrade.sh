#!/system/bin/sh

echo "Searching for upgrades"
ls /storage/sd* 2> /dev/null > /dev/null || { echo "No SD card present, cannot continue"; exit 1; }

odindb-send -s upgrade -m developer_override_downgrade_check 1
odindb-send -s upgrade -m upgrade_check

cim_uuid_latest=$(odindb-send -s upgrade -p upgrades_available | busybox awk -F'[=,/]' '/uuid.*storage/{print $(NF-1)}' | sort | tail -n1)
cim_uuid=sd:$(ls /storage/*/$cim_uuid_latest) || { echo "No upgrades found"; exit 1; }

echo "Staring upgrade with CIM $cim_uuid"
odindb-send -s upgrade -m upgrade $cim_uuid
