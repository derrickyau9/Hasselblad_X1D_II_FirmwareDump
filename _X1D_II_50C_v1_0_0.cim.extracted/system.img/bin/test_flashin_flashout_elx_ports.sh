#!/system/bin/sh
#
# 2018.09
#

timeout=10
start=`cat /proc/uptime | busybox awk -F. '{print $1}'`
elapsed()
{
    local now=`cat /proc/uptime | busybox awk -F. '{printf $1}'`
    local diff=$(($now-$start))
    echo $diff
}

REPLY=$(odindb-send -s suc -m func_test E_FuncTestModule_CfvFlashinFlashoutElx E_FuncTestAction_Start 0 0 0 | awk 'NR==1{print $2; exit}')
while [ $REPLY != '=' ]
do
    echo $REPLY
    sleep 2
    REPLY=$(odindb-send -s suc -m func_test E_FuncTestModule_CfvFlashinFlashoutElx E_FuncTestAction_Check 0 0 0 | awk 'NR==1{print $2; exit}')
    if [ $(elapsed) -ge $timeout ]; then
        break
    fi
done
if [ "$REPLY" == '=' ]; then
   REPLY=0
fi
/system/bin/returnstatus_to_string.sh $REPLY
if [ "$REPLY" == 0 -o "$REPLY" == 3 ]; then
    exit 0
else
    exit 1
fi
