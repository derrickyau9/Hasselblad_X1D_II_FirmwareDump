#########################################################################
# File Name: check_system_status.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Tue 04 Dec 2018 10:49:51 PM CST
#########################################################################
#!/sbin/sh

function check_system_status()
{
	dmesg > /data/dji/dmesg.log
	if [ $? -ne 0 ]; then
		echo "Now,system is in recovery status"
		return 1
	else
		grep "/recovery not specified in fstab" /data/dji/dmesg.log
		if [ $? -ne 0 ]; then
			echo "Now,system is in recovery status"
			return 2
		else
			echo "Now,system is in normal status"
			rm -f /data/dji/dmesg.log
			return 0
		fi
	fi
}

check_system_status
exit $?
