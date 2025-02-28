#!/system/bin/sh

#TX_ENGINE="wl"
#LOG_LEVEL="3"

#if [ -f /data/dji/camera_factory ]; then
#    TX_ENGINE="lcdc"
#    echo "starting camera service in factory mode"
#fi

# TODO: will add hbl camera service later
/system/bin/camservice -e wayland
