busybox devmem 0xFD400004 32 0xFFFFFFFF;
busybox devmem 0xFD400014 32 0xFFFFFFFF;
echo 1 > /sys/module/isp_dji/parameters/reprocess_pass
echo 1 > /sys/module/video_tx/parameters/continuous_flag
echo 1 > /sys/module/synopsys_csi2/parameters/hs_trail_enlarge
echo 650000000 > /sys/module/video_tx/parameters/csi_phy_rate
