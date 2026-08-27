---
title: 使用 Gradle 管理依赖
---
## 目录

* [**有用链接**](#useful-links)
* [**build.gradle 指南**](#guide-to-buildgradle)
* [**libGDX 依赖**](#libgdx-dependencies)
 * [可用的 libGDX 扩展](#libgdx-extensions)
* [**外部依赖**](#external-dependencies)
 * [添加仓库](#adding-external-repositories)
 * [将本地依赖 Maven 化](#mavenizing-local-dependencies)
 * [文件依赖](#file-dependencies)
   * [Android 陷阱](#android-pitfall)
* [**使用 HTML 声明依赖**](#gwt-inheritance)
 * [libGDX 扩展继承](#libgdx-extension-inherits)
* [**库的依赖管理**](#dependency-management-for-libraries)

### 有用链接
使用 Gradle 管理依赖很容易理解，而且有多种实现方式。如果你熟悉 Maven 或 Ivy，Gradle 完全兼容这两种方式，同时也支持自定义方式。如果你不熟悉 Gradle，其网站上有很好的学习资源，建议阅读这些资源以熟悉 Gradle。
* [Gradle 用户指南](https://docs.gradle.org/current/userguide/userguide.html)
* [Gradle 依赖管理指南](https://docs.gradle.org/current/userguide/dependency_management.html)
* [声明依赖](https://docs.gradle.org/current/userguide/dependency_management.html#declaring-dependencies)

### build.gradle 指南
Gradle 项目由根目录中的 `build.gradle` 文件管理。如果你使用过 gdx-setup.jar 构建 libGDX 项目，会注意到其结构：[结构示例](/wiki/start/project-generation#project-layout)

根目录及每个子目录都包含一个 `build.gradle` 文件。为清晰起见，我们将在根目录的 `build.gradle` 文件中定义依赖。（也可以在各子目录的 `build.gradle` 脚本中完成，但集中处理更整洁，也更容易理解。）

下面是设置工具生成的_默认_构建脚本的一小段：

_根据拥有的其他模块，完整脚本会略有不同_
```gradle
//Configuration for the script itself (aka, listing the dependencies of the script that lists dependencies - InSCRIPTion!)
buildscript {
    //Defines the repositories required by this script, e.g. hosting the android plugin
    repositories {
        //maven central repository, needed for the android plugin
        mavenCentral()
        //snapshot repository (in case this script depends on snapshot/prerelease artifacts)
        maven { url "https://oss.sonatype.org/content/repositories/snapshots/" }
        gradlePluginPortal()
        //local maven repository (advanced use)
        mavenLocal()
        google()
        maven { url 'https://oss.sonatype.org/content/repositories/snapshots/' }
        maven { url 'https://s01.oss.sonatype.org/content/repositories/snapshots/' }
    }
    //Defines the artifacts this script depends on, e.g. the android plugin
    dependencies {
        //Adds the android gradle plugin as a dependency of this buildscript
        classpath "com.android.tools.build:gradle:8.1.4"
        classpath "org.docstr:gwt-gradle-plugin:$gwtPluginVersion"
    }
}

//Configuration common to all projects (:core, :desktop and :android in this example)
allprojects {
    //Defines gradle plugins used by all projects.
    //A plugin extends gradle with additional tasks, configurations, etc., with defaults set according to conventions.
    apply plugin: "eclipse"
    apply plugin: "idea"

    // This allows you to "Build and run using IntelliJ IDEA", an option in IDEA's Settings.
    idea {
        module {
        outputDir file('build/classes/java/main')
        testOutputDir file('build/classes/java/test')
        }
    }
}

configure(subprojects - project(':android')) {
  apply plugin: 'java-library'
  sourceCompatibility = 8
  compileJava {
    options.incremental = true
  }
  // From https://web.archive.org/web/20240901085440/https://lyze.dev/2021/04/29/libGDX-Internal-Assets-List/
  // The article can be helpful when using assets.txt in your project.
  compileJava.doLast {
    // projectFolder/assets
    def assetsFolder = new File("${project.rootDir}/assets/")
    // projectFolder/assets/assets.txt
    def assetsFile = new File(assetsFolder, "assets.txt")
    // delete that file in case we've already created it
    assetsFile.delete()

    // iterate through all files inside that folder
    // convert it to a relative path
    // and append it to the file assets.txt
    fileTree(assetsFolder).collect { assetsFolder.relativePath(it) }.each {
      assetsFile.append(it + "\n")
    }
  }
}

subprojects {
    //Version of your game
    version = '1.0.0'
    ext.appName = 'MyOriginalGame'
    repositories {
        mavenCentral()
        maven { url 'https://s01.oss.sonatype.org' }
        // You may want to remove the following line if you have errors downloading dependencies.
        mavenLocal()
        maven { url 'https://oss.sonatype.org/content/repositories/snapshots/' }
        maven { url 'https://s01.oss.sonatype.org/content/repositories/snapshots/' }
        maven { url 'https://jitpack.io' }
    }
}

eclipse.project.name = 'MyOriginalGame' + '-parent'
```

### libGDX 依赖
依赖在每个子项目对应的 `build.gradle` 文件中配置。例如：`core/build.gradle`、`android/build.gradle`、`html/build.gradle` 等。
要向项目添加外部依赖，必须在构建脚本的正确部分正确声明该依赖。

（部分）libGDX 扩展已经 Maven 化并发布到 Maven 仓库，因此可以很容易地从 `build.gradle` 文件将它们引入项目。此类依赖的格式请见下方[列表](#libgdx-extensions)。
如果你熟悉 Maven，请注意其格式：
```gradle
implementation '<groupId>:<artifactId>:<version>:<classifier>'
```

下面以 android `build.gradle` 文件为例快速说明其工作方式。

在[这里](#freetypefont-gradle)可以看到 FreeType 扩展的依赖。假设我们希望 Android 项目拥有这一依赖：
```gradle
dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
    implementation "com.badlogicgames.gdx:gdx-backend-android:$gdxVersion"
    implementation project(':core')

    natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-arm64-v8a"
    natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-armeabi-v7a"
    natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86"
    natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86_64"
}
```

**我们知道 FreeType 扩展在 Android 中有以下声明：**
```gradle
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-arm64-v8a"
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-armeabi-v7a"
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-x86"
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-x86_64"
```

**因此，只需将它添加到 dependencies 模板中即可。**

```gradle
dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
    implementation "com.badlogicgames.gdx:gdx-backend-android:$gdxVersion"
    implementation project(':core')

    natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-arm64-v8a"
    natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-armeabi-v7a"
    natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-x86"
    natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-x86_64"
    natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-arm64-v8a"
    natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-armeabi-v7a"
    natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86"
    natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86_64"
}
```

**确保 Core 项目的 core/build.gradle 中包含 freetype 扩展。**

```gradle
dependencies {
  api "com.badlogicgames.gdx:gdx-freetype:$gdxVersion"
  api "com.badlogicgames.gdx:gdx:$gdxVersion"
}
```
这样就完成了，android 项目现在拥有 freetype 依赖。
之后需要刷新依赖。很简单，对吧？

#### libGDX 扩展
可以从 `build.gradle` 脚本直接导入、且已经 Maven 化的 libGDX 扩展包括：
* [Box2D](#box2d-gradle)
* [Bullet](#bullet-gradle)
* [FreeTypeFont](#freetypefont-gradle)
* [Controllers](#controllers-gradle)
* [Tools](#tools-gradle)
* [Box2DLights](#box2dlights-gradle)
* [Ashley](#ashley-gradle)
* [AI](#ai-gradle)

#### Box2D Gradle
**Core 依赖：**
```gradle
api "com.badlogicgames.gdx:gdx-box2d:$gdxVersion"
```
**桌面端依赖：**
```gradle
implementation "com.badlogicgames.gdx:gdx-box2d-platform:$gdxVersion:natives-desktop"
```
**Android 依赖：**
```gradle
natives "com.badlogicgames.gdx:gdx-box2d-platform:$gdxVersion:natives-arm64-v8a"
natives "com.badlogicgames.gdx:gdx-box2d-platform:$gdxVersion:natives-armeabi-v7a"
natives "com.badlogicgames.gdx:gdx-box2d-platform:$gdxVersion:natives-x86"
natives "com.badlogicgames.gdx:gdx-box2d-platform:$gdxVersion:natives-x86_64"
```
**iOS 依赖：**
```gradle
implementation "com.badlogicgames.gdx:gdx-box2d-platform:$gdxVersion:natives-ios"
```
**HTML 依赖：**
```gradle
implementation "com.badlogicgames.gdx:gdx-box2d:$gdxVersion:sources"
implementation("com.badlogicgames.gdx:gdx-box2d-gwt:$gdxVersion:sources") {exclude group: "com.google.gwt", module: "gwt-user"}
```
并在 `./html/src/yourgamedomain/GdxDefinition*.gwt.xml` 中添加 `<inherits name="com.badlogic.gdx.physics.box2d.box2d-gwt" />`

***

#### Bullet Gradle
**Core 依赖：**
```gradle
api "com.badlogicgames.gdx:gdx-bullet:$gdxVersion"
```
**桌面端依赖：**
```gradle
implementation "com.badlogicgames.gdx:gdx-bullet-platform:$gdxVersion:natives-desktop"
```
**Android 依赖：**
```gradle
natives "com.badlogicgames.gdx:gdx-bullet-platform:$gdxVersion:natives-arm64-v8a"
natives "com.badlogicgames.gdx:gdx-bullet-platform:$gdxVersion:natives-armeabi-v7a"
natives "com.badlogicgames.gdx:gdx-bullet-platform:$gdxVersion:natives-x86"
natives "com.badlogicgames.gdx:gdx-bullet-platform:$gdxVersion:natives-x86_64"
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-arm64-v8a"
```
**iOS 依赖：**
```gradle
implementation "com.badlogicgames.gdx:gdx-bullet-platform:$gdxVersion:natives-ios"
```
**HTML 依赖：**
不兼容！

***

#### FreeTypeFont Gradle
**Core Dependency:**
```gradle
api "com.badlogicgames.gdx:gdx-freetype:$gdxVersion"
```
**Desktop Dependency:**
```gradle
implementation "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-desktop"
```
**Android Dependency:**
```gradle
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-arm64-v8a"
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-armeabi-v7a"
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-x86"
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-x86_64"
```
**iOS Dependency:**
```gradle
implementation "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-ios"
```
**iOS-MOE Dependency:**
```gradle
natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-ios"
```
**HTML Dependency:**
不兼容！替代方案请参阅 [gdx-freetype-gwt](https://github.com/intrigus/gdx-freetype-gwt)。

***

#### Controllers Gradle
**Core Dependency:**
```gradle
api "com.badlogicgames.gdx-controllers:gdx-controllers-core:$gdxControllersVersion"
```
**Desktop Dependency:**
```gradle
implementation "com.badlogicgames.gdx-controllers:gdx-controllers-desktop:$gdxControllersVersion"
```
**Android Dependency:**
```gradle
implementation "com.badlogicgames.gdx-controllers:gdx-controllers-android:$gdxControllersVersion"
```
**iOS Dependency:**
```gradle
implementation "com.badlogicgames.gdx-controllers:gdx-controllers-ios:$gdxControllersVersion"
```

**HTML Dependency:**
```gradle
implementation "com.badlogicgames.gdx-controllers:gdx-controllers-core:$gdxControllersVersion:sources"
implementation("com.badlogicgames.gdx-controllers:gdx-controllers-gwt:$gdxControllersVersion:sources"){exclude group: "com.badlogicgames.gdx", module: "gdx-backend-gwt"}
```
并在 `./html/src/yourgamedomain/GdxDefinition*.gwt.xml` 中添加 `<inherits name="com.badlogic.gdx.controllers" />` 和 `<inherits name="com.badlogic.gdx.controllers.controllers-gwt" />`

***

#### Tools Gradle
**Core Dependency:**
不要将其放入 core！

**Desktop Dependency (LWJGL2 Legacy Desktop only):**
```gradle
api "com.badlogicgames.gdx:gdx-tools:$gdxVersion"
```
**Android Dependency:**
不兼容！

**iOS Dependency:**
不兼容！

**HTML Dependency:**
不兼容！

***

#### Box2DLights Gradle
* **注意：**此扩展还需要 [Box2D](#box2d-gradle) 扩展

**Core Dependency:**
```gradle
api "com.badlogicgames.box2dlights:box2dlights:$box2dlightsVersion"
```
**Desktop Dependency:**
不需要原生依赖。

**Android Dependency:**
不需要原生依赖。

**HTML Dependency:**
```gradle
implementation "com.badlogicgames.box2dlights:box2dlights:$box2dlightsVersion:sources"
```
并在 `./html/src/yourgamedomain/GdxDefinition*.gwt.xml` 中添加 `<inherits name="Box2DLights" />`

***

#### Ashley Gradle

* **注意：**此扩展的发布周期不依赖主 libGDX 库，因此在两个 libGDX 版本之间发布新版本并不罕见。如果想引入新版本（或其他版本），请查看 [https://repo1.maven.org/maven2/com/badlogicgames/ashley/ashley/](https://repo1.maven.org/maven2/com/badlogicgames/ashley/ashley/)，并修改 `ext` 部分的 `ashleyVersion` 值。

**Core Dependency:**
```gradle
api "com.badlogicgames.ashley:ashley:$ashleyVersion"
```

**Desktop Dependency:**
不需要原生依赖。

**Android Dependency:**
不需要原生依赖。

**HTML Dependency:**
```gradle
implementation "com.badlogicgames.ashley:ashley:$ashleyVersion:sources"
```
并在 `./html/src/yourgamedomain/GdxDefinition*.gwt.xml` 中添加 `<inherits name="com.badlogic.ashley_gwt" />`

***

#### AI Gradle

* **注意：**此扩展的发布周期不依赖主 libGDX 库，因此在两个 libGDX 版本之间发布新版本并不罕见。如果想引入新版本（或其他版本），请查看 [https://repo1.maven.org/maven2/com/badlogicgames/gdx/gdx-ai/](https://repo1.maven.org/maven2/com/badlogicgames/gdx/gdx-ai/)，并修改 `ext` 部分的 `aiVersion` 值。

**Core Dependency:**
```gradle
api "com.badlogicgames.gdx:gdx-ai:$aiVersion"
```

**Desktop Dependency:**
不需要原生依赖。

**Android Dependency:**
不需要原生依赖。

**HTML Dependency:**
```gradle
implementation "com.badlogicgames.gdx:gdx-ai:$aiVersion:sources"
```
并在 `./html/src/yourgamedomain/GdxDefinition*.gwt.xml` 中添加 `<inherits name="com.badlogic.gdx.ai" />`

***



### 外部依赖
#### 添加外部仓库
Gradle 会遍历构建脚本中定义的所有仓库，以查找定义为依赖的文件。Gradle 支持多种仓库格式，包括 Maven 和 Ivy。

在根 build.gradle 的 `subprojects` 模板中可以看到仓库的定义方式。示例如下：
```gradle
subprojects {
    version = '1.0.0'
    ext.appName = 'MyOriginalGame'
    repositories {
        mavenCentral()
        maven { url 'https://s01.oss.sonatype.org' }
         // You may want to remove the following line if you have errors downloading dependencies.
        mavenLocal()
        maven { url 'https://oss.sonatype.org/content/repositories/snapshots/' }
        maven { url 'https://s01.oss.sonatype.org/content/repositories/snapshots/' }
        maven { url 'https://jitpack.io' }f
    }
}
```
#### 添加依赖
外部依赖通过 group、name、version，有时还包括 classifier 属性来标识。

```gradle
dependencies {
    implementation group: 'com.badlogicgames.gdx', name: 'gdx', version: '1.0-SNAPSHOT', classifier: 'natives-desktop'
}
```
定义外部依赖时，Gradle 允许使用简写；上面的配置等同于：

```gradle
dependencies {
    implementation 'com.badlogicgames.gdx:gdx:1.0-SNAPSHOT:natives-desktop'
}
```

### 将本地依赖 Maven 化
如果希望使用 Maven 仓库管理本地 .jar 文件，下面两条命令会将任意本地 .jar 文件及其源代码安装到本地 Maven 仓库。

```bash
mvn install:install-file -Dfile=<path-to-file> -DgroupId=<group-id> -DartifactId=<artifact-id> -Dversion=<version> -Dpackaging=<packaging>
```
```bash
mvn install:install-file -Dfile=<path-to-source-file> -DgroupId=<group-id> -DartifactId=<artifact-id> -Dversion=<version> -Dpackaging=<packaging> -Dclassifier=sources
```

要让 Gradle 引入新依赖，请编辑根项目目录中的 build.gradle 文件，并修改 core 项目条目：
```gradle
project(":core") {
   ...

    dependencies {
        ...
        implementation "<group-id>:<artifact-id>:<version>"
        implementation "<group-id>:<artifact-id>:<version>:sources"
    }
}
```

之后需要刷新依赖，IDE 才能看到它，因此请运行：
Command line - `$ ./gradlew --refresh-dependencies`  
Eclipse - `$ ./gradlew eclipse`  
IntelliJ - `$ ./gradlew idea`  

另外不要忘记，以这种方式添加的依赖也必须加入 [GWT 继承文件](#gwt-inheritance)。

### 文件依赖
如果依赖尚未 Maven 化，仍然可以使用它！

为此，请在子项目对应的 `build.gradle` 文件的项目模板中找到 dependencies { } 部分，并添加以下内容：

```gradle
dependencies {
    implementation fileTree(dir: 'libs', include: '*.jar')
}
```

这会将 libs 目录中的所有 .jar 文件作为依赖引入。


**注意**：“dir”相对于项目根目录。如果将依赖添加到 android 项目，`libs` 应位于 android/ 目录中；如果添加到 core 项目，`libs` 应位于 core/ 目录中。

下面是一个更_完整_的脚本示例：
```gradle
project(":android") {
    apply plugin: "android"

    configurations { natives }

    dependencies {
        coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'
        implementation "com.badlogicgames.gdx:gdx-backend-android:$gdxVersion"
        implementation project(':core')

        natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-arm64-v8a"
        natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-armeabi-v7a"
        natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-x86"
        natives "com.badlogicgames.gdx:gdx-freetype-platform:$gdxVersion:natives-x86_64"
        natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-arm64-v8a"
        natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-armeabi-v7a"
        natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86"
        natives "com.badlogicgames.gdx:gdx-platform:$gdxVersion:natives-x86_64"
        implementation fileTree(dir: 'libs', include: '*.jar')
    }
}
```

需要注意的是，这些文件依赖不会包含在项目发布的依赖描述符中，但会包含在同一构建中的传递项目依赖里。

##### Android 陷阱
向项目（例如 core 项目）添加 `flat file` 依赖时，还需要在 android 项目中重复声明依赖。这是因为 Android Gradle plugin 目前[无法处理](https://code.google.com/p/android/issues/detail?id=186012)传递的 `flat file` 依赖。

例如，如果要将 `libs` 目录中的所有 jar 添加为项目依赖，需要执行以下操作。

```gradle
project(":core") {
   ...
   implementation fileTree(dir: '../libs', include: '*.jar')
   ...
}

// And also

project(":android") {
   ...
   implementation fileTree(dir: '../libs', include: '*.jar')
   ...
}
```

这只对 android 项目有要求，其他项目都能正常继承 `flat file` 依赖。

### GWT 继承
GWT 比较特殊。为了让 GWT 编译器知道项目依赖哪些模块并从哪些模块 _inherits_，需要明确告知它。

这需要在 gwt 子目录中的 `gwt.xml` 文件里完成。你需要同时修改 `GdxDefinition.gwt.xml` 和 `GdxDefinitionSuperdev.gwt.xml`。

**_默认的_ gwt.xml：**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE module PUBLIC "-//Google Inc.//DTD Google Web Toolkit trunk//EN" "http://google-web-toolkit.googlecode.com/svn/trunk/distro-source/core/src/gwt-module.dtd">
<module rename-to="html">
	<inherits name='com.badlogic.gdx.backends.gdx_backends_gwt' />
	<inherits name='MyGameName' />
	<entry-point class='com.badlogic.mygame.client.HtmlLauncher' />

	<set-configuration-property name="gdx.assetpath" value="../android/assets" />
</module>
```
我们依赖 libGDX gwt 后端和 core 项目，因此在 <inherits> 标签中定义了它们。使用上述方法添加依赖时，也需要在这里添加！

#### libGDX 扩展继承
以下是 gwt 支持的 libGDX 扩展。

* libGDX Core - `<inherits name='com.badlogic.gdx.backends.gdx_backends_gwt' />`
* Box2d       - `<inherits name='com.badlogic.gdx.physics.box2d.box2d-gwt' />`
* Box2dLights - `<inherits name='Box2DLights' />`
* Controllers - `<inherits name='com.badlogic.gdx.controllers' />` and `<inherits name='com.badlogic.gdx.controllers.controllers-gwt' />`
* Ashley      - `<inherits name='com.badlogic.ashley_gwt' />`
* AI          - `<inherits name='com.badlogic.gdx.ai' />`

### 库的依赖管理
如果你正在创建一个供他人通过 Gradle 引入项目的库，可能需要将 _implementation_ 关键字替换为 _api_。
使用 _api_ 声明的库依赖对所有依赖你的库的人可见且可用，而使用 _implementation_ 声明的依赖只能由你访问。
