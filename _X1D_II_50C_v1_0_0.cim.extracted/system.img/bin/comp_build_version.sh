#!/system/bin/sh
lk_ver_info=`unrd -g dji.build.version`
linux_ver_info=`getprop dji.build.version`
if [ $? != 0 ]; then
	echo "lk_ver_info" $lk_ver_info
	echo "linux_ver_info" $linux_ver_info
	echo "get version failed"
	exit 2
fi

if [ "$lk_ver_info" != "$linux_ver_info" ]; then
	echo "lk_ver_info" $lk_ver_info
	echo "linux_ver_info" $linux_ver_info
	echo "lk_ver and linux_ver compare fail"
	exit 1
fi
echo "lk_ver_info" $lk_ver_info
echo "linux_ver_info" $linux_ver_info

echo "lk_ver and linux_ver compare pass"
exit 0
