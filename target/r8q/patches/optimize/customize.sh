# r8q performance / battery optimizations.
# Removes components inherited from the S22 (S901) donor firmware that are
# broken or pure waste on r8q, confirmed live via ADB profiling.

# 1) CameraLightSensor (com.samsung.adaptivebrightnessgo)
#    Uses the FRONT CAMERA as a brightness sensor, opening/closing a camera
#    session every ~5 seconds. This kept the whole camera stack (cameraserver,
#    camera provider HAL, SS_3A) awake at idle - a constant battery drain that
#    also generated ~half of the system log spam and the recurring camera
#    fastRPC/DSP errors. r8q has a real hardware ambient light sensor
#    (stk_stk31610), so auto-brightness keeps working without this.
DELETE_FROM_WORK_DIR "system" "system/priv-app/CameraLightSensor"

# 2) SecureElement (com.android.se)
#    Tries to reach an embedded Secure Element (eSE) that r8q does not have,
#    ANR-looping every ~30-60s (dozens of ANRs). NFC read/write and HCE
#    tap-to-pay (Google Pay / Wallet) do NOT use this service and keep working;
#    only hardware-eSE payments - already non-functional on r8q - are affected.
DELETE_FROM_WORK_DIR "system" "system/app/SecureElement"
