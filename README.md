# MagiskLess-Riru

Fork of the (now deprecated) [Riru](https://github.com/RikkaApps/Riru) Magisk module.

This fork is a version of Riru that does not require Magisk to be installed on the device.

## Requirements

* Android 6.0+ devices

And if you want to use the provided template to install MagiskLess-Riru on the device
* Permissive 'su' SELinux context (should be present on userdebug builds such as on LineageOS)
* No dm-verity

## Guide

### Install

* Using gradle

  1. Enter recovery mode on your device, and select "Apply update from ADB"
  2. Run the command following:
  ```
  gradle riru:flashRelease
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

* `:riru:assembleDebug/Release`

  Generate update package zip to `out`.

* `:riru:flashDebug/Release`

  Build an update package (using the [android-flashable-zip](https://github.com/Alhyoss/android-flashable-zip) template) and sideload it to the device.
