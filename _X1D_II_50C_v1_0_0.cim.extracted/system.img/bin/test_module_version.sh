echo "eagle version:"
getprop | grep "dji.build.version"

echo "\n"
echo "fpga version:"
upgrade_fw -c -n farmus

echo "\n"
echo "pwrctrl version:"
upgrade_fw -c -n pwrctrl

echo "\n"
echo "suc version:"
upgrade_fw -c -n suc

echo "\n"
echo "cpld version:"
test_i2c 4 r 0x20 0 4
