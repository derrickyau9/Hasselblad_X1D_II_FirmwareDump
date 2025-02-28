#!/bin/sh
#######################################################
# $Version:      v1.0
# $Function:     Shell
# $Author:       elsas.liu
# $Create Date:  2018-11-17 09:30
# $Description:  vinput_monkey_lib.sh
#######################################################


function rand(){
        min=$1
        max=$(($2-$min+1))
        num=$(($RANDOM + 10000))
        echo $(($num%$max+$min))
    }

function generate_seed(){
    rnd=$(rand $1 $2)
    echo ${rnd#-}
}

function keyevent_monkey_test(){
    dbugFile="/data/vinput_monkey.txt"

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

    echo "----------keyevent monkey test start-----------"
    loop_old=$1
    loop_int=${loop_old%.*}
    loop=${loop_old%.*}

    # remove dbug test file
    echo $dbugFile
    if [ -f "$dbugFile" ]
    then
        echo $dbugFile
        rm -f $dbugFile
        sleep 0.5
    fi

    # begin vinput daemon
    vinput_daemon &
    sleep 1
    echo "all loop is $loop"
    while [ $loop -gt 0 ]
    do
    rnd=$(rand 100 1600)
    echo -n "${rnd#-} " >> /data/vinput_monkey.txt
    # echo $rnd
    case ${rnd#-} in
        1[0-9][0-9])
            vinput2 keyevent full_press
            full_press_num=$(($full_press_num+1))
            sleep 0.5
            ;;
        2[0-9][0-9])
            vinput2 keyevent half_press
            half_press_num=$(($half_press_num+1))
            ;;
        3[0-9][0-9])
            vinput2 keyevent af
            af_press_num=$(($af_press_num+1))
            ;;
        4[0-9][0-9])
            vinput2 keyevent ios
            iso_press_num=$(($iso_press_num+1))
            ;;
        5[0-9][0-9])
            vinput2 keyevent ae_l
            ae_l_press_num=$(($ae_l_press_num+1))
            ;;
        6[0-9][0-9])
            vinput2 keyevent af_d
            af_d_press_num=$(($af_d_press_num+1))
            ;;
        7[0-9][0-9])
            vinput2 keyevent browse_key
            browse_press_num=$(($browse_press_num+1))
            ;;
        8[0-9][0-9])
            vinput2 keyevent select_key
            select_key_press_num=$(($select_key_press_num+1))
            ;;
        9[0-9][0-9])
            vinput2 keyevent soft_key_1
            soft_key_1_press_num=$(($soft_key_1_press_num+1))
            ;;
        10[0-9][0-9])
            vinput2 keyevent soft_key_2
            soft_key_2_press_num=$(($soft_key_2_press_num+1))
            ;;
        11[0-9][0-9])
            vinput2 keyevent menu_key
            menu_key_press_num=$(($menu_key_press_num+1))
            ;;
        12[0-9][0-9])
            vinput2 keyevent front_wheel_left
            front_wheel_left_num=$(($front_wheel_left_num+1))
            ;;
        13[0-9][0-9])
            vinput2 keyevent front_wheel_right
            front_wheel_right_num=$(($front_wheel_right_num+1))
            ;;
        14[0-9][0-9])
            vinput2 keyevent back_wheel_left
            back_wheel_left_num=$(($back_wheel_left_num+1))
            ;;
        15[0-9][0-9])
            vinput2 keyevent back_wheel_right
            back_wheel_right_num=$(($back_wheel_right_num+1))
            ;;
        *)
            echo "wrong number"
            ;;
    esac
    sleep 0.1
    loop=$(($loop-1))
    # ((loop--))
    done
    echo "------keyevent monkey test end------"
    echo "keyevent: capture button full_press $full_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$full_press_num'/'$loop_int')*100}'`."
    echo "keyevent: capture button half_press $half_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$half_press_num'/'$loop_int')*100}'`."
    echo "keyevent: AF|MF key press $af_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$af_press_num'/'$loop_int')*100}'`."
    echo "keyevent: ae_l key press $ae_l_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$ae_l_press_num'/'$loop_int')*100}'`."
    echo "keyevent: iso|wb key press $iso_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$iso_press_num'/'$loop_int')*100}'`."
    echo "keyevent: af_d key press $af_d_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$af_d_press_num'/'$loop_int')*100}'`."
    echo "keyevent: browse key press $browse_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$browse_press_num'/'$loop_int')*100}'`."
    echo "keyevent: soft_key_1 press $soft_key_1_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$soft_key_1_press_num'/'$loop_int')*100}'`."
    echo "keyevent: soft_key_2 press $soft_key_2_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$soft_key_2_press_num'/'$loop_int')*100}'`."
    echo "keyevent: select key press $select_key_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$select_key_press_num'/'$loop_int')*100}'`."
    echo "keyevent: menu key press $menu_key_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$menu_key_press_num'/'$loop_int')*100}'`."
    echo "keyevent: front wheel turn left $front_wheel_left_num times, `awk 'BEGIN{printf "%.2f%%\n",('$front_wheel_left_num'/'$loop_int')*100}'`."
    echo "keyevent: front wheel turn right $front_wheel_right_num times, `awk 'BEGIN{printf "%.2f%%\n",('$front_wheel_right_num'/'$loop_int')*100}'`."
    echo "keyevent: back wheel turn left $back_wheel_left_num times, `awk 'BEGIN{printf "%.2f%%\n",('$back_wheel_left_num'/'$loop_int')*100}'`."
    echo "keyevent: back wheel turn right $back_wheel_right_num times, `awk 'BEGIN{printf "%.2f%%\n",('$back_wheel_right_num'/'$loop_int')*100}'`."
    echo "-----------------------------------"
    exit 0
}

