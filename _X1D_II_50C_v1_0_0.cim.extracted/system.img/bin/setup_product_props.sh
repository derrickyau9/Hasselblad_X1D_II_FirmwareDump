#!/system/bin/sh

#Use default if unrd is empty, should only happen during production.
setprop hbl.suserial "123456789ABCDEF"

unrd | busybox awk -v type_x1dm2=12 -v type_cfv=14 ' /HW_VER|suserial/ {
    split($0, a);
    if(a[1] == "suserial") {
        system("setprop hbl.suserial " a[2]);
    }
    if(a[1] == "HW_VER") {
        split(a[2], v, "\.");
        system("setprop dji.prod_type " int(v[1]) " && setprop dji.hw_rev " int(v[2]) " && setprop dji.ddr_type " int(v[3]));
        if(int(v[1]) == type_x1dm2) {
            system("setprop hbl.usb_pid 0x0007 && setprop hbl.usb_prod_name \"X1D II 50C\"");
        }
        else if(int(v[1]) == type_cfv) {
            system("setprop hbl.usb_pid 0x0008 && setprop hbl.usb_prod_name \"CFV II 50C\"");
        }
    }
}'
