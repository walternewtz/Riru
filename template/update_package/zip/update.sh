#!/sbin/sh

######## Preparation ##########

ui_print "Mounting partitions..."

mount_partitions

# Create riru directory
RIRUDIR=/system_root@RIRU_PATH@/riru-core
FILESDIR=$INSTALLDIR/files

mkdir -p $RIRUDIR

set_metadata_recursive $RIRUDIR selabel "u:object_r:system_file:s0"

add_file() {
  FROM=$1
  TO=$2

  cp $FROM $TO
  set_metadata $TO uid root guid root mode 644 selabel "u:object_r:system_file:s0"
}

# we place all the files in the correct directories: /riru/riru-core, /riru/riru-core/lib[64],
# /riru/riru-core/system/lib[64] and /system/lib[64]
mkdir -p $RIRUDIR/lib
mkdir -p $RIRUDIR/lib64
mkdir -p $RIRUDIR/system/lib
mkdir -p $RIRUDIR/system/lib64

add_file $FILESDIR/lib/armeabi-v7a/libriru.so $RIRUDIR/lib/libriru.so
add_file $FILESDIR/lib/arm64-v8a/libriru.so $RIRUDIR/lib64/libriru.so
add_file $FILESDIR/lib/armeabi-v7a/libriruhide.so $RIRUDIR/lib/libriruhide.so
add_file $FILESDIR/lib/arm64-v8a/libriruhide.so $RIRUDIR/lib64/libriruhide.so
add_file $FILESDIR/lib/armeabi-v7a/libriruloader.so $RIRUDIR/system/lib/libriruloader.so
add_file $FILESDIR/lib/arm64-v8a/libriruloader.so $RIRUDIR/system/lib64/libriruloader.so
add_file $FILESDIR/lib/armeabi-v7a/libriruloader.so /system/lib/libriruloader.so
add_file $FILESDIR/lib/arm64-v8a/libriruloader.so /system/lib64/libriruloader.so
add_file $FILESDIR/rirud.apk $RIRUDIR/rirud.apk
add_file $FILESDIR/rirud_launcher.rc /system/etc/init/rirud_launcher.rc

# Needed to modify the ro.dalvik.vm.native.bridge property
mv $FILESDIR/resetprop /system/bin/
chmod 755 /system/bin/resetprop