function monkey_touch_event_test(){
    touch_short_press_num=0
    touch_long_press_num=0
    touch_swap_num=0
    touch_pinch_num=0

    echo "----------touchevent monkey test start-----------"
    loop_old=$1
    loop_int=${loop_old%.*}
    loop=${loop_old%.*}

    # begin vinput daemon
    vinput_daemon &
    sleep 1
    echo "all loop is $loop"
    while [ $loop -gt 0 ]
    do
        # echo $rnd
        rnd_seed=$(rand 100 500)
        seed=${rnd_seed#-}
        case $seed in
        1[0-9][0-9])
            x=$(generate_seed 0 1024)
            y=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_short_press_num=$(($touch_short_press_num+1))
            ;;
        2[0-9][0-9])
            x=$(generate_seed 0 1024)
            y=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_long_press_num=$(($touch_long_press_num+1))
            ;;
        3[0-9][0-9])
            x1=$(generate_seed 0 1024)
            x2=$(generate_seed 0 1024)
            y1=$(generate_seed 0 768)
            y2=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_swap_num=$(($touch_swap_num+1))
            ;;
        4[0-9][0-9])
            x1=$(generate_seed 0 1024)
            x2=$(generate_seed 0 1024)
            y1=$(generate_seed 0 768)
            y2=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            a=$(generate_seed 0 1)
            vinput2 touch $x $y $z
            touch_pinch_num=$(($touch_pinch_num+1))
            ;;
        *)
            echo "wrong number"
            ;;
    esac
    sleep 0.1
    loop=$(($loop-1))
    done

    echo "------touchevent monkey test end------"
    echo "touchevent: touch short press $touch_short_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_short_press_num'/'$loop_int')*100}'`."
    echo "touchevent: touch long press $touch_long_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_long_press_num'/'$loop_int')*100}'`."
    echo "touchevent: touch swap $touch_swap_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_swap_num'/'$loop_int')*100}'`."
    echo "touchevent: touch pinch $touch_pinch_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_pinch_num'/'$loop_int')*100}'`."
    echo "--------------------------------------"
    exit 0
}

