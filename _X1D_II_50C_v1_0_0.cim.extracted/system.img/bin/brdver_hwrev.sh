#get the string that contains hw_version
hw_ver_tmp=$(cat /proc/cmdline | grep 'hw_version=')

#intercept hw_version from the string
hw_ver_tmp=${hw_ver_tmp#*hw_version=}

#get hw_version
hw_ver=${hw_ver_tmp:0:8}

#get the string of pcb
pcb=${hw_ver:3:2}

#convert the string of pcb to number
pcb_num=$((pcb))

#return pcb
exit $pcb_num
