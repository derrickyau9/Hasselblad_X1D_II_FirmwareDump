#########################################################################
# File Name: start_ftp_server.sh
# Author: Holmes.Xie
# mail: holmes.xie@dji.com
# Created Time: Mon 04 Jun 2018 09:45:24 PM CST
#########################################################################
#!/bin/bash

#ifconfig rndis0 172.16.0.32 netmask 255.255.255.0

busybox tcpsvd -vE 0 21 busybox ftpd -w /ftp > /dev/null &

echo "Pass "
sleep 3
exit 0
