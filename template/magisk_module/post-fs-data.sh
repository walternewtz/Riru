#!/system/bin/sh
MODDIR=${0%/*}
MODULESDIR="$(realpath $MODDIR/..)"
# KernelSU has no tmpfs, just skip
#TMPPROP="$(magisk --path)/riru.prop"
#MIRRORPROP="$(magisk --path)/.magisk/modules/riru-core/module.prop"
MODPROP="$MODDIR/module.prop"
#sh -Cc "cat '$MODDIR/module.prop' > '$TMPPROP'"
#if [ $? -ne 0 ]; then
#  exit
#fi
#mount --bind "$TMPPROP" "$MIRRORPROP"
if [ "$ZYGISK_ENABLE" = "1" ]; then
    sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ Riru is not loaded because of Zygisk. ] /g' "$MIRRORPROP"
    exit
fi

# KernelSU does not support custom sepolicy patches yet
./magiskpolicy --live --apply "$MODDIR/sepolicy.rule"

sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ app_process fails to run. ] /g' "$MIRRORPROP"
cd "$MODDIR" || exit
#flock "module.prop"
#mount --bind "$TMPPROP" "$MODDIR/module.prop"
export PATH="$PATH:$MODDIR"
# Rirud must be startd before ro.dalvik.vm.native.bridge being reset
unshare -m sh -c "/system/bin/app_process -Djava.class.path=rirud.apk /system/bin --nice-name=rirud riru.Daemon 25206 $MODULESDIR $(getprop ro.dalvik.vm.native.bridge)&"
#umount "$MODDIR/module.prop"

# post-fs-data phase, REMOVING THE -n FLAG MAY CAUSE DEADLOCK!
./resetprop -n --file "$MODDIR/system.prop"
