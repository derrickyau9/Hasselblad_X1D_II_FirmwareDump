#!/system/bin/sh
################################################################################
# About
# Upgrades the usb controllers which the sd cards are connected to.
#
# Usage:
# gl_flash.sh
#
# Options
# It's possible to skip restarting the storage services after upgrade by
# setting the environment variable RESTART_SERVICE=0
#
# Example:
# $ RESTART_SERVICE=0 /system/bin/gl_flash.sh
#
# upgrade flow:
# ---------------------------
# 1. Unmount all volumes
# 2. Stop the storage services (storage_daemon and vold)
# 3. Power up the usb controllers
# 4. Disable autosuspend of the storage/usb devices
# 5. Flash the usb controllers
# 6. Restart the usb controller
# 7. Enable autosuspend
# 8. Start the storage services (vold and storage daemon) [OPTION]
# 9. Done!
#
# Improvements (TODOS):
# ---------------------
# * If user removes sd card during upgrade the driver will
#   turn off power to controller. This could be fixed by adding an
#   attribute on sd-reset driver to disable power handling
#
# * Make sure camera does not enter suspend if the script run standalone
# * Return exit code from script so hbl-upgrade.sh can decide what to do if
#   something went wrong during upgrade (retry etc).
################################################################################

################################################################################
# Files used by script:
#
################################################################################
# Device 0 that will be upgraded by script
SG0=/dev/sg0

# Device 1 that will be upgraded by script
SG1=/dev/sg1

# The sd-reset driver handles power to the usb controller so the attribute is
# used to power on/off the controller. If no cards are inserted the power will
# be off.
SD_RST_PHYPWR="/sys/devices/platform/soc/f0a00000.apb/f0a00000.apb:sd_reset/phypwr"

# Force a card detect by writing to this file
SD_TRIGGER_CARD_DETECT="/sys/devices/platform/soc/f0a00000.apb/f0a00000.apb:sd_reset/trigger_card_detection"

# Don't know what this does but keeping it in case something is polling for this
# file. My guess is that it was thought off as an indication that the system should
# not enter suspend when this file is present (?)
USB_NO_SUSPEND_FILE="/data/usb_no_suspend"

# Function arguments
ACTION_START=1
ACTION_STOP=2

# Global flash result variables
# Initialized to 1 (Error)
GLOBAL_SG0_RES=1
GLOBAL_SG1_RES=1

# Check if user has specified RESTART_SERVICES
if [ -z $RESTART_SERVICES ]; then
    RESTART_SERVICES=1
fi

################################################################################
# Helper Functions
#
################################################################################

################################################################################
# function: control_storage_services
# Before upgrading the storage services are shut down so they wont interfere
# with the upgrade process of the usb controllers.
#
# When the upgrade is completed the services are restarted.
# Arguments:
#   Arg1 action:
#   - ACTION_START => start vold and then start storage_daemon
#   - ACTION_STOP  => stop storage_daemon and then stops vold
################################################################################
function control_storage_services {
    # Handle start/stop action
    if [ $1 -eq $ACTION_START ]; then
        ACTION="start"
        SERVICES="vold storage_daemon"
    else
        ACTION="stop"
        SERVICES="storage_daemon vold"
    fi
    # Start or stop the services in the list
    for service in $SERVICES
    do
        echo "$ACTION service $service. Please wait..."
        setprop ctl.$ACTION $service
        sleep 5
    done
}

##########################################################§######################
# function: control_autosuspend
#
# Controls the autosuspend files of the device
# Arguments:
#   Arg1 action:
#     - ACTION_START => set device power state to auto
#     - ACTION_STOP  => set device power state to on
################################################################################
function control_autosuspend {
    if [ $1 -eq $ACTION_STOP ]; then
        echo "Disabling autosuspend"
        MODE="on"
    else
        echo "Enabling autosuspend"
        MODE="auto"
    fi
    # Handle devices under /sys/bus/scsi/devices
    DEVICES=$(find /sys/bus/scsi/devices/[0-9]*/power -name control)
    for device in $DEVICES
    do
       echo  "  echo $MODE > $device"
       echo $MODE > $device
    done

    # Handle usb devices
    USB_DEVICES=$(find /sys/bus/usb/devices/[0-9]-[0-9]/power -name "control")
    for device in $USB_DEVICES
    do
        echo "  echo $MODE > $device"
        echo $MODE > $device
    done
}

