#! /system/bin/sh

### BEGIN INFO
# Used to autotest Wi-Fi
# QCA6174A-3 device.
# Provider: caesar.li
### END INFO

echo "Enter wifi_bt_test_cmd.sh ..."

WIFI_DIR=/system/lib/modules
CTRL_DIR=/data/misc/wifi
SDIO_DIR=/sys/bus/sdio/devices

WIFI_NAM=wlan

# config file
AP_CONF=/cali/wifi/hostapd.conf
STA_CONF=/cali/wifi/wpa_supplicant.conf
DHCP_CONF=/etc/udhcpd_wifi.conf

# executable file
QCMBR_CMD=/system/bin/qcmbr
BTDIAG_CMD=/system/bin/Btdiag
WPA_CLI_CMD=/system/bin/wpa_cli
HOSTAPD_CMD=/system/bin/hostapd
WPA_SUPP_CMD=/system/bin/wpa_supplicant
HCIATTACH_CMD=/system/bin/hciattach
HCICONFIG_CMD=/system/xbin/hciconfig

### BEGIN DEFINITION
# 0 -> Succ
# 1 -> FAILURE General
# 2 -> No such device or address
# 3 -> Invalid argument or cmd
# 4 -> File already exist
# 5 -> Device or resource busy
### END DEFINITION

cmd=$1
cmd_obj=$2
param_0=$3
param_1=$4

if [ "$cmd" = "-h" -o "$cmd" = "--help" -o -z "$cmd" ]; then
    echo "Usage: "
    echo "       wifi_bt_test_cmd.sh  set   sta/ap     < 0 | 1 >"
    echo "       wifi_bt_test_cmd.sh  set   sta_link   < ssid >  < password >"
    echo "       wifi_bt_test_cmd.sh  set   bt_init    < baudrate >  < timeout >"
    echo "       wifi_bt_test_cmd.sh  set   bt_en      < 0 | 1 >"
    echo "       wifi_bt_test_cmd.sh  test  qcmbr      < 0 | 1 >"
    echo "       wifi_bt_test_cmd.sh  test  btdiag     < 0 | 1 >"
    echo "       wifi_bt_test_cmd.sh  test  insmod     < loop >"
    echo "       wifi_bt_test_cmd.sh  test  sta_link   < ipAddr >  < loop >"
    echo "       wifi_bt_test_cmd.sh  test  sdio_link  < mmcN >"
    exit 0
fi

if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
    echo "Usage: wifi_bt_test_cmd.sh <cmd> <cmd_obj> <param_0> <param_1(optional)>"
    exit 3
fi

function unload_wifi_driver_service()
{
    # Kill wpa_supplicant
    if [ `ps | busybox grep -c wpa_supplicant` -gt 0 ]; then
        echo "kill process wpa_supplicant first"
        kill `ps | busybox grep wpa_supplicant | busybox awk -F ' ' '{print $2}'`
        sleep .5
    fi

    # Kill hostapd
    if [ `ps | busybox grep -c hostapd` -gt 0 ]; then
        echo "kill process hostapd first"
        kill `ps | busybox grep hostapd | busybox awk -F ' ' '{print $2}'`
        sleep .5
    fi

    # Unload driver modules
    if [ `lsmod | busybox grep -c $WIFI_NAM` -gt 0 ]; then
        rmmod $WIFI_NAM
        sleep .5
    fi
}

# Test Wi-Fi sdio driver insmod or rmmod produce
function check_wifi_driver_insmod()
{
    unload_wifi_driver_service

    local CNT=0
    while [ $CNT -lt $param_0 ]
    do
        CNT=`busybox expr $CNT + 1`
        insmod $WIFI_DIR/$WIFI_NAM.ko
        sleep 1.5

        if [ `lsmod | busybox grep -c $WIFI_NAM` -le 0 ]; then
            echo "Insmod $WIFI_NAM.ko module failed, CNT:$CNT"
            return 2
        fi

        rmmod $WIFI_NAM
        sleep .5
        if [ `lsmod | busybox grep -c $WIFI_NAM` -gt 0 ]; then
            echo "Rmmod $WIFI_NAM.ko module failed, CNT:$CNT"
            return 1
        fi

        echo "Test insmod $WIFI_NAM.ko module succ, CNT:$CNT"
    done

    return 0
}

