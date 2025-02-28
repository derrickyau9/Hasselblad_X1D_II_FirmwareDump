#!/system/bin/sh

. lib_test_cases.sh

eagle_state()
{
    echo 6 1 > /sys/devices/platform/soc/f0a00000.apb/f0a10000.i2c0/i2c-0/0-0048/f0a10000.i2c0\:tps65961@48\:on_off_ldo/state
    usleep 100000
    amt_test_cmd efuse
    local efuse_ret=$?
    echo 6 0 > /sys/devices/platform/soc/f0a00000.apb/f0a10000.i2c0/i2c-0/0-0048/f0a10000.i2c0\:tps65961@48\:on_off_ldo/state
    return $efuse_ret
}

local idx=1
sleep 1
eagle_state
local state_ret=$?
if [ $state_ret -ne 0 ]; then
    echo "red"
    odindb-send -s suc -m set_led E_LedState_On E_LedColor_Red
    for idx in $(seq 5) ; do
        odindb-send -s suc -m set_led E_LedState_On E_LedColor_Red
        sleep 1
        odindb-send -s suc -m set_led E_LedState_On E_LedColor_Green
        sleep 1
    done
    odindb-send -s suc -m set_led E_LedState_On E_LedColor_Red
    echo "switch to pro failed!"
    exit 1
else
    echo "green"
    odindb-send -s suc -m set_led E_LedState_On E_LedColor_Green
    echo "switch to pro success!"
    exit 0
fi
