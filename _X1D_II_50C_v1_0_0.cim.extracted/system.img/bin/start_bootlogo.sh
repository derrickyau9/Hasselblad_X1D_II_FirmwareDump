#!/system/bin/sh

## this file is used for bootlogo to notify compositor that we're done.
## and start compositor service will set sys.bootlogo.ctl=1 to let bootlogo exit.
## for boot up, this file and property currently not exist.
## this is case for restart bootlogo service.
if [ -f /tmp/.bootlogo_complete ]; then
rm -f /tmp/.bootlogo_complete
setprop sys.bootlogo.ctl ""
fi

/system/bin/bootlogo
