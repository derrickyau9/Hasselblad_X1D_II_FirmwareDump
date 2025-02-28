#get the string that contains hw_version
hw_ver_tmp=$(cat /proc/cmdline | grep 'hw_version=')

#intercept hw_version from the string
hw_ver_tmp=${hw_ver_tmp#*hw_version=}

#get hw_version
hw_ver=${hw_ver_tmp:0:8}

#get the string of production
production=${hw_ver:0:2}

#convert the string of production to number
production_num=$((production))

#return production
exit $production_num
