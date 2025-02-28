#!/system/bin/sh
#
# 2018.09
#
key_name="bodystate-uinput"
key_code="KEY_A"

REPLY=$(/system/bin/wait_for_key.sh $key_name $key_code)
REPLY=$?
/system/bin/returnstatus_to_string.sh $REPLY
exit $REPLY
