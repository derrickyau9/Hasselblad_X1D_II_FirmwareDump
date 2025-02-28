#!/system/bin/sh
#
# 2018.09
#

REPLY=$(odindb-send -s suc -m func_test E_FuncTestModule_UsbCharging E_FuncTestAction_Start 0 0 0 | awk 'NR==1{print $2; exit}')

/system/bin/returnstatus_to_string.sh $REPLY
if [ "$REPLY" == 0 -o "$REPLY" == 3 ]; then
    exit 0
else
    exit 1
fi
