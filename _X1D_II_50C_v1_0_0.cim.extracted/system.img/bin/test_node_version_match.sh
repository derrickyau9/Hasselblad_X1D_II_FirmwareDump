#!/system/bin/sh

function check_node_version()
{
   eagle_version=$(getprop dji.build.version)-$(odindb-send --apps-messaging-version | busybox awk ' /apps_messaging_version/ { print $3 } ')
   suc_version=$(odindb-send -s suc -m firmware_version | busybox awk ' /firmware_version/ { print $3 } ')
   farmus_version=$(odindb-send -s farmus -m firmware_version | busybox awk ' /firmware_version/ { print $3 } ')
   spc_version=$(odindb-send -s pwrctrl -m firmware_version 0 | busybox awk ' /firmware_version/ { print $3 } ')

   echo "EAGLE version: $eagle_version"
   echo "SUC version: $suc_version"
   echo "FARM version: $farmus_version"
   echo "SPC version: $spc_version"
   echo

   if [ "$eagle_version" != "$suc_version" ] || [ "$eagle_version" != "$farmus_version" ] || [ "$eagle_version" != "$spc_version" ]; then
      echo "ERROR: NODE VERSIONS ARE NOT THE SAME!"
      exit 1
   fi

   echo "TEST FINISHED WITHOUT ERRORS"
   return 0
}

check_node_version
exit $?
