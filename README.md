# MagiskLess-Riru

Fork of the (now deprecated) [Riru](https://github.com/RikkaApps/Riru) Magisk module.

This fork is a version of Riru that does not require Magisk to be installed on the device.

## Requirements

* Android 6.0+ devices

And if you want to use the provided template to install MagiskLess-Riru on the device:
* Permissive 'su' SELinux context (should be present on userdebug builds such as on LineageOS)
* No dm-verity

## Guide

### Install

* Using gradle

  1. Enter recovery mode on your device, and select "Apply update from ADB"
  2. Run the command following:
  ```
  gradle flashRelease
  ```

* Manually

  1. Place the files in a directory of your choice on the device in the following structure:
  ```
  <riru-directory>
  └── riru-core
      ├── system
      │   ├── lib
      │   │   └── libriruloader.so
      │   └── lib64
      │       └── libriruloader.so
      │
      ├── lib
      │   ├── libriru.so
      │   └── libriruhide.so
      │
      ├── lib64
      │   ├── libriru.so
      │   └── libriruhide.so
      │
      └── rirud.apk
  ```
  2. Place the `libriruloader.so` 64 bits and 32 bits versions in the `/system/lib64` and `/system/lib` folders respectively
  3. Set the property `ro.dalvik.vm.native.bridge` to `libriruloader.so` before zygote is launched
  4. Run the following command on startup of the device (replace `<riru-directory>` with your chosen installation directory)
  ```
  /system/bin/app_process -Djava.class.path=<riru-directory>/riru-core/rirud.apk /system/bin --nice-name=rirud riru.Daemon <riru-directory> 0
  ```

## Build

Gradle tasks:

* `zipDebug/Release`

  Build an update package (using the [android-flashable-zip](https://github.com/Alhyoss/android-flashable-zip) template).

* `flashDebug/Release`

  Build an update package (using the [android-flashable-zip](https://github.com/Alhyoss/android-flashable-zip) template) and sideload it to the device.

## Modules

Place the Riru modules in the the same directory as the `riru-core` folder (`/data/riru` by default).

If the module does not use Magisk-specific features, it should work with MagiskLess-Riru.

## Troubleshooting

You may encounter SELinux issues on your device when installing MagiskLess-Riru or a Riru module.

If you are using the provided template, you can inject the required SELinux policies by using the `inject_selinux_policy` util method in the `update.sh` file:
```
inject_selinux_policy -s zygote -t adb_data_file -c dir -p search
```

You can find the required SELinux policies in Logcat:
```
adb logcat | grep avc
```