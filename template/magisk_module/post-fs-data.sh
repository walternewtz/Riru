#!/system/bin/sh
MODDIR=${0%/*}
TMPPROP="$(magisk --path)/riru.prop"
MIRRORPROP="$(magisk --path)/.magisk/modules/riru-core/module.prop"

ORIG_NB="$(getprop ro.dalvik.vm.native.bridge)"

if [ -f "/system/lib/libnb.so" ]; then
    rm -rf "$MODDIR/system/lib/libnb.so"
    rm -rf "$MODDIR/system.prop"
    ln -s ./libriruloader.so "$MODDIR/system/lib/libnb.so"
    touch "$MODDIR/system/lib/libnb.so.bak"
    mount --bind "$(magisk --path)/.magisk/mirror/system/lib/libnb.so" "$(magisk --path)/.magisk/modules/riru-core/system/lib/libnb.so.bak"
    resetprop -n "ro.dalvik.vm.native.bridge" "libnb.so.bak"
    ORIG_NB="libnb.so.bak"
fi 
if [ -f "/system/lib64/libnb.so" ]; then
    rm -rf "$MODDIR/system/lib64/libnb.so"
    rm -rf "$MODDIR/system.prop"
    ln -s ./libriruloader.so "$MODDIR/system/lib64/libnb.so"
    touch "$MODDIR/system/lib64/libnb.so.bak"
    mount --bind "$(magisk --path)/.magisk/mirror/system/lib64/libnb.so" "$(magisk --path)/.magisk/modules/riru-core/system/lib64/libnb.so.bak"
    resetprop -n "ro.dalvik.vm.native.bridge" "libnb.so.bak"
    ORIG_NB="libnb.so.bak"
fi


sh -Cc "cat '$MODDIR/module.prop' > '$TMPPROP'"
if [ $? -ne 0 ]; then
  exit
fi
mount --bind "$TMPPROP" "$MIRRORPROP"
if [ "$ZYGISK_ENABLE" = "1" ]; then
    sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ Riru is not loaded because of Zygisk. ] /g' "$MIRRORPROP"
    exit
fi
sed -Ei 's/^description=(\[.*][[:space:]]*)?/description=[ ⛔ app_process fails to run. ] /g' "$MIRRORPROP"
cd "$MODDIR" || exit
flock "module.prop"
mount --bind "$TMPPROP" "$MODDIR/module.prop"
unshare -m sh -c "/system/bin/app_process -Djava.class.path=rirud.apk /system/bin --nice-name=rirud riru.Daemon $(magisk -V) $(magisk --path) $ORIG_NB &"
umount "$MODDIR/module.prop"
