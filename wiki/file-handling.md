---
title: 文件处理
---
* [简介](#introduction)
* [平台文件系统](#platform-filesystems)
* [文件（存储）类型](#file-storage-types)
* [检查存储可用性和路径](#checking-storage-availability-and-paths)
* [获取 FileHandle](#obtaining-filehandles)
* [列出文件并检查文件属性](#listing-and-checking-properties-of-files)
* [错误处理](#error-handling)
* [从文件读取](#reading-from-a-file)
* [向文件写入](#writing-to-a-file)
* [删除、复制、重命名和移动文件/目录](#deleting-copying-renaming-and-moving-filesdirectories)


## 简介
libGDX 应用运行在四类平台上：桌面系统（Windows、Linux、macOS、headless）、Android、iOS，以及支持 JavaScript/WebGL 的浏览器。每个平台处理文件 I/O 的方式略有不同。libGDX 的 [Files](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Files.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/Files.java) 模块为所有这些平台提供统一接口，能够：

   * 从文件读取
   * 向文件写入
   * 复制文件
   * 移动文件
   * 删除文件
   * 列出文件和目录
   * 检查文件/目录是否存在

在深入了解 libGDX 文件处理的细节之前，应先了解所有支持平台的文件系统之间存在的一些差异：

## 平台文件系统
### 桌面端（Windows、Linux、Mac OS X、Headless）
在桌面操作系统上，文件系统是一整块存储空间。文件可以使用相对于当前工作目录（应用执行时所在目录）的路径或绝对路径引用。忽略文件权限时，所有应用通常都可以读写文件和目录。

### Android
Android 上的情况稍微复杂一些。文件可以作为资源或 assets 存储在应用的 [APK](https://en.wikipedia.org/wiki/APK_(file_format)) 中。这些文件是只读的。libGDX 只使用 [assets 机制](https://developer.android.com/reference/android/content/res/AssetManager)，因为它可以直接访问字节流，也更接近传统文件系统。[资源](https://developer.android.com/guide/topics/resources/providing-resources)更适合普通 Android 应用，但用于游戏时会带来问题，例如 Android 会在加载时自动调整图片大小。

Assets 存储在项目的 `assets` 目录中，部署应用时会自动打包进 APK。它们可通过 `Gdx.files.internal` 访问，这是一个只读目录，不要将它与 Android 文档所称的“internal”混淆。Android 系统中的其他应用无法访问这些文件。

文件也可以存储在 Android 文档所称的[内部存储](https://developer.android.com/training/data-storage)中（在 LibGDX 中通过 `Gdx.files.local` 访问），这里的文件可读写。每个已安装应用都有专用的内部存储目录，该目录只有应用自身可以访问。可以把这种存储理解为应用的私有工作区。

最后，文件还可以存储在外部存储中，在 LibGDX 中通过 `Gdx.files.external` 访问。Android 对外部文件的行为随着版本发生过变化，因此在 LibGDX 中：

* libGDX 1.9.11 及更早版本使用 Android 外部存储目录。在 Android 4.3 及更早版本中，这是可能并不总是可用的 SD 卡目录；在更高版本中，则是虚拟的模拟 SD 卡目录。要访问这些文件，需要在 AndroidManifest.xml 中添加权限，参见[权限](/wiki/app/starter-classes-and-configuration#permissions)。从 Android 6 起，使用该目录还需要运行时权限；从 Android 11 起，普通应用将完全禁止访问（如果要发布到 Play Store）。
* libGDX 1.9.12 及更高版本使用应用专属的外部存储目录。该目录位于 Android/data/your_package_id/，应用无需任何额外权限或变更即可读写。其他应用（例如文件管理器）在 Android 10 及更早版本中可以访问这些文件；从 Android 11 起，该目录只能通过 USB 访问。注意：如果用户卸载应用，除非事先将数据复制到其他位置，否则此处保存的数据会被删除。

应用专属外部存储会在游戏启动时初始化供你使用，因此 Android 会创建一个空目录。如果不使用外部文件并希望抑制此行为，可以在 `AndroidApplication#createFiles` 中重写 `AndroidFiles` 的实例化（1.9.14 及更高版本）：

```java
	protected AndroidFiles createFiles() {
		this.getFilesDir(); // workaround for Android bug #10515463
		return new DefaultAndroidFiles(this.getAssets(), this, false);
	}
```

### iOS
iOS 上所有文件类型都可用。

### Javascript/WebGL
原生 Javascript/WebGL 应用没有传统文件系统的概念。相反，图片等资源通过 URL 引用一个或多个服务器上的文件。现代浏览器还支持接近传统读写文件系统的 [Local Storage](https://web.archive.org/web/20240621005117/http://diveintohtml5.info/storage.html)。但 Local Storage 默认可用空间较小，标准也不统一，并且没有（好的）方式准确查询配额。因此，Preferences API 目前是 JS 平台持久写入本地数据的唯一方式。

libGDX 会在底层进行一些处理，为你提供只读文件系统抽象。

## 文件（存储）类型
在 libGDX 中，文件由 [FileHandle](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/files/FileHandle.java) 类的实例表示。FileHandle 有一个类型，用于定义文件的位置。下表说明各平台上每种文件类型的可用性和位置。

| *类型* | *描述、文件路径和特性* | *桌面端* | *Android* | *HTML5* | *iOS* |
|:------:|:--------------------------------------|:---------:|:---------:|:-------:|:-----:|
| Classpath | Classpath 文件直接存储在源代码文件夹中，会随 jar 一起打包，并且始终为*只读*。它们有其用途，但应尽可能避免使用。 | 是 | 是 | 否 | 是 |
| Internal | 桌面端的 Internal 文件相对于应用程序的*根目录*或*工作目录*，Android 上相对于 *assets* 目录，GWT 项目中相对于 `core/assets/` 目录。这些文件为*只读*。如果在内部存储中找不到文件，文件模块会回退到 classpath 中搜索。这是使用 Eclipse 资源文件夹链接机制时所必需的，参见[项目设置](/wiki/start/project-generation)。相对路径（`./` 或 `../`）并不总是受支持，因此不应使用。 | 是 | 是 | 是 | 是 |
| Local | 桌面端的 Local 文件相对于应用程序的*根目录*或*工作目录*，Android 上相对于应用程序的内部（私有）存储。注意，在桌面端 Local 与 Internal 基本相同。 | 是 | 是 | 否 | 是 |
| External| 桌面系统上的 External 文件路径相对于当前用户的[主目录](https://www.roseindia.net/java/beginners/UserHomeExample.shtml)。Android 上使用应用专属的外部存储。 | 是 | 是 | 否 | 是 |
| Absolute | Absolute 文件必须指定完整路径。<br/>*注意*：为了保证可移植性，仅应在绝对必要时使用此选项。 | 是 | 是 | 否 | 是 |

Absolute 和 Classpath 文件主要用于桌面编辑器等具有更复杂文件 I/O 需求的工具。对于游戏，可以放心忽略它们。应按以下顺序使用这些类型：

  * **Internal Files**：随应用程序打包的所有资源（图像、音频文件等）都是内部文件。如果使用设置界面，只需将它们放入 Android 项目的 `assets` 文件夹。
  * **Local Files**：如果需要写入小文件（例如保存游戏状态），请使用本地文件。它们通常是应用程序私有的。如果需要键值存储，也可以查看[偏好设置](/wiki/preferences)。
    注意，Android 的应用专属缓存可以通过 `../cache` 访问。存储在其中的文件可以由用户通过应用设置中的“清除缓存”按钮清除。
  * **External Files**：如果需要写入大文件（例如截图）或从网络下载文件，可以将它们放到外部存储中。注意，外部存储是不稳定的，用户可能移除存储设备或删除写入的文件。由于外部存储中的文件不会自动清理且不稳定，通常使用本地文件存储更简单。

## 检查存储可用性和路径
不同存储类型的可用性取决于应用运行的平台。可以通过 Files 模块查询相关信息：

```java
boolean isExtAvailable = Gdx.files.isExternalStorageAvailable();
boolean isLocAvailable = Gdx.files.isLocalStorageAvailable();
```

也可以查询外部存储和本地存储的根路径：

```java
String extRoot = Gdx.files.getExternalStoragePath();
String locRoot = Gdx.files.getLocalStoragePath();
```

## 获取 FileHandle
可以直接从 *Files* 模块使用前述类型之一获取 `FileHandle`。
以下代码获取内部文件 `myfile.txt` 的句柄。

```java
FileHandle handle = Gdx.files.internal("myfile.txt");
```

如果使用了 [gdx-liftoff 工具](/wiki/start/project-generation)，该文件将位于项目的 `assets` 文件夹中。桌面端和 html 项目会在 Eclipse 中链接到此文件夹，从 Eclipse 内运行时会自动找到它。

```java
FileHandle handle = Gdx.files.classpath("myfile.txt");
```

`myfile.txt` 文件位于编译后类或所包含 jar 文件所在的目录中。

```java
FileHandle handle = Gdx.files.external("myfile.txt");
```

在这种情况下，桌面端的 `myfile.txt` 需要位于用户的[主目录](https://en.wikipedia.org/wiki/Home_directory)中（Linux 为 `/home/<user>/myfile.txt`，macOS 为 `/Users/<user>/myfile.txt`，Windows 为 `C:\Users\<user>\myfile.txt`），Android 上则需要位于 SD 卡根目录。

```java
FileHandle handle = Gdx.files.absolute("/some_dir/subdir/myfile.txt");
```

对于绝对文件句柄，文件必须准确位于完整路径所指向的位置：Windows 当前驱动器的 `/some_dir/subdir/` 中，或 Linux、macOS 和 Android 上的对应确切路径中。

FileHandle 实例会传给负责读写数据的类的方法。例如，通过 Texture 类加载图像，或通过 Audio 模块加载音频文件时，都需要指定 FileHandle。

## 列出文件并检查文件属性
有时需要检查特定文件是否存在，或列出目录内容。FileHandle 提供了简洁完成这些操作的方法。

下面的示例检查特定文件是否存在，以及某个路径是否确实是目录。

```java
boolean exists = Gdx.files.external("doitexist.txt").exists();
boolean isDirectory = Gdx.files.external("test/").isDirectory();
```

列出目录同样简单：

```java
FileHandle[] files = Gdx.files.local("mylocaldir/").list();
for(FileHandle file: files) {
   // do something interesting here
}
```

**警告**：如果不指定文件夹，列表将为空。

**注意**：桌面端不支持列出内部目录。作为替代方案，可以在部署前[生成文件列表](https://web.archive.org/web/20240901085440/https://lyze.dev/2021/04/29/libGDX-Internal-Assets-List/)。使用 [gdx-liftoff](https://libgdx.com/wiki/start/project-generation) 生成的新项目内置了此功能，会自动在 `assets/assets.txt` 生成文件列表。

还可以获取文件的父目录，或为目录中的文件创建 FileHandle（即“子项”）。

```java
FileHandle parent = Gdx.files.internal("graphics/myimage.png").parent();
FileHandle child = Gdx.files.internal("sounds/").child("myaudiofile.mp3");
```

`parent` 会指向 `"graphics/"`，`child` 会指向 `sounds/myaudiofile.mp3"`。

FileHandle 还提供许多用于检查文件具体属性的方法。详情请参阅 Javadocs。

**注意**：目前 HTML5 后端大多尚未实现这些功能。如果应用程序的目标平台包含 HTML5，请尽量不要过度依赖它们。

## 错误处理
FileHandle 的某些操作可能失败。我们采用 `RuntimeExceptions` 报告错误，而不是使用受检异常，因为 90% 的情况下我们访问的都是已知存在且可读的文件（例如随应用打包的内部文件）。

## 从文件读取
获取 FileHandle 后，可以将其传给知道如何从文件加载内容的类（例如图像类），也可以自行读取。后者通过 FileHandle 类中的输入方法完成。下面示例演示如何从内部文件加载文本：

```java
FileHandle file = Gdx.files.internal("myfile.txt");
String text = file.readString();
```

如果处理的是二进制数据，也可以轻松将文件加载到字节数组中：

```java
FileHandle file = Gdx.files.internal("myblob.bin");
byte[] bytes = file.readBytes();
```

FileHandle 类还提供许多其他读取方法。更多信息请查看 [Javadocs](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/files/FileHandle.html)。

## 向文件写入
与读取文件类似，FileHandle 也提供写入文件的方法。注意，只有 local、external 和 absolute 文件类型支持写入文件。向文件写入字符串的方式如下：

```java
FileHandle file = Gdx.files.local("myfile.txt");
file.writeString("My god, it's full of stars", false);
```

`FileHandle#writeString` 的第二个参数指定是否将内容追加到文件末尾。如果设为 false，文件当前内容将被覆盖。

当然也可以向文件写入二进制数据：

```java
FileHandle file = Gdx.files.local("myblob.bin");
file.writeBytes(new byte[] { 20, 3, -2, 10 }, false);
```

FileHandle 还提供许多以不同方式写入数据的方法，例如使用 `OutputStream`。详情仍请参阅 Javadocs。

## 删除、复制、重命名和移动文件/目录
这些操作同样只适用于可写文件类型（local、external、absolute）。但请注意，复制操作的源也可以是只读 FileHandle。示例如下：

```java
FileHandle from = Gdx.files.internal("myresource.txt");
from.copyTo(Gdx.files.external("myexternalcopy.txt"));

Gdx.files.external("myexternalcopy.txt").rename("mycopy.txt");
Gdx.files.external("mycopy.txt").moveTo(Gdx.files.local("mylocalcopy.txt"));

Gdx.files.local("mylocalcopy.txt").delete();
```

注意，源和目标都可以是文件或目录。

有关可用方法的更多信息，请查看 [FileHandle Javadocs](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/files/FileHandle.html)。
