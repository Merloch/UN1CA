SEPOLICY="$WORK_DIR/system/system/etc/selinux/plat_sepolicy.cil"
sed -i \
    -e "/^(typeattributeset exec_type\b/ s/))/voipvol_exec ))/" \
    -e "/^(typeattributeset file_type\b/ s/))/voipvol_exec ))/" \
    -e "/^(typeattributeset system_file_type\b/ s/))/voipvol_exec ))/" \
    -e "/^(typeattributeset domain\b/ s/))/voipvol ))/" \
    "$SEPOLICY"
cat >> "$SEPOLICY" <<EOF
; Added by unica/mods/voipvolfix
(type voipvol)
(roletype object_r voipvol)
(type voipvol_exec)
(roletype object_r voipvol_exec)
(typepermissive voipvol)
(typetransition init voipvol_exec process voipvol)
(allow init voipvol (process (transition)))
(allow init voipvol (process (noatsecure rlimitinh siginh)))
(allow init voipvol (fd (use)))
(allow init voipvol_exec (file (read open execute getattr map)))
(allow voipvol voipvol_exec (file (entrypoint read open execute getattr map)))
(allow voipvol shell_exec (file (read open execute getattr map execute_no_trans)))
(allow voipvol system_file (file (read open execute getattr map execute_no_trans)))
(allow voipvol toolbox_exec (file (read open execute getattr map execute_no_trans)))
EOF
