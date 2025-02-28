#!/system/bin/sh -x

trap "check_error" ERR

# Arguments, optional
# 1. Continue upgrade on failure of any node
# 2. Use other base path than /system

CONTINUE_ON_FAIL=${1:-0}
SYSPATH=${2:-/system/}

EXITSTATUS=0
NODE=""
PROGRESS_FILE=/tmp/progress
persistent_storage=/data

set_max_progress() {
    echo 'progress='$1 > $PROGRESS_FILE
}

set_progress() {
    odindb-send -s upgrade -p upgrade_progress $1
}

check_error() {
    EXITSTATUS=$((EXITSTATUS + $?))
    echo "Failed to upgrade $NODE" >&2
    [[ $CONTINUE_ON_FAIL -ne 1 ]] && exit $EXITSTATUS
}

PROD_TYPE_X1DM2=12
PROD_TYPE_CFV=14
PROD_TYPE=`getprop dji.prod_type`
HW_REV=`getprop dji.hw_rev`

echo "======= Start upgrade nodes ======="
echo "Continue on fail: $CONTINUE_ON_FAIL"


# Before upgrading CPLD mark CPLD as possibly dirty
# so CPLD is restored on upgrade fail
touch $persistent_storage/cpld-dirty; sync
NODE="CPLD"
set_max_progress 56
$SYSPATH/bin/upgrade_cpld.sh && rm $persistent_storage/cpld-dirty; sync

NODE="FPGA"
set_max_progress 63
$SYSPATH/bin/upgrade_fpga.sh

NODE="SPC"
set_max_progress 70
$SYSPATH/bin/upgrade_spc.sh

if [ $PROD_TYPE = $PROD_TYPE_X1DM2 ]; then
NODE="TP"
set_max_progress 76
$SYSPATH/bin/upgrade_tp.sh
elif [ $PROD_TYPE = $PROD_TYPE_CFV ]; then
NODE="BIFBOD"
set_max_progress 73
$SYSPATH/bin/upgrade_bifbody.sh || true
NODE="BIFGRI"
set_max_progress 76
$SYSPATH/bin/upgrade_bifgrip.sh || true
NODE="TOUCH"
set_max_progress 79
$SYSPATH/bin/ec1702_configure_touch.sh
fi

NODE="GL3227"
set_max_progress 82
$SYSPATH/bin/upgrade_gl3227.sh

NODE="SUC"
set_max_progress 99
$SYSPATH/bin/upgrade_suc.sh

set_progress 100

echo "======= End upgrade nodes ======="

exit $EXITSTATUS
