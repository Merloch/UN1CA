# Disable TouchWizHome updates
DECODE_APK "system" "system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk"
LOG "- Parcheando versionCode en TouchWizHome_2017.apk"
EVAL "sed -i \"s/1701105117/999999999/g\" \"$APKTOOL_DIR/system/priv-app/TouchWizHome_2017/TouchWizHome_2017.apk/apktool.yml\""
# ]
LOG_STEP_OUT
