#!/system/bin/sh
# Map the HAL voip volume index (0..8, logged as "Setting voip volume index: N")
# to the WSA smart-amp "Digital PCM Volume" (the node this audio path actually uses;
# the kernel Voip Rx Gain only applies to the ADSP CVS session app-VoIP bypasses).
# Index is inverted vs the slider on r8q. Only acts while a call is active.
FULL=817; FLOOR=560; STEPS=8
while true; do
  logcat -v raw -s compress_voip:D 2>/dev/null | while read -r line; do
    case "$line" in
      *"Setting voip volume index: "*)
        idx=${line##*: }
        case "$idx" in
          [0-8])
            cur=$(tinymix "Left Digital PCM Volume" 2>/dev/null | tail -1)
            case "$cur" in
              *"Digital PCM Volume"*)
                inv=$(( STEPS - idx ))
                v=$(( FLOOR + (FULL-FLOOR)*inv/STEPS ))
                tinymix "Left Digital PCM Volume" $v >/dev/null 2>&1
                tinymix "Right Digital PCM Volume" $v >/dev/null 2>&1 ;;
            esac ;;
        esac ;;
    esac
  done
  sleep 3
done
