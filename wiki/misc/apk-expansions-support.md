---
title: APK 扩展支持
# 不列入目录
---
当游戏资源超过一定大小时，为了在 Google Play 发布游戏，必须将资源放入单独的文件中，以使 APK 大小保持在 100MB 以下。更多信息请阅读[此处](https://developer.android.com/google/play/expansion-files)。

## 如何使用此功能
libGDX 现在内置了检测和读取扩展文件中资源的支持。libGDX 接受的扩展文件格式是未压缩（stored）的 zip 文件。不要使用 Android SDK 提供的 _jobb_ 工具，只需将部分或全部资源从 android/assets 移动到 zip 文件中。通常该文件会由 Google Play 自动下载；但如果要进行测试，则必须手动将文件复制到设备上。

然后，Android 应用必须从 [AndroidFiles](https://github.com/libgdx/libgdx/blob/master/backends/gdx-backend-android/src/com/badlogic/gdx/backends/android/AndroidFiles.java) 调用 `setAPKExpansion()` 函数，如下所示：
`((AndroidFiles)Gdx.files).setAPKExpansion(1, 0)`  
该函数的返回值可用于检查扩展文件是否成功打开。参数分别是 _main_ 文件和 _patch_ 文件的版本号；在 Google Play 上，这些版本号必须与上传这些文件所对应的 APK 版本匹配。

之后可以使用以下方式访问资源：
`Gdx.files.internal("assetname.ext")`  
用法与平时相同。

请注意，对于大量小文件，这种方式可能效率较低，因为 [AndroidFiles](https://github.com/libgdx/libgdx/blob/master/backends/gdx-backend-android/src/com/badlogic/gdx/backends/android/AndroidFiles.java) 会先检查资源中是否存在文件，之后才创建 [AndroidZipFileHandle](https://github.com/libgdx/libgdx/blob/master/backends/gdx-backend-android/src/com/badlogic/gdx/backends/android/AndroidZipFileHandle.java)。如果要优化加载时间，请使用类似 [ZipFileHandleResolver](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests-android/src/com/badlogic/gdx/tests/android/ZipFileHandleResolver.java) 的 FileHandleResolver。