# Test Wi-Fi autotest mode: qcmbr tool
function enable_wifi_autotest_mode()
{
    unload_wifi_driver_service
    if [ `ps | busybox grep -c qcmbr` -gt 0 ]; then
        kill `ps | busybox grep qcmbr | busybox awk -F ' ' '{print $2}'`
        sleep .5
    fi

    if [ $param_0 -eq 0 ]; then
        echo "Exit wifi autotest[$cmd_obj] mode."
        ifconfig rndis0 down
        return 0
    fi

    ifconfig rndis0 up
    sleep .2
    ifconfig rndis0 192.168.42.2
    sleep .2

    insmod $WIFI_DIR/$WIFI_NAM.ko con_mode=5
    if [ `lsmod | busybox grep -c $WIFI_NAM` -le 0 ]; then
        echo "Wifi test mode insmod failed"
        return 2
    fi

    sleep 1.5
    ifconfig wlan0 up
    sleep .2

    $QCMBR_CMD &
    if [ `ps | busybox grep -c qcmbr` -le 0 ]; then
        echo "qcmbr run failed."
       return 2
    fi

    return 0
}

# Test Wi-Fi autotest mode: qcmbr tool
function enable_bt_autotest_mode()
{
    unload_wifi_driver_service

    if [ $param_0 -eq 0 ]; then
        echo "Exit wifi autotest[$cmd_obj] mode."
        ifconfig rndis0 down
        return 0
    fi

    ifconfig rndis0 up
    sleep .2
    ifconfig rndis0 192.168.42.2
    sleep .2

    $BTDIAG_CMD UDT=yes PORT=2390 IOType=SERIAL QDARTIOType=ethernet BT-DEVICE=/dev/ttyS4 BT-BAUDRATE=1000000

    return 0
}

# Wi-Fi enable / disable
function enable_wifi_setup()
{
    if [ $param_0 -gt 1 -o $param_0 -lt 0 ]; then
        echo "enable_wifi_setup invalid parameter."
        return 3
    fi

    unload_wifi_driver_service

    if [ $param_0 -eq 0 ]; then
        echo "Wifi mode[$cmd_obj] disable."
        return 0
    fi

    if [ is$cmd_obj = is"ap" ]; then
        if [ ! -f $AP_CONF -o ! -f $HOSTAPD_CMD ]; then
            echo "ap conf file or hostapd not exist."
            return 2
        fi
    fi

    if [ is$cmd_obj = is"sta" ]; then
        if [ ! -f $WPA_SUPP_CMD ]; then
            echo "Wpa_supplicant not exist."
            return 2
        fi

        if [ ! -f $STA_CONF ]; then
            echo "Sta cfg file not exist, generate default file."
            echo "ctrl_interface=$CTRL_DIR/sockets" > $STA_CONF
            echo "device_name=Phantom No"          >> $STA_CONF
            echo "manufacturer=DJI"                >> $STA_CONF
            echo "bss_max_count=40"                >> $STA_CONF
            echo "autoscan=periodic:1"             >> $STA_CONF
        fi
    fi

    if [ ! -f $DHCP_CONF ]; then
        echo "dhcp config file not exist."
        return 2
    fi

    insmod $WIFI_DIR/$WIFI_NAM.ko
    if [ `lsmod | busybox grep -c $WIFI_NAM` -le 0 ]; then
        echo "Insmod $WIFI_NAM.ko module failed."
        return 2
    fi

    busybox ifconfig wlan0 down
    sleep .5
    busybox ifconfig wlan0 up

    if [ is$cmd_obj = is"ap" ]; then
        busybox ifconfig wlan0 192.168.2.1
        echo "Start run hostapd"
        $HOSTAPD_CMD -B $AP_CONF
        if [ `ps | busybox grep -c hostapd` -le 0 ]; then
            echo "Hostapd setup failed, please check hostapd log."
            return 2
        fi
        sleep .5
        busybox udhcpd $DHCP_CONF
    elif [ is$cmd_obj = is"sta" ]; then
        echo "Start to run wpa_supplicant"
        $WPA_SUPP_CMD -iwlan0 -Dnl80211 -c$STA_CONF -dd -B
        if [ `ps | busybox grep -c wpa_supplicant` -le 0 ]; then
            echo "Wpa_supplicant setup failed, please check wpa_supplicant log."
            return 2
        fi
        sleep .2
    else
        echo "Invalid param"
        return 3
    fi
    return 0
}

