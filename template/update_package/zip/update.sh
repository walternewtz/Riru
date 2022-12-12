#!/sbin/sh

# Create riru directory
RIRUDIR=@RIRU_PATH@/riru-core

package_extract_dir files $INSTALLDIR

mkdir -p $RIRUDIR

add_file() {
  FROM=$1
  TO=$2

  cp $FROM $TO
  set_metadata $TO uid root guid root mode 644 selabel "u:object_r:system_file:s0"
}

# we place all the files in the correct directories: /data/riru/riru-core, /data/riru/riru-core/lib[64],
# /data/riru/riru-core/system/lib[64] and /system/lib[64]
mkdir -p $RIRUDIR/lib
mkdir -p $RIRUDIR/lib64
mkdir -p $RIRUDIR/system/lib
mkdir -p $RIRUDIR/system/lib64

set_metadata_recursive $RIRUDIR selabel "u:object_r:system_file:s0"

add_file $INSTALLDIR/lib/$ABI32/libriru.so $RIRUDIR/lib/libriru.so
add_file $INSTALLDIR/lib/$ABI32/libriruhide.so $RIRUDIR/lib/libriruhide.so
add_file $INSTALLDIR/lib/$ABI32/libriruloader.so $RIRUDIR/system/lib/libriruloader.so
add_file $INSTALLDIR/lib/$ABI32/libriruloader.so /system/lib/libriruloader.so

if [ $IS64BIT ]; then
    add_file $INSTALLDIR/lib/$ABI/libriru.so $RIRUDIR/lib64/libriru.so
    add_file $INSTALLDIR/lib/$ABI/libriruhide.so $RIRUDIR/lib64/libriruhide.so
    add_file $INSTALLDIR/lib/$ABI/libriruloader.so $RIRUDIR/system/lib64/libriruloader.so
    add_file $INSTALLDIR/lib/$ABI/libriruloader.so /system/lib64/libriruloader.so
fi

add_file $INSTALLDIR/rirud.apk $RIRUDIR/rirud.apk
add_file $INSTALLDIR/rirud_launcher.rc /system/etc/init/rirud_launcher.rc

# Needed to modify the ro.dalvik.vm.native.bridge property
mv $INSTALLDIR/resetprop /system/bin/
chmod 755 /system/bin/resetprop

ui_print "Riru installed!"