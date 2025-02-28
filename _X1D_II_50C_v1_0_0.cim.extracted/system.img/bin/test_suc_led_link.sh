#!/system/bin/sh
#
# 2018.09
#

REPLY=$(odindb-send -s suc -m func_test E_FuncTestModule_SucLcdLed E_FuncTestAction_Start 0 0 0 | awk 'NR==1{print $2; exit}')

# The DJI-test-tool handles the reply as a bool.
# If the return status of the function is "Started" the script should be
# considered successfull by the DJI-test-tool.
if [ $REPLY == '1' -o $REPLY == '3' ]; then
    echo "ERROR: TEST FINISHED WITH ERRORS"
    exit 1
else
    echo "TEST FINISHED WITHOUT ERRORS, DID THE LED TOGGLE BETWEEN RED, GREEN AND ORANGE?"
    exit 0
fi
