#!/system/bin/sh
MODDIR=${0%/*}

MAGIC=$(tr -dc 'a-f0-9' </dev/urandom | head -c 18)
TMP_PATH=/dev/riru_magic_$MAGIC
mkdir "$TMP_PATH"

TMPPROP="$TMP_PATH/riru.prop"
MIRRORPROP="/data/adb/modules/riru-core/module.prop"
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
unshare -m sh -c "/system/bin/app_process -Djava.class.path=rirud.apk /system/bin --nice-name=rirud riru.Daemon $TMP_PATH &"

for libname in riru riruhide riruloader; do
  [ -f "$MODDIR/lib/lib${libname}.so" ] && cp -af "$MODDIR/lib/lib${libname}.so" "$TMP_PATH/${libname}32"
  [ -f "$MODDIR/lib64/lib${libname}.so" ] && cp -af "$MODDIR/lib64/lib${libname}.so" "$TMP_PATH/${libname}64"
done
chmod -R 755 "$TMP_PATH"
chcon -R u:object_r:system_file:s0 "$TMP_PATH"
  
"$MODDIR/riruloader" "$TMP_PATH" &