# Wi-Fi STA mode link a AP Test
function wifi_sta_link_ap()
{
    echo "Connecting AP, ssid[$param_0], psk[$param_1]"
    if [ ! -f $WPA_CLI_CMD ]; then
        echo "wpa_cli is not exist, please recheck."
        return 2
    fi

    wpa_cli -g /data/misc/wifi/sockets/wlan0 remove_network 0
    sleep .1
    wpa_cli -g /data/misc/wifi/sockets/wlan0 scan
    sleep .1
    wpa_cli -g /data/misc/wifi/sockets/wlan0 add_network
    sleep .1
    wpa_cli -g /data/misc/wifi/sockets/wlan0 set_network 0 auth_alg OPEN
    sleep .1

    if [ $param_1 -eq 0 ]; then
        wpa_cli -g /data/misc/wifi/sockets/wlan0 set_network 0 key_mgmt NONE
        sleep .1
    else
        wpa_cli -g /data/misc/wifi/sockets/wlan0 set_network 0 key_mgmt WPA-PSK
        sleep .1
        wpa_cli -g /data/misc/wifi/sockets/wlan0 set_network 0 psk \"$param_1\"
        sleep .1
        wpa_cli -g /data/misc/wifi/sockets/wlan0 set_network 0 proto RSN
        sleep .1
    fi

    wpa_cli -g /data/misc/wifi/sockets/wlan0 set_network 0 mode 0
    sleep .1
    wpa_cli -g /data/misc/wifi/sockets/wlan0 set_network 0 ssid \"$param_0\"
    sleep .1
    wpa_cli -g /data/misc/wifi/sockets/wlan0 select_network 0
    sleep .1
    wpa_cli -g /data/misc/wifi/sockets/wlan0 enable_network 0
    sleep .1

    local CHECK_COUNT=0
    while [ $CHECK_COUNT -lt 5 ]
    do
        CHECK_COUNT=`busybox expr $CHECK_COUNT + 1`
        wpa_cli -g /data/misc/wifi/sockets/wlan0 status | busybox grep wpa_state=COMPLETED
        if [ $? = 0 ]; then
            echo "Connected SUCC."
            break
        else
            echo "Waiting for Connect, COUNT $CHECK_COUNT"
            sleep 1
        fi
    done

    # Kill dhcpcd
    DHCPCD_PID_FILE=/data/misc/dhcp/dhcpcd-wlan0.pid
    if [ `ps | busybox grep -c dhcpcd` -gt 0 ]; then
        echo "kill process dhcpcd first"
        kill `ps | busybox grep dhcpcd | busybox awk -F ' ' '{print $2}'`
        if [ -f "$DHCPCD_PID_FILE" ]; then
            rm $DHCPCD_PID_FILE
        fi
    fi

    echo "Start to process dhcpcd procedure"
    # DHCP procedure
    dhcpcd wlan0 --noipv4ll
    if [ $? = 0 ]; then
        echo "DHCP Success"
    else
        echo "DHCP Failed"
        return 1
    fi
    return 0
}

# Wi-Fi station mode check ping ap
function wifi_sta_link_check_ping()
{
    if [ `lsmod | busybox grep -c $WIFI_NAM` -le 0 ]; then
        echo "Insmod $WIFI_NAM.ko module failed, check ping fail."
        return 2
    fi

    if [ `ps | busybox grep -c wpa_supplicant` -le 0 ]; then
        echo "wpa_supplicant is not exist, check ping fail."
        return 2
    fi

    local CT=0
    local LOOP=$param_1
    local PASS_NO=0
    # 0 stands for 1000000
    if [ $param_1 -eq 0 ]; then
        LOOP=1000000
    fi

    sleep 1
    echo "Start to check ping..."
    while [ $CT -lt $LOOP ]
    do
        if [ $PASS_NO != $CT ]; then
            return 1
        fi

        CT=`busybox expr $CT + 1`

        RESULT=`busybox ping -s $CT -c 1 $param_0`
        echo $RESULT | busybox grep " 0% packet loss"
        if [ $? = 0 ]
        then
            echo "-------- ${CT} time PASS-------- "
            PASS_NO=`busybox expr $PASS_NO + 1`
        else
            echo "FAIL: ${CT} time failed while ping AP"
        fi
        sleep 1
    done
    return 0
}

