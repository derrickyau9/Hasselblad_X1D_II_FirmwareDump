#!/system/bin/sh

#VENDOR_ID_LBS=0x51
#VENDOR_ID_MBS=0x04
#PRODUCT_ID_LBS=0x35
#PRODUCT_ID_MBS=0xc0

VENDOR_ID_LBS=81
VENDOR_ID_MBS=4
PRODUCT_ID_LBS=53
PRODUCT_ID_MBS=192

test_pmic_link()
{
    local ret=0
    local retval=0
    ((retval=`i2cget -f -y 0 0x49 0x4f`))
    if [ "$retval" -ne "$VENDOR_ID_LBS" ]; then
        echo "PMIC link fail"
        echo $retval
        ret=1
    fi
    ((retval=`i2cget -f -y 0 0x49 0x50`))
    if [ "$retval" -ne "$VENDOR_ID_MBS" ]; then
        echo "PMIC link fail"
        echo $retval
        ret=1
    fi
    ((retval=`i2cget -f -y 0 0x49 0x51`))
    if [ "$retval" -ne "$PRODUCT_ID_LBS" ]; then
        echo "PMIC link fail"
        echo $retval
        ret=1
    fi
    ((retval=`i2cget -f -y 0 0x49 0x52`))
    if [ "$retval" -ne "$PRODUCT_ID_MBS" ]; then
        echo "PMIC link fail"
        echo $retval
        ret=1
    fi
    return $ret
}

test_pmic_link
echo $?
exit $?
