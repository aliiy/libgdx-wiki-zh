---
title: "设置开发环境"
description: "在运行第一个 libGDX 项目之前，需要先设置开发环境。第一步是选择 IDE，常见选择包括 Android Studio、IntelliJ IDEA 和 Eclipse。"
redirect_from:
  - /dev/setup/
---

如果你第一次使用 libGDX，那么这里就是正确的起点。下面的步骤会详细说明如何运行你的第一个 libGDX 项目。

{% include setup_flowchart.html current='0' %}

开始使用 libGDX 前，需要先设置一个 IDE（集成开发环境）。它本质上是 Java 文件的编辑器，并能让 Java 应用开发更加方便。**如果已经安装 IDE，可以直接跳到下一[步](/wiki/start/project-generation)。**

Java 世界有许多不同的 IDE。它们各有优缺点，但最终都能完成工作，因此可以自由选择自己最喜欢的工具。

## （1）Android Studio
对于不仅想面向桌面、还想面向移动平台的新手，**我们推荐 Android Studio**。
{: .notice--info}

- JDK：由 Android Studio 提供
- IDE：[Android Studio](https://developer.android.com/studio)
- Android：开箱即用
- iOS：[RoboVM OSS IntelliJ plugin](https://mobivm.github.io)

## （2）IDEA
- JDK 17 或 21：有多种发行版可选，但 [Adoptium](https://adoptium.net/) 应该能满足需求
- IDE：[IntelliJ IDEA](https://www.jetbrains.com/idea/download/)（“Community”版本即可）
- Android：[Android SDK](https://developer.android.com/tools/releases/platform-tools)
- iOS：[RoboVM OSS IntelliJ plugin](https://mobivm.github.io)

## （3）Eclipse
- JDK 17 或 21：有多种发行版可选，但 [Adoptium](https://adoptium.net/) 应该能满足需求
- IDE：[Eclipse](https://www.eclipse.org/downloads/)
- Android：官方不支持，但可以尝试使用 [Andmore](https://projects.eclipse.org/projects/tools.andmore)，或折腾旧版 [ADT](https://marketplace.eclipse.org/content/android-development-tools-eclipse)
- iOS：[RoboVM OSS Eclipse plugin](https://mobivm.github.io)

## （4）其他 IDE
当然也可以使用其他 Java IDE，例如 NetBeans 或 Visual Studio Code。不过它们在 libGDX 社区中并不常见，如果遇到 IDE 特有的问题，可能较难获得帮助。
{: .notice--info}
- [NetBeans](https://netbeans.apache.org/download/index.html) 需要 NetBeans Gradle Plugin；Android 和 iOS 不受官方支持
- Visual Studio Code 需要扩展来支持 Java；请参阅 [Coding Pack for Java](https://code.visualstudio.com/docs/java/java-tutorial#_coding-pack-for-java)；Android 和 iOS 不受官方支持
- AIDE 仅支持运行 Android 10 或更早版本的设备上的 Android 开发；libGDX 的 JAR 文件可在[这里](https://repo1.maven.org/maven2/com/badlogicgames/gdx/)找到

## （5）不使用 IDE
也可以完全不使用 IDE 开发 libGDX 应用，只使用记事本或 [Vim](https://www.vim.org) 这样的简单编辑器。但这**不推荐**，因为 IDE 提供了代码补全和错误检查等便利功能。如果坚持这样做，libGDX 应用可以通过命令行构建和运行。
{: .notice--info}

- JDK 17 或 21：有多种发行版可选，但 [Adoptium](https://adoptium.net/) 应该能满足需求
- Android：[Android SDK](https://developer.android.com/tools/releases/platform-tools)
- 设置 ANDROID_HOME 环境变量，或使用 gradle.properties

<br/>

**现在已经有了开发环境，可以创建第一个 libGDX 项目。libGDX 提供了一个项目生成工具，会生成所有必要文件。请查看[这里](/wiki/start/project-generation)开始操作。**