function monkey_all_event_test_lcd(){
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
    touch_short_press_num=0
    touch_long_press_num=0
    touch_swap_num=0
    touch_pinch_num=0

    echo "---------- monkey test start-----------"
    loop_old=$1
    loop_int=${loop_old%.*}
    loop=${loop_old%.*}

    # remove dbug test file
    echo $dbugFile
    if [ -f "$dbugFile" ]
    then
        echo $dbugFile
        rm -f $dbugFile
        sleep 0.5
    fi

    # begin vinput daemon
    vinput_daemon &
    sleep 1
    echo "all loop is $loop"
    while [ $loop -gt 0 ]
    do
    rnd=$(rand 100 2000)
    echo -n "${rnd#-} " >> /data/vinput_monkey.txt
    # echo $rnd
    case ${rnd#-} in
        1[0-9][0-9])
            vinput2 keyevent full_press
            full_press_num=$(($full_press_num+1))
            sleep 0.5
            ;;
        2[0-9][0-9])
            vinput2 keyevent half_press
            half_press_num=$(($half_press_num+1))
            ;;
        3[0-9][0-9])
            vinput2 keyevent af
            af_press_num=$(($af_press_num+1))
            ;;
        4[0-9][0-9])
            vinput2 keyevent ios
            iso_press_num=$(($iso_press_num+1))
            ;;
        5[0-9][0-9])
            vinput2 keyevent ae_l
            ae_l_press_num=$(($ae_l_press_num+1))
            ;;
        6[0-9][0-9])
            vinput2 keyevent af_d
            af_d_press_num=$(($af_d_press_num+1))
            ;;
        7[0-9][0-9])
            vinput2 keyevent browse_key
            browse_press_num=$(($browse_press_num+1))
            ;;
        8[0-9][0-9])
            vinput2 keyevent select_key
            select_key_press_num=$(($select_key_press_num+1))
            ;;
        9[0-9][0-9])
            vinput2 keyevent soft_key_1
            soft_key_1_press_num=$(($soft_key_1_press_num+1))
            ;;
        10[0-9][0-9])
            vinput2 keyevent soft_key_2
            soft_key_2_press_num=$(($soft_key_2_press_num+1))
            ;;
        11[0-9][0-9])
            vinput2 keyevent menu_key
            menu_key_press_num=$(($menu_key_press_num+1))
            ;;
        12[0-9][0-9])
            vinput2 keyevent front_wheel_left
            front_wheel_left_num=$(($front_wheel_left_num+1))
            ;;
        13[0-9][0-9])
            vinput2 keyevent front_wheel_right
            front_wheel_right_num=$(($front_wheel_right_num+1))
            ;;
        14[0-9][0-9])
            vinput2 keyevent back_wheel_left
            back_wheel_left_num=$(($back_wheel_left_num+1))
            ;;
        15[0-9][0-9])
            vinput2 keyevent back_wheel_right
            back_wheel_right_num=$(($back_wheel_right_num+1))
            ;;
        16[0-9][0-9])
            x=$(generate_seed 0 1024)
            y=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_short_press_num=$(($touch_short_press_num+1))
            ;;
        17[0-9][0-9])
            x=$(generate_seed 0 1024)
            y=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_long_press_num=$(($touch_long_press_num+1))
            ;;
        18[0-9][0-9])
            x1=$(generate_seed 0 1024)
            x2=$(generate_seed 0 1024)
            y1=$(generate_seed 0 768)
            y2=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_swap_num=$(($touch_swap_num+1))
            ;;
        19[0-9][0-9])
            x1=$(generate_seed 0 1024)
            x2=$(generate_seed 0 1024)
            y1=$(generate_seed 0 768)
            y2=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            a=$(generate_seed 0 1)
            vinput2 touch $x $y $z
            touch_pinch_num=$(($touch_pinch_num+1))
            ;;
        *)
            echo "wrong number"
            ;;
    esac
    sleep 0.1
    loop=$(($loop-1))
    # ((loop--))
    done
    odindb-send -s bodystate -p screens_active 1
    sleep 1
    echo "----------monkey test end-----------"
    echo "keyevent: capture button full_press $full_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$full_press_num'/'$loop_int')*100}'`."
    echo "keyevent: capture button half_press $half_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$half_press_num'/'$loop_int')*100}'`."
    echo "keyevent: AF|MF key press $af_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$af_press_num'/'$loop_int')*100}'`."
    echo "keyevent: ae_l key press $ae_l_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$ae_l_press_num'/'$loop_int')*100}'`."
    echo "keyevent: iso|wb key press $iso_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$iso_press_num'/'$loop_int')*100}'`."
    echo "keyevent: af_d key press $af_d_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$af_d_press_num'/'$loop_int')*100}'`."
    echo "keyevent: browse key press $browse_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$browse_press_num'/'$loop_int')*100}'`."
    echo "keyevent: soft_key_1 press $soft_key_1_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$soft_key_1_press_num'/'$loop_int')*100}'`."
    echo "keyevent: soft_key_2 press $soft_key_2_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$soft_key_2_press_num'/'$loop_int')*100}'`."
    echo "keyevent: select key press $select_key_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$select_key_press_num'/'$loop_int')*100}'`."
    echo "keyevent: menu key press $menu_key_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$menu_key_press_num'/'$loop_int')*100}'`."
    echo "keyevent: front wheel turn left $front_wheel_left_num times, `awk 'BEGIN{printf "%.2f%%\n",('$front_wheel_left_num'/'$loop_int')*100}'`."
    echo "keyevent: front wheel turn right $front_wheel_right_num times, `awk 'BEGIN{printf "%.2f%%\n",('$front_wheel_right_num'/'$loop_int')*100}'`."
    echo "keyevent: back wheel turn left $back_wheel_left_num times, `awk 'BEGIN{printf "%.2f%%\n",('$back_wheel_left_num'/'$loop_int')*100}'`."
    echo "keyevent: back wheel turn right $back_wheel_right_num times, `awk 'BEGIN{printf "%.2f%%\n",('$back_wheel_right_num'/'$loop_int')*100}'`."
    echo "touchevent: touch short press $touch_short_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_short_press_num'/'$loop_int')*100}'`."
    echo "touchevent: touch long press $touch_long_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_long_press_num'/'$loop_int')*100}'`."
    echo "touchevent: touch swap $touch_swap_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_swap_num'/'$loop_int')*100}'`."
    echo "touchevent: touch pinch $touch_pinch_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_pinch_num'/'$loop_int')*100}'`."
    echo "-----------------------------------"
    exit 0
}

