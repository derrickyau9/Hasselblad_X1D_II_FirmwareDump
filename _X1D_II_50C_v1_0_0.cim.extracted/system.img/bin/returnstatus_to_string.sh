#!/system/bin/sh
#
# 2018.09
#

case "$1" in
    0)
        echo 'SUCCESS'
        ;;
    1)
        echo 'ERROR'
        ;;
    2)
        echo 'PARAMETER_ERROR'
        ;;
    3)
        echo 'BUSY' #Used when a test has been started but not finished.
        ;;
    4)
        echo 'CANCELED'
        ;;
    *)
        echo 'FAIL'
        ;;
esac
