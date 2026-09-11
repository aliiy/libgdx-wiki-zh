---
title: 更新 libGDX
description: "更新 libGDX、其依赖项和 Gradle Wrapper 本身非常简单。请先打开项目根目录中的 build.gradle 文件。"
---
* [**切换 libGDX 版本**](#switching-libgdx-versions)
* [**更新 Gradle 本身**](#updating-gradle-itself)

# 切换 libGDX 版本
基于 Gradle 的 libGDX 项目可以很方便地切换 libGDX 版本。通常你会关注两类 libGDX 构建版本：

* 发布版：这些版本被视为稳定版。可在 [Maven Central](https://search.maven.org/search?q=g:com.badlogicgames.gdx%20AND%20a:gdx) 查看可用的发布版本。
* 每夜构建版：在 Maven 术语中也称为 SNAPSHOT 构建版。这些是 libGDX 的最新版本，每次源代码仓库发生更改都会构建。快照构建版的版本号形式为 `x.y.z-SNAPSHOT`，例如 `1.9.10-SNAPSHOT`。可在[这里](https://github.com/libgdx/libgdx/blob/master/gradle.properties#L8)找到最新的 SNAPSHOT 版本字符串。

基于 Gradle 的项目可以很方便地在发布版和每夜构建版之间切换。打开项目根目录中的 `gradle.properties` 文件，找到下面这一行：

```gradle
gdxVersion=1.12.1
```

你看到的版本可能高于 `1.12.1`。找到该字符串后，可以将其改为最新发布版、旧版或当前的 SNAPSHOT 版本。你可能还需要根据 libGDX 的变更日志更新其他版本和依赖项。编辑完成后，保存 `gradle.properties` 文件。

下一步取决于你使用的 IDE：

* **Eclipse**：在包资源管理器中选中所有项目，右键点击，然后选择 `Gradle -> Refresh All`。这会下载你在 `gradle.properties` 中指定的 libGDX 版本，并正确地将 JAR 文件连接到项目。
* **IntelliJ IDEA** / **Android Studio**：通常会检测到 `gradle.properties` 已更新并显示刷新按钮。点击该按钮，IDEA 就会将 libGDX 更新到 `gradle.properties` 中指定的版本。也可以进入 Gradle 任务面板/工具窗口并点击刷新按钮。运行类似 `builddependents` 的任务通常也能完成此操作。
* **NetBeans**：在“Projects”视图中右键点击最顶层的项目节点，然后选择“Reload Project”。所有子项目也会随新文件一起重新加载。
* **命令行**：调用任意任务通常都会检查依赖版本是否发生变化，并重新下载有变化的内容。

## 替换其他文件

某些版本可能需要替换其他文件，具体如下：

#### 更新到 1.9.13 及更高版本
从 1.9.13 开始，变更日志会明确说明破坏性变更及相应的迁移步骤，请查看[变更日志](/news/changelog/)。

#### 更新到 1.9.12

* HTML：可以删除 HTML 项目的 soundmanager 文件及 `index.html` 中的相关引用。
* HTML：应根据设置模板更新 HTMLLauncher 中的代码。

#### 更新到 1.9.6
* 替换 HTML 项目的 soundmanager 文件，否则 Web Application 可能无法启动。请参阅 [#2246](https://github.com/libgdx/libgdx/pull/4426)。

## Gradle Versions 插件

与 Maven Versions Plugin 类似，[Gradle Versions Plugin](https://github.com/ben-manes/gradle-versions-plugin) 提供了简单的 `dependencyUpdates` 任务，用于确定哪些依赖项有可用更新。

# 更新 Gradle 本身
你可能还希望更新 Gradle 版本。

## Gradle Wrapper
Gradle Wrapper（`./gradlew`）本质上是一个调用指定 Gradle 版本的脚本，必要时会先下载该版本。它是执行 Gradle 构建的推荐方式，因为无需复杂配置，任何开发者都能快速运行项目。也可以使用系统中安装的 Gradle。

要更新项目中内置（并存储在仓库中）的 Gradle Wrapper 版本，可以运行以下命令：

```
./gradlew wrapper --gradle-version #{GRADLE_VERSION}
```

其中 `#{GRADLE_VERSION}` 是你希望使用的 Gradle 版本。建议使用我们的设置工具在[此处](https://github.com/libgdx/libgdx/blob/master/extensions/gdx-setup/res/com/badlogic/gdx/setup/resources/gradle/wrapper/gradle-wrapper.properties#L3)指定的版本。

或者，也可以通过 URL 指定 Gradle 发行版（官方发行版请查看[这里](https://services.gradle.org)）：

```
./gradlew wrapper --gradle-distribution-url #{GRADLE_DISTRIBUTION_URL}
```

## 其他步骤
由于 Gradle 更新经常会引入破坏性变更，更新后可能需要额外步骤才能再次运行项目。通常建议使用 Gdx-Liftoff 重新创建项目结构，然后复制依赖项和代码。
