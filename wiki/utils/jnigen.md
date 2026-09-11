---
title: jnigen
---
jnigen 是一个可独立使用或与 libGDX 配合使用的小型库，允许将 C/C++ 代码内联写入 Java 源代码。它让概念上属于同一部分的代码（Java 本机类方法和实际实现）彼此更接近，相比通常的 [JNI](https://en.wikipedia.org/wiki/Java_Native_Interface) 工作流更容易重构。数组和直接缓冲区会自动转换，进一步减少样板代码。Windows、Linux、OS X 和 Android 的本机库构建也由它处理。jnigen 还提供了运行时从 JAR 加载本机库的机制，避免 “java.library.path” 带来的问题。

## 设置

需要安装 32 位和 64 位 MinGW。安装后，请确保 `bin` 目录位于 PATH 中。

注意，gdx-jnigen 是 Java 项目。由于 Android NDK 要求存在 AndroidManifest.xml，它包含一个空文件，但本身不是 Android 项目。

### Windows

  * **32 位 MinGW** 运行 [mingw-get-setup.exe](https://sourceforge.net/projects/mingw/files/Installer/)，通过 GUI 安装，在 “Basic Setup” 下选择 `mingw32-base` 和 `mingw32-gcc-g++`，然后选择 Installation -> Apply Changes。
  * **64 位 MinGW** 下载 [64 位 MinGW](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/4.8.2/threads-win32/seh/x86_64-4.8.2-release-win32-seh-rt_v3-rev1.7z/download) 二进制文件并解压。

### Linux

  * Ubuntu 和其他基于 Debian 的系统（未经验证）

```bash
sudo apt-get install g++-mingw-w64-i686 g++-mingw-w64-x86-64
```

  * Arch Linux（这会安装同时支持 32 位和 64 位的编译器；[了解更多](https://wiki.archlinux.org/index.php/MinGW_package_guidelines)）

```bash
sudo pacman -S mingw-w64-gcc
```

  * Fedora、CentOS 和基于 RHEL 的系统

```bash
sudo dnf install mingw32-gcc-c++ mingw64-gcc-c++ mingw32-winpthreads-static mingw64-winpthreads-static
```

## 快速开始

下面是一个最简示例，先看包含内联本机代码的 Java 源代码：

```
public class Example {
	// @off

	static public native int add (int a, int b); /*
		return a + b;
	*/

	public static void main (String[] args) throws Exception {
		new SharedLibraryLoader().load("my-native-lib");
		System.out.println(add(1, 2));
	}
}
```

`@off` 注释会关闭文件其余部分的 Eclipse 源代码格式化程序，避免破坏注释中本机代码的格式。必须在 Eclipse 首选项 Java > Code Style > Formatter 中启用此功能。点击 “Edit” 按钮，选择 “Off/On Tags”，勾选 “Enable Off/On tags”。

接下来定义一个本机方法。通常使用 JNI 时，需要运行 [javah](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/javah.html) 生成存根源文件，再编辑它们并保持与 Java 源代码同步。使用 jnigen 时，只需在本机方法后立即添加包含本机代码的多行注释即可。本机方法的参数可供本机代码使用。

最后定义 main 方法。`SharedLibraryLoader` 会从类路径中提取并加载适合的本机库，因此可以将本机库放在 JAR 中分发，不会再遇到 `java.library.path` 问题。

## 工作原理

jnigen 包含两部分：

  * 检查指定文件夹中的 Java 源文件，检测本机方法及其附带的 C++ 实现，并输出类似手动使用 JNI 创建的 C++ 源文件和头文件。
  * 提供 Ant 构建脚本生成器，为每个平台构建本机源代码。

### 本机代码生成

下面是 jnigen 所理解的 Java/C++ 混合 Java 源文件示例（取自 [BufferUtils](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/BufferUtils.java)）：

```java
private static native ByteBuffer newDisposableByteBuffer (int numBytes); /*
   char* ptr = (char*)malloc(numBytes);
   return env->NewDirectByteBuffer(ptr, numBytes);
*/

private native static void copyJni (float[] src, Buffer dst, int numFloats, int offset); /*
   memcpy(dst, src + offset, numFloats << 2 );
*/
```

C++ 代码位于 Java 本机方法声明后的块注释中。Java 侧输入参数可以通过其 Java 名称供 C++ 代码使用，并在可能时对有限类型子集进行封送。封送规则如下：

  * 基本类型按原样传递，类型使用 jint、jshort、jboolean 等。
  * 一维基本类型数组会转换为可直接访问的类型化指针。数组会通过 JNIEnv::GetPrimitiveArrayCritical 和 JNIEnv::ReleasePrimitiveArrayCritical 自动锁定和解锁。
  * 直接缓冲区会通过 JNIEnv::GetDirectBufferAddress 转换为 unsigned char`*` 指针。注意，缓冲区的位置不会被考虑！
  * 其他类型会以对应的 JNI 类型传递，例如普通 Java 对象会作为 jobject 传递。

上面的两个 jnigen 本机方法会转换为以下 C++ 源代码（同时还会生成对应的头文件）：

```cpp
JNIEXPORT jobject JNICALL Java_com_badlogic_gdx_utils_BufferUtils_newDisposableByteBuffer(JNIEnv* env, jclass clazz, jint numBytes) {
//@line:334
   char* ptr = (char*)malloc(numBytes);
   return env->NewDirectByteBuffer(ptr, numBytes);
}

JNIEXPORT void JNICALL Java_com_badlogic_gdx_utils_BufferUtils_copyJni___3FLjava_nio_Buffer_2II(JNIEnv* env, jclass clazz, jfloatArray obj_src, jobject obj_dst, jint numFloats, jint offset) {
   unsigned char* dst = (unsigned char*)env->GetDirectBufferAddress(obj_dst);
   float* src = (float*)env->GetPrimitiveArrayCritical(obj_src, 0);

//@line:348
   memcpy(dst, src + offset, numFloats << 2 );

   env->ReleasePrimitiveArrayCritical(obj_src, src, 0);
}
```

可以看到，封送代码会在 `copyJni()` 方法的开头和结尾自动插入。如果 JNI 方法从不是末尾的位置返回，jnigen 会用另一个负责全部封送的函数包装你的函数。

jnigen 会在生成的本机代码中输出 Java 行号，指出 C++ 代码在原始 Java 源文件中的位置。这对构建 jnigen 生成的 C++ 代码很有帮助，因为 Ant 脚本会输出带 Java 行号的错误，可以点击控制台中的行直接跳转。

### 使用方法

推荐通过 Gradle 插件使用 jnigen，尽管这不是必需的。
首先需要应用 jnigen 插件：
```gradle
// Add buildscript dependency
buildscript {
    dependencies {
        classpath "com.badlogicgames.gdx:gdx-jnigen-gradle:2.X.X"
    }
}

// Apply jnigen plugin
apply plugin: "com.badlogicgames.gdx.gdx-jnigen"
```

然后可以在 `jnigen {}` 块中配置构建操作。
可以使用 `add(<platform>, <bitness>, <architectur>)` 添加新目标。
平台：`Windows`、`Linux`、`MacOsX`、`IOS`、`Android`
架构：`x86`（默认）、`ARM`
位数：`32`（默认）、`64`、`128`

注意：iOS 和 Android 不接受 Architecture 或 Bitness，只会生成一个任务。

每个新目标都会创建一个命名模式为 `jnigenBuild<platform><architecture><bitness>` 的 Gradle 任务，但默认值会从任务名称中省略。

执行这些任务会为指定平台构建本机库。

注意：构建 Android 本机库时，需要将 `NDK_HOME` 设置为有效 NDK 的路径。iOS 和 MacOS 只能在 MacOS 上编译。

用于分发的任务是 `jnigenJarNatives<destintation>`。它们会将生成的本机库打包进 jar，以便由 `SharedLibraryLoader` 加载。这些 jar 应随应用分发。

Destintation 取值：`Desktop`、`Àndroid`、`IOS`  

每个目标还可以根据需要配置额外的链接器标志和其他选项。
关于所有选项及其应用方式的完整文档，请参阅 jnigen[文档](https://github.com/libgdx/gdx-jnigen#gdx-jnigen-gradle-quickstart)。


### 更多内容

下面是一些不同复杂度的 jnigen 构建示例：

* [gdx](https://github.com/libgdx/libgdx/blob/master/gdx/build.gradle)
* [gdx-freetype](https://github.com/libgdx/libgdx/blob/master/extensions/gdx-freetype/build.gradle)
* [gdx-bullet](https://github.com/libgdx/libgdx/blob/master/extensions/gdx-bullet/build.gradle)
* [gdx-video-desktop](https://github.com/libgdx/gdx-video/blob/master/gdx-video-desktop/build.gradle)
* [Jamepad](https://github.com/libgdx/Jamepad/blob/master/build.gradle)

### ccache
如果要为所有平台（Linux、Windows、Mac OS X、Android、iOS，以及 arm、arm-v7、x86、x64 的所有组合）构建，强烈建议使用 [ccache](https://ccache.dev/)。libGDX 使用非常简单的配置。在构建服务器上，我们有一个 `/opt/ccache` 目录，其中包含多个 shell 脚本，每个编译器二进制文件对应一个：

```
jenkins@badlogic:~/workspace/libgdx/gdx/jni$ ls -lah /opt/ccache/
-rwxr-xr-x  1 jenkins  www-data   44 Apr  6 13:14 g++
-rwxr-xr-x  1 jenkins  www-data   44 Apr  6 13:14 gcc
-rwxr-xr-x  1 jenkins  www-data   78 Apr  6 13:15 i686-w64-mingw32-g++
-rwxr-xr-x  1 jenkins  www-data   78 Apr  6 13:15 i686-w64-mingw32-gcc
-rwxr-xr-x  1 jenkins  www-data   82 Apr  6 13:15 x86_64-w64-mingw32-g++
-rwxr-xr-x  1 jenkins  www-data   82 Apr  6 13:15 x86_64-w64-mingw32-gcc
```

每个脚本看起来都像这样（当然可执行文件名称会有所不同）：

```
echo "g++ ccache!"
ccache /usr/bin/g++ "$@"
```

要让 ccache 生效，只需确保 `/opt/ccache` 目录位于 PATH 的最前面：

```
export PATH=/opt/ccache:$PATH
```

每当调用某个编译器时，shell 脚本都会将其重定向到 ccache。

对于 Android，只需设置 NDK_CCACHE 即可。

```
export NDK_CCACHE=ccache
```
