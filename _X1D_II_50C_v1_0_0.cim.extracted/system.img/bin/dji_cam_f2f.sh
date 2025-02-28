#!/system/bin/sh

function gen_vsensor_sp {
	width=$1
	height=$2
    liveview_height=960
	echo '{'
	echo '   "stream_profile": {'
	echo '       "name": "vsensor",'
	echo '       "stream_groups": ['
	echo '           {'
	echo '               "id": "still_f2f",'
	echo '               "shooter_id": "still-general",'
	echo '               "shooter_param": "res=full;",'
	echo '               "still_process_pipe": ['
	echo '                   {'
	echo '                       "id": "main_pipe",'
	echo '                       "nodes": ['
	echo '                          {'
	echo '                            "id": "input",'
	echo '                            "param": ""'
	echo '                          }'
	echo '                       ]'
	echo '                   },'
	echo '                   {'
	echo '                       "id":"hdr_pipe",'
	echo '                       "nodes": ['
	echo '                           {'
	echo '                               "id": "input",'
	echo '                               "param": ""'
	echo '                           }'
	echo '                       ]'
	echo '                   }'
	echo '               ],'
	echo '               "sensor_fps": "DCAM_FPS_2997",'
	if [[ "$width" > "8192" || "$height_int" > "8192" ]]; then
	    echo '               "main_jpeg_encoder": "plat_imgtec_rst",'
	fi
	echo '               "streams" : ['
	echo '                    {'
	echo '                       "id" : "liveview",'
	echo '                       "type": "DCAM_STREAM_TYPE_COMMON",'
	echo '                       "usage": "DCAM_STREAM_USAGE_LIVEVIEW",'
	echo '                       "behavior": "DCAM_STREAM_BEHAVIOR_REPEATING",'
	echo '                       "format": "DUSS_PIXFMT_YUV8_SP422_YUV",'
	echo '                       "fps": "DCAM_FPS_2997",'
	echo '                       "width": 1280,'
	echo '                       "height": '"$liveview_height,"
	echo '                       "width_alignment": 128,'
	echo '                       "height_alignment": 1,'
	echo '                       "buffer_nr": 5'
	echo '                    },'
	echo '                    {'
	echo '                       "id" : "still_yuv",'
	echo '                       "type": "DCAM_STREAM_TYPE_COMMON",'
	echo '                       "usage": "DCAM_STREAM_USAGE_STILL",'
	echo '                       "behavior": "DCAM_STREAM_BEHAVIOR_PERREQUEST",'
	echo '                       "format": "DUSS_PIXFMT_YUV8_SP422_YUV",'
	echo '                       "width": '"$width,"
	echo '                       "height": '"$height,"
	echo '                       "width_alignment": 128,'
	echo '                       "height_alignment": 1,'
	echo '                       "buffer_nr": 2'
	echo '                    }'
	echo '               ]'
	echo '           }'
	echo '       ]'
	echo '   }'
	echo '}'
}

function show_help {
    echo "========================================================="
    echo "Usage:"
    echo "$0 <raw file> -i -f -awb -ae"
    echo '   <raw file>: the file path of the raw file. <raw file>.txt file should be existing as well.'
    echo '   -i: interactive mode.'
    echo '   -f: force the log to console.'
    echo '   -awb: using awb instead of hardcoded gains in raw info file.'
    echo '   -ae: using AE mode instead of manual exposure mode.'
    echo ''
    echo "Example: $0 /data/my.raw"
    echo "========================================================"
}

function check_raw_file {
    if [ -z "$1" ]; then
        echo 'raw file is not specified.'
        show_help
        exit 1
    fi
    
    if [ ! -f $1 ]; then
        echo "raw file:$1 doesn't exist."
        exit 1
    fi
}

function check_raw_info_file {
    if [ ! -f $1 ]; then
        echo "raw info file:$1 doesn't exist."
        exit 1
    fi
}

function check_width {
    if [ -z "$1" ]; then
        echo 'Width is not specified.'
        show_help
        exit 1
    fi   
}

function check_height {
    if [ -z "$1" ]; then
        echo 'height is not specified.'
        show_help
        exit 1
    fi   
}

function check_cfa_pattern {
   if [ -z "$1" ]; then
        echo 'cfa_pattern is not specified.'
        show_help
        exit 1
   fi
   case "$1" in
        "rggb") ;;
        "grbg") ;;
        "gbrg") ;;
        "bggr") ;;
        *)
          echo "Invalid cfa_pattern:$1"
          show_help
          exit 1
	;;
   esac
}

