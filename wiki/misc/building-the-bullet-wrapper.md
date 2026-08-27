---
title: 构建 Bullet 封装
# 不列入目录，但通过 /dev/contributing/ 链接
---
* [修改封装](#modifying-the-wrapper)
* [构建 Java 模块](#building-the-java-module)
* [编译本机 Bullet 库](#compiling-the-native-bullet-libraries)
* [在 Android 上测试](#testing-on-android)
* [在桌面端测试](#testing-on-desktop)

该 [Bullet 物理库](https://pybullet.org/wordpress/)扩展是 C++ 引擎的 Java 封装，由名为 [SWIG](http://www.swig.org/) 的接口编译器生成。

### 修改封装
修改 `libgdx/extensions/gdx-bullet/jni/swig` 中的 SWIG 接口文件，即可向 Bullet 封装添加新功能或修改现有功能。详情请参阅 SWIG [文档](http://www.swig.org/Doc1.3/Java.html)。

[Bullet 封装自定义类](/wiki/extensions/physics/bullet/bullet-wrapper-custom-classes)应放入 `libgdx/extensions/gdx-bullet/jni/src/custom`，用于添加额外功能。要在 Java 中使用新类，请将其加入 SWIG 接口文件。

### 构建 Java 模块
修改 SWIG 接口文件后，构建 gdx-bullet Java 模块。
```
cd libgdx/extensions/gdx-bullet/jni/swig
ant -f build.xml
```
这会使用 SWIG 接口文件，从 `libgdx/extensions/gdx-bullet/jni/src` 中的 Bullet 源代码生成 Java 类。

如果添加了新的 C++ 源文件，则必须在编译本机 Bullet 代码前更新 `Android.mk` 构建文件。运行 Java 程序 `libgdx/extensions/gdx-bullet/src/com/badlogic/gdx/physics/bullet/BulletBuild.java` 即可完成此操作，工作目录应设为 `libgdx/extensions/gdx-bullet`。

### 编译本机 Bullet 库
构建 SWIG 模块后，可以编译不同架构的本机库。
```
cd libgdx/extensions/gdx-bullet/jni
ant -f build.xml all
```
要检查问题，可以使用 `-v` 标志启用详细输出。为 Android 编译时，必须设置 `NDK_HOME` 环境变量。如果使用 Linux 编译，可能还需要追加选项 `-DndkSuffix="" -Denv.NDK_HOME="/opt/android-ndk"`。

生成的本机二进制文件会放入 `libgdx/extensions/gdx-bullet/libs`。注意，在 libGDX 根目录运行 `ant -f fetch.xml` 会覆盖这些文件。

### 在 Android 上测试
将新的本机库复制到对应的 Android 测试路径：
```
cp libgdx/extensions/gdx-bullet/libs/armeabi-v7a/* libgdx/tests/gdx-tests-android/libs/armeabi-v7a/
cp libgdx/extensions/gdx-bullet/libs/armeabi/* libgdx/tests/gdx-tests-android/libs/armeabi/
cp libgdx/extensions/gdx-bullet/libs/arm64-v8a/*  libgdx/tests/gdx-tests-android/libs/arm64-v8a
cp libgdx/extensions/gdx-bullet/libs/x86/*  libgdx/tests/gdx-tests-android/libs/x86
cp libgdx/extensions/gdx-bullet/libs/x86_64/*  libgdx/tests/gdx-tests-android/libs/x86_64
```
然后构建并运行 Android 测试套件。
```
gradlew tests:gdx-tests-android:installDebug
```
### 在桌面端测试
桌面端测试套件会自动使用新的本机库，可以通过 Gradle wrapper 脚本运行：
```
gradlew tests:gdx-tests-lwjgl
```
