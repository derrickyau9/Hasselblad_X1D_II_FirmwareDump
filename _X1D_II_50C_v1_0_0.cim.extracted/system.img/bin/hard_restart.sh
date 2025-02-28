#!/system/bin/sh
tty=/dev/ttyS1

odindb-send -s suc -p autostart 1

stm32flash -i ':31,-31' $tty

