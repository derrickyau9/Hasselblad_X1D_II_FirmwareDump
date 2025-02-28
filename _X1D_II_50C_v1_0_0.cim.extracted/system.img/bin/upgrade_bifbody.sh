#!/system/bin/sh
#
# 2018.09
#

# Shared functions
. /system/bin/upgrade_common.sh

stop_live_view

hex-writer -m 6 -t flash -f /system/etc/firmware/rtnodes/bifrost_body.hex
REPLY=$?
if [ "$REPLY" == 0 ]; then
    echo "SUCCEEDED TO UPGRADE BIFROST BODY"
else
    echo "FAILED TO UPGRADE BIFROST BODY"
fi
exit $REPLY
