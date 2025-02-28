
cs47l35-dmic-config.sh

if [ $# -ne 2 ]; then
        echo "Usage $0 record_path record_time"
        exit 1
fi

tinycap $1 -r 48000 -b 16 -c 2 -i wav -t $2
