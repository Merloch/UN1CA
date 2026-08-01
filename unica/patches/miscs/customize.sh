SET_PROP_IF_DIFF "vendor" "ro.oem_unlock_supported" "0"

# Better device/model detection in CoreRune
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/rune/CoreRune.smali" "replace" \
    '<clinit>()V' \
    'ro.product.model' \
    'ro.product.vendor.model'
SMALI_PATCH "system" "system/framework/framework.jar" \
    "smali_classes6/com/samsung/android/rune/CoreRune.smali" "replace" \
    '<clinit>()V' \
    'ro.product.device' \
    'ro.product.vendor.device'

# shellcheck disable=SC2016
# Disable RescueParty
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/RescueParty.smali" "return" \
    '-$$Nest$smisDisabled()Z' \
    'true'

# Better model detection in FreecessController
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/am/FreecessController.smali" "replace" \
    '<clinit>()V' \
    'ro.product.model' \
    'ro.product.vendor.model'
    
# Set custom Display ID prop
STOCK_PROP="$(GET_PROP "system" "ro.build.display.id")"
CUSTOM_PROP="UN1CA $(echo -n ${ROM_VERSION} | cut -d "-" -f1)-${ROM_CODENAME} - ${TARGET_CODENAME} [${STOCK_PROP}]"
SET_PROP "system" "ro.build.display.id" "$CUSTOM_PROP"

# Crok's RAM Managment Fix
# https://github.com/crok/crokrammgmtfix/blob/master/service.sh#L27-L32
[ -f "$WORK_DIR/system/system/etc/init/ram_mgmt_fix.rc" ] && rm -f "$WORK_DIR/system/system/etc/init/ram_mgmt_fix.rc"
{
    echo "on post-fs-data"
    echo "    exec_background -- /system/bin/cmd device_config set_sync_disabled_for_tests persistent"
    echo "    exec_background -- /system/bin/cmd device_config put activity_manager max_cached_processes 256"
    echo "    exec_background -- /system/bin/cmd device_config put activity_manager max_phantom_processes 2147483647"
    echo "    exec_background -- /system/bin/cmd settings put global settings_enable_monitor_phantom_procs false"
    echo "    exec_background -- /system/bin/cmd device_config put activity_manager max_empty_time_millis 43200000"
    echo "    exec_background -- /system/bin/cmd"
} >> "$WORK_DIR/system/system/etc/init/ram_mgmt_fix.rc"
SET_METADATA "system" "system/etc/init/ram_mgmt_fix.rc" 0 0 644 "u:object_r:system_file:s0"
