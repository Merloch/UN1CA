# HDR fix
LOG_STEP_IN "- Adding hdr-fix"
ADD_TO_WORK_DIR "r9qxxx" "system" \
    "lib/libstagefright.so" 0 0 644 "u:object_r:system_file:s0"
LOG_STEP_OUT

# Pro mode EV Fix
LOG_STEP_IN "- Adding camera PRO mode EV-fix"
ADD_TO_WORK_DIR "r9qxxx" "vendor" \
    "lib64/X12QS_libTsAe.so" 0 0 644 "u:object_r:vendor_file:s0"
LOG_STEP_OUT
