---
title: "创建项目"
description: "libGDX 项目生成工具会处理创建 libGDX Gradle 项目所需的全部步骤。"
redirect_from:
  - /dev/project_generation/
  - /dev/project-generation/
---

要创建第一个项目并下载必要的依赖，libGDX 提供了一个项目生成工具。

{% include setup_flowchart.html current='1' %}

1. 下载 libGDX 项目生成工具（gdx-liftoff）。

    <a href="https://github.com/libgdx/gdx-liftoff/releases/latest" class="btn btn--success">Download gdx-liftoff</a>
2. 文件位于版本发布页面的 Assets 部分。下载以 `.jar` 结尾的文件。

3. 双击下载的文件。如果无法打开，请打开命令行工具，进入保存 `.jar` 文件的下载目录，并运行命令 <br>`java -jar gdx-liftoff-x.x.x.x.jar`。将 `x` 替换为下载的版本号，例如 `gdx-liftoff-1.12.1.12.jar`。
   <br>在 Linux 上，可能需要右键点击该文件，选择“Properties”，然后在“Permission”选项卡中勾选“Allow executing the file as program”。

随后会打开下面的设置界面，用于生成项目：

![Setup UI](https://github.com/libgdx/gdx-liftoff/raw/master/.github/screenshot.png){: style="width: 500px;" }

可以观看视频指南 <a href="https://youtu.be/VF6N_X_oWr0">GDX-Liftoff：libGDX 项目设置</a>，也可以继续按照以下步骤操作。

## 项目
需要填写以下参数：

* **PROJECT NAME**：应用程序名称。可以包含字母、数字、下划线和短横线，例如 `YourProjectName`<br>
* **PACKAGE**：代码所在的 Java 包，例如 `io.github.some_example_name`<br>
* **MAIN CLASS**：应用程序主游戏 Java 类的名称，例如 `Main`<br>

## 附加组件
点击 Project Options 按钮进入附加组件页面：

* **Platforms**：项目要支持的后端。所有项目都需要 Core，强烈建议选择 Desktop 进行测试。此外，请根据要支持的设备类型选择其他平台。<br>

**注意：**要为 iOS 编译游戏，需要 Xcode，而它仅可在 macOS 上使用！
{: .notice--info}

* **Languages**：除 Java 外要加入项目的语言（Groovy、Kotlin、Scala）。<br>
* **Extensions**：扩展 libGDX 功能的官方支持附加组件。
  * **[Ashley](https://github.com/libgdx/ashley)**：轻量级实体框架。<br>
  * **[Box2dlights](https://github.com/libgdx/box2dlights)**：使用 box2d 进行射线检测、使用 OpenGL ES 2.0 渲染的 2D 光照框架。<br>
  * **[Ai](https://github.com/libgdx/gdx-ai)**：人工智能框架。<br>
  * **[Box2d](/wiki/extensions/physics/box2d)**：Box2D 是一个 2D 物理库。<br>
  * **[Bullet](/wiki/extensions/physics/bullet/bullet-physics)**：3D 碰撞检测与刚体动力学库。<br>
  * **[Controllers](https://github.com/libgdx/gdx-controllers?tab=readme-ov-file#%EF%B8%8F-game-controller-extension-for-libgdx-version-2)**：用于处理控制器的库（例如 XBox 360 控制器）。<br>
  * **[FreeType](/wiki/extensions/gdx-freetype)**：可缩放字体，适合动态调整字体大小。但请注意，交叉编译到 HTML 目标时无法使用它。<br>
  * **Tools**：一组工具，包括粒子编辑器（2D/3D）、位图字体打包器和图像纹理打包器。<br>
* **Template**：定义要包含在项目中的基类。<br>

## 第三方
进入下一页面后会到达 Third-Party 页面。这里列出的是官方 libGDX 维护者未提供的附加扩展：

* **Search**：可以输入第三方库的名称或关键词来筛选列表。<br>
* **Show only selected**：使用此选项仅显示已选择的库，便于取消选择不再需要的库。<br>
* 如果要稍后添加扩展，请查看[此 Wiki 页面](/wiki/articles/dependency-management-with-gradle#libgdx-extensions)。<br>

## 设置
最后一个页面用于设置版本和其他选项：

* **libGDX Version**：项目中要包含的 libGDX 官方版本。最新稳定版本为 `{{ site.data.versions.libgdxRelease }}`。要使用最新更改和错误修复，请使用 snapshot 版本，可在 GitHub 上的 [README 文件](https://github.com/libgdx/libgdx#readme)顶部找到。请注意，snapshot 构建可能不稳定，并且可能包含破坏 API 的更改。<br>
* **Java Version**：用于构建项目的 Java 版本。<br>
  * 对大多数项目，推荐使用 `8`。<br>
  * 如果要支持旧版 Android 设备或 iOS，请使用 `7`。<br>
  * `11` 支持桌面端和 HTML。请注意，GWT（HTML5）仅支持 [Java 库的一个子集](https://www.gwtproject.org/doc/latest/DevGuideCodingBasicsCompatibility)。<br>
  * `22` 等最新 Java 版本仅支持桌面端。<br>
* **App Version**：项目中使用的游戏版本号。请参阅[语义化版本](https://semver.org/)。<br>
* **Add GUI Assets**：添加通用的 Scene2D UI skin。<br>
* **Add README**：添加包含占位文本的基础 README 文件。阅读 README 中的提示，了解有用的 Gradle 命令。<br>
* **Add Gradle Tasks**：添加项目生成后要执行的可选 Gradle 命令。<br>
* **Project Path**：项目的目标文件夹。<br>
* **Android SDK Path**：如果选择 Android 作为目标平台，必须在此提供其路径。<br>
  * Linux 默认路径：`~/Android/Sdk`<br>
  * Mac 默认路径：`~/Library/Android/sdk`<br>
  * Windows: `%LOCALAPPDATA%\Android\Sdk`<br>
  * 在 Android Studio 欢迎屏幕中点击“More Actions”，然后选择“SDK Manager”，即可查看其位置。<br>

## 生成项目
点击生成后，会显示项目摘要页面：

* 文件生成过程中的任何错误都会在此列出，并附带 stack trace。<br>
* 如果安装了 IntelliJ IDEA，可以直接在其中打开项目。<br>
* 点击“New Project”从头开始该过程。

## 项目结构
项目生成过程会创建一个目录，结构如下：

```
gradle.properties          <- global variables used to define version numbers throughout the project
settings.gradle            <- definition of sub-modules. By default core, desktop, android, html, ios
build.gradle               <- main Gradle build file
gradlew                    <- local Gradle wrapper
gradlew.bat                <- script that will run Gradle on Windows
local.properties           <- IntelliJ only file, defines Android SDK location

assets/                    <- contains your graphics, audio, etc.

core/
    build.gradle           <- Gradle build file for core project. Defines dependencies throughout the project.
    src/                   <- Source folder for all your game's code

lwjgl3/
    build.gradle           <- Gradle build file for desktop project. Defines desktop only dependencies.
    src/                   <- Source folder for your desktop project, contains LWJGL launcher class

android/
    build.gradle           <- Gradle build file for android project. Defines Android only dependencies.
    AndroidManifest.xml    <- Android specific config
    res/                   <- contains icons for your app and other resources
    src/                   <- Source folder for your Android project, contains android launcher class

html/
    build.gradle           <- Gradle build file for the html project. Defines GWT only dependencies.
    src/                   <- Source folder for your html project, contains launcher and html definition
    webapp/                <- War template, on generation the contents are copied to war. Contains startup url index page and web.xml

ios/
    build.gradle           <- Gradle build file for the iOS project. Defines iOS only dependencies.
    src/                   <- Source folder for your iOS project, contains launcher
```

## 什么是 Gradle？
libGDX 项目是 [Gradle](https://gradle.org/) 项目，这让依赖管理和构建变得容易得多。

Gradle 是一个**依赖管理**系统，因此可以轻松将第三方库引入项目，而不必手动下载。你只需要提供要包含在应用程序中的库名称和版本，这些都在 Gradle 配置文件中完成。添加、删除或修改第三方库的版本，只需修改配置文件中的几行内容。依赖管理系统会从中央仓库（本例中是 [Maven Central](https://search.maven.org/)）获取指定的库，并将其存储在项目之外的目录中。更多信息请参阅我们的 [wiki](/wiki/articles/dependency-management-with-gradle)。
{: .notice--info}

此外，Gradle 还是一个**构建系统**，可以帮助构建和打包应用程序，而不依赖特定 IDE。如果使用构建服务器或持续集成服务器，这一点尤其有用，因为这类环境通常没有可用的 IDE。构建服务器可以调用构建系统，并提供构建配置，让它知道如何为不同平台构建应用程序。有关部署应用程序的更多信息，请查看[这里](/wiki/deployment/deploying-your-application)。
{: .notice--info}

**现在可以[将项目导入 IDE 并运行](/wiki/start/import-and-running)了。**
