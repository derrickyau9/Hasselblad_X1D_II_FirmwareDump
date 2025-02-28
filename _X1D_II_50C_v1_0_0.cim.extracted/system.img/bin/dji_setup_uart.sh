#!/system/bin/sh

dji_is_production()
{
	cat /proc/cmdline | grep "mp_state=production"
	local production_stat=$?
	return $production_stat
}

dji_is_production

if [ $? -eq 0 ]; then
	busybox devmem 0xf0a41084 32 0x00010001
	busybox devmem 0xf0a41088 32 0x00010007
else
	busybox devmem 0xf0a41084 32 0x00000001
	busybox devmem 0xf0a41088 32 0x00000007
fi
