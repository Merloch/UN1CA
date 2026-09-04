# r8q performance / battery optimizations, confirmed live via ADB profiling.
# Implemented as a mod (last apply stage) so the deletions survive the legacy
# patch (which re-adds CameraLightSensor) and run after the eSE patch.
if [ "$TARGET_CODENAME" != "r8q" ]; then
    LOG "\033[0;33m! Not r8q. Skipping\033[0m"
    return 0
fi

# 1) CameraLightSensor (com.samsung.adaptivebrightnessgo)
#    Uses the FRONT CAMERA as a brightness sensor, opening/closing a camera
#    session every ~5s and keeping the whole camera stack awake at idle - a
#    constant battery drain that also produced ~half of the idle log spam.
#    r8q has a real hardware ambient light sensor (stk_stk31610), so auto-
#    brightness keeps working without it.
DELETE_FROM_WORK_DIR "system" "system/priv-app/CameraLightSensor"
DELETE_FROM_WORK_DIR "system" "system/etc/permissions/privapp-permissions-com.samsung.adaptivebrightnessgo.cameralightsensor.xml"

# 2) SecureElement (com.android.se)
#    Tries to reach an embedded Secure Element (eSE) that r8q does not have,
#    ANR-looping every ~30-60s. NFC read/write and HCE tap-to-pay (Google
#    Pay/Wallet) do NOT use this service and keep working; only hardware-eSE
#    payments - already non-functional on r8q - are affected.
DELETE_FROM_WORK_DIR "system" "system/app/SecureElement"

# 3) Silence constant DEBUG/INFO log spam from the auto-brightness / sensor
#    pipeline (and a few other chatty tags). At idle these logged ~80 lines/sec
#    for no benefit, keeping logd busy. Only their logging is muted; the
#    features behave identically.
#    cutils-trace, SecVibrator, npu_user_driver, KeyguardFingerPrintSwipe and
#    AF_DEBUG all log successful or expected operations at error level.
for _TAG in BrightnessHandler SecBrightnessController SehLight SSC_DAEMON \
        sensors-hal MotionRecognitionService SemWifiTrafficPoller QuickPanelLog \
        cutils-trace SecVibrator-HAL-AIDL-CORE SecVibrator-HAL-AIDL-EXT \
        npu_user_driver KeyguardFingerPrintSwipe AF_DEBUG; do
    SET_PROP "system" "persist.log.tag.$_TAG" "S"
done
unset _TAG

# 4) Camera vendor keys the r8q HAL does not expose
#    The donor (S22) camera app reads samsung.android.control.textDetectionInfo,
#    nightModeSuggestion and nightIconState off every capture result. The r8q
#    HAL registers none of them, so SemCaptureResult.a() threw, built a stack
#    trace and logged 90 times a second (3 keys x 30fps) for as long as the
#    camera was open. Patch it to remember the keys that failed. The features
#    behind those tags cannot work on r8q either way.
APPLY_PATCH "system" "system/priv-app/SamsungCamera/SamsungCamera.apk" \
    "$MODPATH/SamsungCamera.apk/0001-Cache-unsupported-vendor-keys.patch"
#    Same for the request side (initialZoomRatio, externalLensType,
#    externalDeviceConnected): ~55 exceptions per session/mode change.
APPLY_PATCH "system" "system/priv-app/SamsungCamera/SamsungCamera.apk" \
    "$MODPATH/SamsungCamera.apk/0002-Cache-unsupported-vendor-keys-in-requests.patch"

# 5) Stock r8q tunables the donor system drops (see system/etc/init/r8q_optimize.rc,
#    shipped automatically from this mod's system/ tree): 512 kB read-ahead on
#    the dynamic partitions and the 30% midground CPU cap.

# 6) Let the AOSP cached-app freezer handle user apps.
#    Samsung's CachedAppOptimizer asks FreecessController.freezeTargetProcess()
#    before scheduling a freeze, and that only says yes for core uids
#    (< 10000): user apps are reserved for Freecess, Samsung's own freezer,
#    which needs a kernel module (KernelSupport: N here) and stays disabled.
#    Net effect measured on r8q: system-uid apps freeze fine, user apps never
#    do (0 of 50 after 60 s idle) and keep burning CPU in cache. Make the gate
#    answer yes for everyone so the stock AOSP freezer - already proven to work
#    on this kernel via cgroup.freeze - covers user apps too.
SMALI_PATCH "system" "system/framework/services.jar" \
    "smali/com/android/server/am/FreecessController.smali" "replace" \
    'freezeTargetProcess(ILjava/lang/String;)Z' \
    'const/4 p0, 0x0' \
    'const/4 p0, 0x1'
