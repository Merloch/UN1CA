# Close the vendor's boot-time USB gadget race so the computer detects ADB on boot
# without manually toggling USB debugging.
#
# On r8q the stock vendor (init.qcom.usb.rc) only writes the gadget UDC when
# sys.usb.ffs.ready=1 coincides with sys.usb.config=sec_charging,adb. At boot these two
# don't line up, so the gadget is never enabled and the computer sees nothing until the
# config is cycled (exactly what toggling USB debugging does). Re-run that transition once
# at boot, ending at the device's own persisted config (sec_charging,adb) - no MTP, and
# not a bare "adb" override.

MARKER="# usbadb: fix boot-time USB gadget race"
if [ -f "$WORK_DIR/system/system/etc/init/hw/init.usb.rc" ]; then
    if ! grep -q "$MARKER" "$WORK_DIR/system/system/etc/init/hw/init.usb.rc"; then
        {
            echo ""
            echo "$MARKER"
            echo "on property:sys.boot_completed=1"
            echo "    setprop sys.usb.config none"
            echo "    setprop sys.usb.config \${persist.sys.usb.config}"
        } >> "$WORK_DIR/system/system/etc/init/hw/init.usb.rc"
    fi
fi