################################################################################
# Function: control_usb_controllers
#
# Power up the usb phy by writing (echo) to
# /sys/devices/platform/soc/f0a00000.apb/f0a00000.apb:sd_reset/phypwr
#
# Arguments:
#   Arg1 action:
#     - ACTION_START => Power on the usb controllers
#     - ACTION_STOP  => Power off the usb controllers
#
################################################################################
function control_usb_controllers {
    if [ $1 -eq $ACTION_START ]; then

        echo "Power on usb controllers. Please wait..."
        echo "  echo 1 > $SD_RST_PHYPWR"
        echo 1 > $SD_RST_PHYPWR
        sleep 3
        DEVICE_COUNT=$(ls /dev/sg* | wc -l)
        if [ $DEVICE_COUNT -ne 2 ]; then
            echo "Warning! Expected two devices but got $DEVICE_COUNT"
        fi
    else
        echo "Power off usb controllers. Please wait..."
	echo "  echo 0 > $SD_RST_PHYPWR"
        echo 0 > $SD_RST_PHYPWR
        sleep 3
    fi
}

################################################################################
# Function: flash_usb_controller
#
# Upgrade the provided usb controller device
# Arguments:
#   Arg 1: The name of the device (i.e /dev/sg0)
#   Arg 2: Reference to the global variable where the result is stored
#
################################################################################
function flash_usb_controller {
    DEVICE=$1
    # use nameref to treat argument as a bound variable (name reference)
    nameref GLOBAL_VARIABLE_REFERENCE=$2
    if [ -a $DEVICE ]; then
        echo "Start flashing $DEVICE. Please wait..."
        gl_flash $DEVICE
        # Store the result into the reference
        GLOBAL_VARIABLE_REFERENCE=$?
    else
        echo "Warning! $DEVICE does not exist! Can't upgrade device!"
    fi
}

################################################################################
# Function: flash_usb_controllers
# Run gl_flash on both /dev/sg0 and /dev/sg1
# Arguments:
#   None
################################################################################
function flash_usb_controllers {
    # Flash /dev/sg0
    flash_usb_controller $SG0 GLOBAL_SG0_RES
    # Flash /dev/sg1
    flash_usb_controller $SG1 GLOBAL_SG1_RES
}

################################################################################
# Function: unmount_all_volumes
# Calls vold using a special command which will unmount any mounted device.
# The command will also detach from pc if the camera is exported.
#
# Arguments:
#   None
################################################################################
function unmount_all_volumes {
    echo "Unmounting all mounted storage devices... Please wait"
    test_hal_storage -c "0 volume detach_pc"
    test_hal_storage -c "0 volume unmount_all"
    sleep 3
}

################################################################################
# Function: trigger_card_detection
#
# Calls the sd-reset driver to force card detection. Useful after upgrade.
#
# Arguments:
#   None
################################################################################
function trigger_card_detection {
    echo "Force card detection. Please wait..."
    echo "  echo 1 > $SD_TRIGGER_CARD_DETECT"
    echo 1 > $SD_TRIGGER_CARD_DETECT
}

################################################################################
#
# Main script
#
################################################################################

# Sanity check
if [ ! -f $SD_RST_PHYPWR ]; then
    echo "Warning! Can't to find phypwr control file. $SD_RST_PHYPWR"
fi

# Init - create a file (not sure its needed but keep it for now...)
touch $USB_NO_SUSPEND_FILE

# Unmount all volumes
unmount_all_volumes

# Stop storage services (storage_daemon & vold)
control_storage_services $ACTION_STOP

# Check if sg0 or sg1 exists, if so, then power off so we get clean state
# before starting the upgrade process
if [ -a $SG0 -o -a $SG1 ]; then
    control_usb_controllers ACTION_STOP
fi

# Power on the usb controllers
control_usb_controllers $ACTION_START

# Disable autosuspend to avoid devices going into suspend during upgrade
control_autosuspend $ACTION_STOP

# Flash the usb controllers
flash_usb_controllers

# Restart the usb controllers if there were any cards mounted before upgrading
control_usb_controllers $ACTION_STOP

# Force trigger card detection after upgrade
# It will power up controllers with card inserted
trigger_card_detection

# Check if we should restart the storage services
if [ $RESTART_SERVICES -eq 1 ]; then
    # Start up storage services
    control_storage_services $ACTION_START
else
    echo "Skip restarting services after upgrade!"
fi

# Cleanup - remove the file
rm $USB_NO_SUSPEND_FILE

# Upgrade done - print result
if [ $GLOBAL_SG0_RES -ne 0 -o $GLOBAL_SG1_RES -ne 0 ]; then
    echo "gl_flash.sh failed!"
else
    echo "gl_flash.sh successful!"
fi

################################################################################
