#!/bin/sh -e

# About
# -----
# This script configures the codec for speaker/headphone

config_speaker_vol() {
    local vol
    vol=$1

    logwrapper echo "Setting speaker volume ${vol}."
    # Workaround:
    # Toggle the digital switch of the speaker before setting volume
    # otherwise the volume is not changed immediately
    tinymix -C 172 0 \
            -C 172 1 \
            -C 175 $vol
}

config_speaker() {
    logwrapper echo "Routing audio through speaker."
    /system/bin/cs47l35-spk-config.sh
}

config_headphone_vol() {
    local vol
    vol=$1

    logwrapper echo "Setting headphone volume ${vol}."
    # HPOUT1 Digital Volume
    tinymix 174 $vol $vol
}

config_headphone() {
    logwrapper echo "Routing audio through headphone jack."
    /system/bin/cs47l35-hpout-config.sh
}

usage() {
    echo "$0 - Configure ec1704 audio mux & volume."
    echo "usage: $0 -o <speaker|headphone> [-v <volume>]"
    echo ""
    echo "Options:"
    echo ""
    echo "    -o <speaker|headphone>      Select audio output."
    echo "    -v <volume>                 Set volume of specified output."
    echo ""
}

main() {
    local mux
    local vol

    while getopts "o:v:" opt; do
        case $opt in
        o)
            mux="${OPTARG}"
            ;;
        v)
            # TODO: Sanitize input
            vol="${OPTARG}"
            ;;
        h)
            usage
            exit 0
            ;;
        \?)
            echo "Invalid option: -${OPTARG}" >&2
            usage
            exit 1
            ;;
        esac
    done

    if [ -z "${mux}" ]; then
        echo "error: select output with -o"
        usage
        exit 1
    fi

    case ${mux} in
        headphone)
            if [ -z "${vol}" ]; then
                config_headphone
            else
                config_headphone_vol ${vol}
            fi
            ;;
        speaker)
            if [ -z "${vol}" ]; then
                config_speaker
            else
                config_speaker_vol ${vol}
            fi
            ;;
        *)
            echo "error: invalid mux ${mux}" >&2
            exit 1
            ;;
    esac
}

main "$@"