function enable_bt_setup()
{
    if [ $1 -gt 1 -o $1 -lt 0 ]; then
        echo "enable_bt_setup invalid parameter."
        return 3
    fi

    if [ `hciconfig | busybox grep -c hci0` -le 0 ]; then
        echo "hci0 interface not exist."
        return 2
    fi

    $HCICONFIG_CMD hci0 down
    if [ $1 -eq 0 ]; then
        echo "enable_bt_setup bt disable."
        return 0
    fi

    $HCICONFIG_CMD hci0 up
    sleep .1

    if [ `hciconfig hci0 | busybox grep -c UP` -le 0 ]; then
        echo "hci0 interface can not up."
        return 5
    fi

    $HCICONFIG_CMD hci0 noleadv
    $HCICONFIG_CMD hci0 noscan
    echo "enable_bt_setup hci0 up succ."
    return 0
}

# Bt interface init
function enable_bt_init()
{
    if [ `hciconfig | busybox grep -c hci0` -gt 0 ]; then
        echo "hci0 interface already exist, up hci0 directly."
    else
        $HCIATTACH_CMD /dev/ttyS4 qca $param_0 -t$param_1 noflow
        sleep 2
    fi

    enable_bt_setup 1
    return $?
}

function check_sdio_module_link()
{
    if [ ! -d $SDIO_DIR/$param_0:0001:1 ]; then
        echo "sdio link check failed."
        return 1
    fi

    echo "sdio link check success."
    return 0
}

if [ "$cmd" = "test" ]; then
    # insmod wifi driver test
    if [ is$cmd_obj = is"insmod" ]; then
        echo "will test wifi driver sdio insmod/rmmod, cnt:$param_0."
        check_wifi_driver_insmod
        if [ $? -gt 0 ]; then
            exit 1
        fi
    # wifi autotest tool
    elif [ is$cmd_obj = is"qcmbr" ]; then
        enable_wifi_autotest_mode
        if [ $? -gt 0 ]; then
            exit 1
        fi
    # bt autotest tool
    elif [ is$cmd_obj = is"btdiag" ]; then
        enable_bt_autotest_mode
    elif [ is$cmd_obj = is"sta_link" ]; then
        wifi_sta_link_check_ping
        if [ $? -gt 0 ]; then
            exit 1
        fi
    elif [ is$cmd_obj = is"sdio_link" ]; then
        check_sdio_module_link
        if [ $? -gt 0 ]; then
            exit 1
        fi
    else
        echo "Unknow test cmd obj:$cmd_obj, FAILURE"
        exit 3
    fi
elif [ "$cmd" = "set" ]; then
    if [ is$cmd_obj = is"ap" -o is$cmd_obj = is"sta" ]; then
        enable_wifi_setup
        if [ $? -gt 0 ]; then
            exit 1
        fi
    elif [ is$cmd_obj = is"sta_link" ]; then
        wifi_sta_link_ap
        if [ $? -gt 0 ]; then
            exit 1
        fi
    elif [ is$cmd_obj = is"bt_init" ]; then
        enable_bt_init
        if [ $? -gt 0 ]; then
            exit 1
        fi
    elif [ is$cmd_obj = is"bt_en" ]; then
        enable_bt_setup $param_0
        if [ $? -gt 0 ]; then
            exit 1
        fi
    else
        echo "Unknow test cmd obj:$cmd_obj, FAILURE"
        exit 3
    fi
else
    echo "CMD INVALID, FAILURE"
    exit 3
fi

echo "Autotest script exit SUCC."
exit 0