function monkey_all_event_test(){
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
    touch_short_press_num=0
    touch_long_press_num=0
    touch_swap_num=0
    touch_pinch_num=0
    lcd_evf_num=0

    echo "---------- monkey test start-----------"
    loop_old=$1
    loop_int=${loop_old%.*}
    loop=${loop_old%.*}

    # remove dbug test file
    echo $dbugFile
    if [ -f "$dbugFile" ]
    then
        echo $dbugFile
        rm -f $dbugFile
        sleep 0.5
    fi

    # begin vinput daemon
    vinput_daemon &
    sleep 1
    echo "all loop is $loop"
    while [ $loop -gt 0 ]
    do
    rnd=$(rand 100 2100)
    echo -n "${rnd#-} " >> /data/vinput_monkey.txt
    # echo $rnd
    case ${rnd#-} in
        1[0-9][0-9])
            vinput2 keyevent full_press
            full_press_num=$(($full_press_num+1))
            sleep 0.5
            ;;
        2[0-9][0-9])
            vinput2 keyevent half_press
            half_press_num=$(($half_press_num+1))
            ;;
        3[0-9][0-9])
            vinput2 keyevent af
            af_press_num=$(($af_press_num+1))
            ;;
        4[0-9][0-9])
            vinput2 keyevent ios
            iso_press_num=$(($iso_press_num+1))
            ;;
        5[0-9][0-9])
            vinput2 keyevent ae_l
            ae_l_press_num=$(($ae_l_press_num+1))
            ;;
        6[0-9][0-9])
            vinput2 keyevent af_d
            af_d_press_num=$(($af_d_press_num+1))
            ;;
        7[0-9][0-9])
            vinput2 keyevent browse_key
            browse_press_num=$(($browse_press_num+1))
            ;;
        8[0-9][0-9])
            vinput2 keyevent select_key
            select_key_press_num=$(($select_key_press_num+1))
            ;;
        9[0-9][0-9])
            vinput2 keyevent soft_key_1
            soft_key_1_press_num=$(($soft_key_1_press_num+1))
            ;;
        10[0-9][0-9])
            vinput2 keyevent soft_key_2
            soft_key_2_press_num=$(($soft_key_2_press_num+1))
            ;;
        11[0-9][0-9])
            vinput2 keyevent menu_key
            menu_key_press_num=$(($menu_key_press_num+1))
            ;;
        12[0-9][0-9])
            vinput2 keyevent front_wheel_left
            front_wheel_left_num=$(($front_wheel_left_num+1))
            ;;
        13[0-9][0-9])
            vinput2 keyevent front_wheel_right
            front_wheel_right_num=$(($front_wheel_right_num+1))
            ;;
        14[0-9][0-9])
            vinput2 keyevent back_wheel_left
            back_wheel_left_num=$(($back_wheel_left_num+1))
            ;;
        15[0-9][0-9])
            vinput2 keyevent back_wheel_right
            back_wheel_right_num=$(($back_wheel_right_num+1))
            ;;
        16[0-9][0-9])
            x=$(generate_seed 0 1024)
            y=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_short_press_num=$(($touch_short_press_num+1))
            ;;
        17[0-9][0-9])
            x=$(generate_seed 0 1024)
            y=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_long_press_num=$(($touch_long_press_num+1))
            ;;
        18[0-9][0-9])
            x1=$(generate_seed 0 1024)
            x2=$(generate_seed 0 1024)
            y1=$(generate_seed 0 768)
            y2=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            vinput2 touch $x $y $z
            touch_swap_num=$(($touch_swap_num+1))
            ;;
        19[0-9][0-9])
            x1=$(generate_seed 0 1024)
            x2=$(generate_seed 0 1024)
            y1=$(generate_seed 0 768)
            y2=$(generate_seed 0 768)
            z=$(generate_seed 0 200)
            a=$(generate_seed 0 1)
            vinput2 touch $x $y $z
            touch_pinch_num=$(($touch_pinch_num+1))
            ;;
        20[0-9][0-9])
            a=$(generate_seed 1 2)
            odindb-send -s bodystate -p screens_active $a
            lcd_evf_num=$(($lcd_evf_num+1))
            if [ $a -eq 1]
            then
                echo "switch to LCD"
            else
                echo "switch to EVF"
            fi
            sleep 0.5
            ;;
        *)
            echo "wrong number"
            ;;
    esac
    sleep 0.1
    loop=$(($loop-1))
    # ((loop--))
    done
    odindb-send -s bodystate -p screens_active 1
    sleep 1
    echo "----------monkey test end-----------"
    echo "keyevent: capture button full_press $full_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$full_press_num'/'$loop_int')*100}'`."
    echo "keyevent: capture button half_press $half_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$half_press_num'/'$loop_int')*100}'`."
    echo "keyevent: AF|MF key press $af_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$af_press_num'/'$loop_int')*100}'`."
    echo "keyevent: ae_l key press $ae_l_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$ae_l_press_num'/'$loop_int')*100}'`."
    echo "keyevent: iso|wb key press $iso_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$iso_press_num'/'$loop_int')*100}'`."
    echo "keyevent: af_d key press $af_d_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$af_d_press_num'/'$loop_int')*100}'`."
    echo "keyevent: browse key press $browse_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$browse_press_num'/'$loop_int')*100}'`."
    echo "keyevent: soft_key_1 press $soft_key_1_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$soft_key_1_press_num'/'$loop_int')*100}'`."
    echo "keyevent: soft_key_2 press $soft_key_2_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$soft_key_2_press_num'/'$loop_int')*100}'`."
    echo "keyevent: select key press $select_key_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$select_key_press_num'/'$loop_int')*100}'`."
    echo "keyevent: menu key press $menu_key_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$menu_key_press_num'/'$loop_int')*100}'`."
    echo "keyevent: front wheel turn left $front_wheel_left_num times, `awk 'BEGIN{printf "%.2f%%\n",('$front_wheel_left_num'/'$loop_int')*100}'`."
    echo "keyevent: front wheel turn right $front_wheel_right_num times, `awk 'BEGIN{printf "%.2f%%\n",('$front_wheel_right_num'/'$loop_int')*100}'`."
    echo "keyevent: back wheel turn left $back_wheel_left_num times, `awk 'BEGIN{printf "%.2f%%\n",('$back_wheel_left_num'/'$loop_int')*100}'`."
    echo "keyevent: back wheel turn right $back_wheel_right_num times, `awk 'BEGIN{printf "%.2f%%\n",('$back_wheel_right_num'/'$loop_int')*100}'`."
    echo "touchevent: touch short press $touch_short_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_short_press_num'/'$loop_int')*100}'`."
    echo "touchevent: touch long press $touch_long_press_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_long_press_num'/'$loop_int')*100}'`."
    echo "touchevent: touch swap $touch_swap_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_swap_num'/'$loop_int')*100}'`."
    echo "touchevent: touch pinch $touch_pinch_num times, `awk 'BEGIN{printf "%.2f%%\n",('$touch_pinch_num'/'$loop_int')*100}'`."
    echo "evf<->lcd: switch evf and lcd $lcd_evf_num times, `awk 'BEGIN{printf "%.2f%%\n",('$lcd_evf_num'/'$loop_int')*100}'`."
    echo "-----------------------------------"
    exit 0
}
