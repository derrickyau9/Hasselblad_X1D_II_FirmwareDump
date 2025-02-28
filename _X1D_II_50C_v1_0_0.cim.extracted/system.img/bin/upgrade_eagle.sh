#!/system/bin/sh
#
# Usage: upgrade_eagle.sh
#
# Usage:
# need to push ota.zip to /cache/ first
update_engine --update_package=/cache/ota.zip
exit $?
