#!/system/bin/sh
#
# 2018.09
#

REPLY=$(odindb-send -s suc -m func_test E_FuncTestModule_SucReleasebar E_FuncTestAction_Stop 0 0 0 | awk 'NR==1{print $2; exit}')
echo $REPLY

# The DJI-test-tool handles the reply as a bool.
# If the return status of the function is "Started" the script should be
# considered successfull by the DJI-test-tool.
if [ $REPLY == '1' -o $REPLY == '3' ]; then
    exit 0
else
    exit 1
fi
