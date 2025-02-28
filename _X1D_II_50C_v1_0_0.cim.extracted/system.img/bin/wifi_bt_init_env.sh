#! /system/bin/sh

### BEGIN INFO
# Used to init wifi/bt related config
# Provider: caesar.li
### END INFO

# control socket directory
CONTROL_DIR=/data/misc/wifi
CFG_DIR=/cali/wifi
BT_CFG_DIR=/cali/bluetooth

if [ ! -d $CONTROL_DIR ]; then
    echo "directory $CONTROL_DIR does not exist"
    exit 1
fi

if [ ! -d $CFG_DIR ]; then
    echo "directory $CFG_DIR doen not exist, create it"
    mkdir $CFG_DIR
fi

if [ ! -d $BT_CFG_DIR ]; then
    echo "directory $BT_CFG_DIR doen not exist, create it"
    mkdir $BT_CFG_DIR
fi

# factory data
FACTORY_DIR=/factory_data/wifi

# Wi-Fi & BT MAC addr file
WIFI_MAC_FILE=$FACTORY_DIR/wlan_mac.bin
BT_MAC_FILE=$FACTORY_DIR/bt_nv.bin
CALI_DIR=/cali/firmware/wlan/
MOD_NAME=wlan

if [ `ps | busybox grep -c wpa_supplicant` -gt 0 ]; then
    echo "kill process wpa_supplicant"
    busybox pgrep wpa_supplicant | busybox xargs kill
fi

if [ `ps | busybox grep -c hostapd` -gt 0 ]; then
    echo "kill process hostapd"
    busybox pgrep hostapd | busybox xargs kill
fi

if [ `lsmod | busybox grep -c $MOD_NAME` -gt 0 ]; then
    rmmod $MOD_NAME
fi

if [ ! -d $CALI_DIR ]; then
    mkdir -p $CALI_DIR
fi

if [ `cat $CFG_DIR/hostapd.conf | busybox grep -c max_num_sta=255` -gt 0 ]; then
    rm $CFG_DIR/hostapd.conf
fi

# WIFI MAC address
if [ -f $WIFI_MAC_FILE ]; then
    echo "find factory wifi mac file"
    cp $WIFI_MAC_FILE $CALI_DIR/wlan_mac.bin
fi

# BT MAC address
if [ -f $BT_MAC_FILE ]; then
    echo "find factory bt mac file"
    cp $BT_MAC_FILE $CALI_DIR/bt_nv.bin
fi

sync

chown wifi:wifi $CONTROL_DIR
chmod 770 $CONTROL_DIR
chown wifi:wifi $CFG_DIR
chmod 770 $CFG_DIR

## turn on dhcp server
if [ ! -d $DHCP_DIR ]
then
    mkdir -p $DHCP_DIR
fi
echo > /data/misc/dhcp/udhcpd.leases
# busybox udhcpd /etc/udhcpd_wifi.conf

# Unlink the unused PF_UNIX socket
#rm /data/misc/wifi/sockets/*

exit 0