function check_bitdepth {
    if [ -z "$1" ]; then
       echo 'bit_depth is not specified.'
       show_help
       exit 1
    fi
    case "$1" in
       "10") ;;
       "12") ;;
       *)
         echo "Invalid bit_depth is specified:$1."
         show_help
         exit 1
	;;
   esac
}

RAW_FILE=$1
RAW_FILE_CAP=$2
WIDTH=
HEIGHT=
CFA_PATTERN=
BITDEPTH=
WB_GAINS=
EXPO_INFO=
OTHER_FLAGS=
USING_AWB=
USING_AE=

if [[ -f $RAW_FILE_CAP ]]; then
shift
fi

shift
until [ $# -eq 0 ]
do
case "$1" in
    "-i")
    OTHER_FLAGS="$OTHER_FLAGS -i"
    ;;
    "-f")
    OTHER_FLAGS="$OTHER_FLAGS -f"
    ;;
    "-awb")
    USING_AWB=1
    ;;
    "-ae")
    USING_AE=1
    ;;
    "-h")
    show_help
    exit 0
    ;;
    *)
    echo "Invalid parameter:$1"
    show_help
    exit 1
    ;;
esac
shift
done

check_raw_file $RAW_FILE
check_raw_info_file $RAW_FILE.txt

if [[ -z "$RAW_FILE_CAP" || ! -f $RAW_FILE_CAP ]]; then
    echo "source raw file for capture not exist, use $RAW_FILE as capture source"
    RAW_FILE_CAP=$RAW_FILE
fi

while read LINE
do
   if [[ $LINE == *"res_liveview:"* ]]; then
       RES=${LINE#*res_liveview:*}
       TMP=( $RES )
       WIDTH=${TMP[0]}
       WIDTH=${WIDTH//[[:blank:]]/}

       HEIGHT=${TMP[1]}
       HEIGHT=${HEIGHT//[[:blank:]]/}
   fi

   if [[ $LINE == *"res_capture:"* ]]; then
       RES=${LINE#*res_capture:*}
       TMP=( $RES )
       WIDTH_CAP=${TMP[0]}
       WIDTH_CAP=${WIDTH_CAP//[[:blank:]]/}

       HEIGHT_CAP=${TMP[1]}
       HEIGHT_CAP=${HEIGHT_CAP//[[:blank:]]/}
   fi


   if [[ $LINE == *"bitdepth:"* ]]; then
       BITDEPTH=${LINE#*bitdepth:*}
       BITDEPTH=${BITDEPTH//[[:blank:]]/}
   fi

   if [[ $LINE == *"cfa:"* ]]; then
       CFA_PATTERN=${LINE#*cfa:*}
       CFA_PATTERN=${CFA_PATTERN//[[:blank:]]/}
   fi

   if [[ $LINE == *"wb_gains:"* ]]; then
       WB_GAINS=${LINE#*wb_gains:*}
   fi

   if [[ $LINE == *"expo_info:"* ]]; then
       EXPO_INFO=${LINE#*expo_info:*}
   fi
done < $RAW_FILE.txt

check_width $WIDTH
check_height $HEIGHT
check_width $WIDTH_CAP
check_height $HEIGHT_CAP
check_cfa_pattern $CFA_PATTERN
check_bitdepth $BITDEPTH

if [ $USING_AWB ]; then
    WB_GAINS=
fi

if [ $USING_AE ]; then
    EXPO_INFO=
fi

mkdir -p /data/dcam

ln -s -f `readlink -f $RAW_FILE`        /data/dcam/vsensor_source_liveview.raw
ln -s -f `readlink -f $RAW_FILE_CAP`    /data/dcam/vsensor_source_capture.raw
if [ $? -ne 0 ]; then
    echo 'creating vsensor_source_*.raw failed.'
    exit 1
fi

gen_vsensor_sp $WIDTH_CAP $HEIGHT_CAP > /data/dcam/vsensor.sp
if [ $? -ne 0 ]; then
    echo 'creating vsensor.sp failed.'
    exit 1
fi

export DCAM_VSENSOR="w=$WIDTH;h=$HEIGHT;w_c=$WIDTH_CAP;h_c=$HEIGHT_CAP;o=$CFA_PATTERN;b=$BITDEPTH;"; export DCAM_EXPO_INFO="$EXPO_INFO"; export DCAM_WB_GAINS="$WB_GAINS"; dji_cht -c still_f2f -d 4 $OTHER_FLAGS
