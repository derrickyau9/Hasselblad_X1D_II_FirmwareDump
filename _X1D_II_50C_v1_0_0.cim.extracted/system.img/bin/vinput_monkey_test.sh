#!/bin/sh
#######################################################
# $Version:      v1.0
# $Function:     Shell
# $Author:       elsas.liu
# $Create Date:  2018-10-18 09:30
# $Description:  vinput_monkey_test.sh
#######################################################

# before test

echo "Enter vinput monkey test..."
if [ -z "$1" ]
then
    echo "Usage: vinput_monkey_test.sh <loop_number>"
    exit 1
fi

full_press_num=0
half_press_num=0
af_press_num=0
ae_l_press_num=0
iso_press_num=0
af_d_press_num=0
browse_press_num=0
soft_key_1_press_num=0
soft_key_2_press_num=0
select_key_press_num=0
menu_key_press_num=0
front_wheel_left_num=0
front_wheel_right_num=0
back_wheel_left_num=0
back_wheel_right_num=0

function rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(($RANDOM + 10000))
    echo $(($num%$max+$min))
}

echo "----------vinput monkey test start-----------"
loop=$1
vinput_daemon &
sleep 1
echo "all loop is $loop"
while [ $loop -gt 0 ]
do
rnd=$(rand 100 1600)
# echo $rnd
echo ${rnd#-}
echo "Now loop number is $loop"
case ${rnd#-} in
    1[0-9][0-9])
        vinput2 keyevent full_press
        full_press_num=$(($full_press_num+1))
        echo "capture button full_press"
        sleep 0.5
        ;;
    2[0-9][0-9])
        vinput2 keyevent half_press
        half_press_num=$(($half_press_num+1))
        echo "capture button half_press"
        ;;
    3[0-9][0-9])
        vinput2 keyevent af
        af_press_num=$(($af_press_num+1))
        echo "AF|MF key press"
        ;;
    4[0-9][0-9])
        vinput2 keyevent ios
        iso_press_num=$(($iso_press_num+1))
        echo "iso|wb key press"
        ;;
    5[0-9][0-9])
        vinput2 keyevent ae_l
        ae_l_press_num=$(($ae_l_press_num+1))
        echo "ae_l key press"
        ;;
    6[0-9][0-9])
        vinput2 keyevent af_d
        af_d_press_num=$(($af_d_press_num+1))
        echo "af_d key press"
        ;;
    7[0-9][0-9])
        vinput2 keyevent browse_key
        browse_press_num=$(($browse_press_num+1))
        echo "browse key press"
        ;;
    8[0-9][0-9])
        vinput2 keyevent select_key
        select_key_press_num=$(($select_key_press_num+1))
        echo "select key press"
        ;;
    9[0-9][0-9])
        vinput2 keyevent soft_key_1
        soft_key_1_press_num=$(($soft_key_1_press_num+1))
        echo "soft_key_1 key press"
        ;;
    10[0-9][0-9])
        vinput2 keyevent soft_key_2
        soft_key_2_press_num=$(($soft_key_2_press_num+1))
        echo "soft_key_2 key press"
        ;;
    11[0-9][0-9])
        vinput2 keyevent menu_key
        menu_key_press_num=$(($menu_key_press_num+1))
        echo "menu key press"
        ;;
    12[0-9][0-9])
        vinput2 keyevent front_wheel_left
        front_wheel_left_num=$(($front_wheel_left_num+1))
        echo "front wheel turn left"
        ;;
    13[0-9][0-9])
        vinput2 keyevent front_wheel_right
        front_wheel_right_num=$(($front_wheel_right_num+1))
        echo "front wheel turn right"
        ;;
    14[0-9][0-9])
        vinput2 keyevent back_wheel_left
        back_wheel_left_num=$(($back_wheel_left_num+1))
        echo "back wheel turn left"
        ;;
    15[0-9][0-9])
        vinput2 keyevent back_wheel_right
        back_wheel_right_num=$(($back_wheel_right_num+1))
        echo "back wheel turn right"
        ;;
    *)
        echo "wrong number"
        ;;
esac
sleep 0.1
loop=$(($loop-1))
# ((loop--))
done
echo "------vinput monkey test over------"
# echo "capture button full_press $full_press_num times, $(printf "%.2f%%" $(($full_press_num*100/$1)))."
echo "capture button full_press $full_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$full_press_num'/'$1')*100}'`."
echo "capture button half_press $half_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$half_press_num'/'$1')*100}'`."
echo "AF|MF key press $af_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$af_press_num'/'$1')*100}'`."
echo "ae_l key press $ae_l_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$ae_l_press_num'/'$1')*100}'`."
echo "iso|wb key press $iso_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$iso_press_num'/'$1')*100}'`."
echo "af_d key press $af_d_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$af_d_press_num'/'$1')*100}'`."
echo "browse key press $browse_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$browse_press_num'/'$1')*100}'`."
echo "soft_key_1 press $soft_key_1_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$soft_key_1_press_num'/'$1')*100}'`."
echo "soft_key_2 press $soft_key_2_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$soft_key_2_press_num'/'$1')*100}'`."
echo "select key press $select_key_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$select_key_press_num'/'$1')*100}'`."
echo "menu key press $menu_key_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$menu_key_press_num'/'$1')*100}'`."
echo "front wheel turn left $front_wheel_left_num times, `awk 'BEGIN{printf "%.2f%%\n",('$front_wheel_left_num'/'$1')*100}'`."
echo "front wheel turn right $front_wheel_right_num times, `awk 'BEGIN{printf "%.2f%%\n",('$front_wheel_right_num'/'$1')*100}'`."
echo "back wheel turn left $back_wheel_left_num times, `awk 'BEGIN{printf "%.2f%%\n",('$back_wheel_left_num'/'$1')*100}'`."
echo "back wheel turn right $back_wheel_right_num times, `awk 'BEGIN{printf "%.2f%%\n",('$back_wheel_right_num'/'$1')*100}'`."
echo "-----------------------------------"
exit 0
