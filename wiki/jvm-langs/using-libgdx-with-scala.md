---
title: 使用 Scala 编写 libGDX
---

Scala 是一种运行于 JVM 的函数式、面向对象编程语言，可以与 Java 库、框架和工具无缝协作。它拥有简洁的语法和 REPL，使用体验类似脚本语言，但 Twitter、LinkedIn 等公司的关键任务服务器软件也在使用它。

Scala 开发者通常会选择 Gradle 或 SBT 作为构建工具。本教程介绍如何配置这两者以开始使用 LibGDX，你可以根据自己的偏好进行选择。

*由于 GWT 的工作方式，Scala 无法使用 HTML5 目标。*

# 使用 Gradle 编写 libGDX 和 Scala

更新：Gdx-Liftoff 提供了在新项目中启用 Scala 支持的选项，并会为你处理大部分配置。以下说明仅为保留历史参考。

使用 Gradle 时，gdx-setup.jar 工具创建的默认构建是最好的起点。对默认“空白” gdx 项目所需的修改可参见 [gdx-scala-demo](https://github.com/LOFI/gdx-scala-demo)。下面概述这些修改。

要支持 Scala 编译，需要对构建进行以下几项补充：

- <root>/gradle.properties
     - 增大 Gradle 使用的堆内存（否则为 iOS 编译时可能遇到问题）。
- <root>/build.gradle
     - 在 `project(":core")` 部分添加 Scala 插件：`apply plugin: "scala"`
     - 在依赖中加入 Scala 库：`compile "org.scala-lang:scala-library:2.11.12"`（Scala 2.12.* 需要 Java 8，但大多数 Android 设备不支持它）。
- <root>/core/build.gradle
     - 在文件顶部应用 Scala 插件。
     - **可选**设置 Scala 文件的源目录：`sourceSets.main.scala.srcDirs = [ "src/" ]`
- <root>/android/build.gradle
     - 在 `android` 部分（文件顶部）添加以下内容：
      ```gradle
      lintOptions {
           abortOnError false // make sure you're paying attention to the linter output!
      }

       // FIXME: How can we apply this simply for all builds? Copy-pasta makes me sad.
      buildTypes {
          release {
              minifyEnabled true
              proguardFile getDefaultProguardFile('proguard-android-optimize.txt')
              proguardFile 'proguard-project.txt'
          }
          debug {
              minifyEnabled true
              proguardFile getDefaultProguardFile('proguard-android-optimize.txt')
              proguardFile 'proguard-project.txt'
          }
      }
      ```
- <root>/android/proguard-project.txt
     - 为使 Proguard 正常工作，需要添加以下几行：

      ```
      -dontwarn sun.misc.*
      -dontwarn java.lang.management.**
      -dontwarn java.beans.**
      ```
     - 之后可能还需要将 `-dontwarn com.badlogic.gdx.jnigen.BuildTarget*` 修改为 `-dontwarn com.badlogic.gdx.jnigen.*`

完成这些修改后，就可以像平时一样从 shell 或常用 IDE 使用 Gradle。

# 使用 SBT 编写 libGDX 和 Scala

使用 Scala 的标准工具与 Java 开发者习惯的工具差异很大。[libgdx-sbt-project](https://github.com/ajhager/libgdx-sbt-project.g8) 项目提供了一条简单路径，让你可以使用标准构建工具和最佳实践开始 libGDX 与 Scala 开发。

本教程假设你已经安装了 [sbt](https://github.com/sbt/sbt) 0.13；Scala 社区使用它来生成项目并与项目交互。

## 设置新项目

在常用 shell 中输入：

    $ sbt new ajhager/libgdx-sbt-project.g8

填写项目相关信息后，就可以分别将游戏源文件和资源放入 common/src/main/scala 与 common/src/main/resources。

**注意**：上述设置可能无法用于 iOS 构建。如果想使用 MobiDevelop fork 的 RoboVM，则应使用：

1. 这个 [sbt-robovm fork](https://github.com/molikto/sbt-robovm)，目前需要自行对该插件运行 `sbt publish-local`。
2. 这个[项目模板 fork](https://github.com/Darkyenus/libgdx-sbt-project.g8)，并使用 sbt-robovm 和 RoboVM 2.3.0 版本。这样它会解析到已执行 `publish-local` 的插件。

 

## 管理项目

更新到最新库：

    $ sbt
    > update 

运行桌面项目：

    > desktop/run

将桌面项目打包为单个 jar：

    > assembly

在设备上运行 Android 项目：
  
    > android/start

有关 Android 配置和使用的深入指南，请参阅 [android-plugin](https://github.com/jberkel/android-plugin)。

在设备上运行 iOS 项目：

    > ios/device

有关 iOS 配置和使用的深入指南，请参阅 [sbt-robovm](https://github.com/ajhager/sbt-robovm)。

## 使用单元测试

运行 desktop、android 和 common 中的所有单元测试（子目录 src/test/scala）：

    > test

运行指定的一组单元测试：

    > common/test

## 与常用 IDE 一起使用

大多数情况下可以打开并编辑各个子项目（如 common、android 或 desktop），但仍需使用 SBT 构建项目。

各编辑器对应的 sbt 插件详情请参阅[这里](https://github.com/ajhager/libgdx-sbt-project.g8/wiki/IDE-Plugins)。

## 其他资源
[使用 libGDX 在 Scala 中开发游戏](https://web.archive.org/web/20140401024419/http://raintomorrow.cc/post/70000607238/develop-games-in-scala-with-libgdx-getting-started)
