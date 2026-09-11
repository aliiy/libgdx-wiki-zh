---
permalink: /dev/natives/
title: "构建 libGDX 原生库"
classes: wide
header:
  overlay_color: "#000"
  overlay_filter: "0.3"
  overlay_image: /assets/images/dev/dev.jpeg
  caption: "图片来源：[**Florian Olivo**](https://unsplash.com/photos/Ek9Znm8lQ1U)"

sidebar:
  nav: "dev"
---

{% include breadcrumbs.html %}

# 前置条件
构建原生库要稍微复杂一些。我们会为我们面向的所有平台构建原生库：

- Windows（32 位和 64 位）、Linux（arm32、arm64、x86_64）、macOS（arm64、x86_64）
- Android（armeabi-v7a、arm64-v8a、x86、x86_64）
- iOS（armv7、arm64、x86_64）

为此我们使用 [GitHub Actions](https://github.com/libgdx/libgdx/actions)，它在 Linux 主机上编译 Windows、Linux 和 Android 的原生库，在 mac 主机上编译 macOS 和 iOS 的原生库。如果你对幕后细节感兴趣，可以看看 [gdx-jnigen 项目](https://github.com/libgdx/gdx-jnigen)。

请注意，以下信息可能不是最新的。如果你想自己构建 libGDX 的原生库，请务必查看 GitHub 上我们实际使用的[构建配置](https://github.com/libgdx/libgdx/blob/master/.github/workflows/build-publish.yml)。
{: .notice--info}

# Linux 主机
你需要：

- 64 位 Linux 发行版（我们使用 Ubuntu 18.04）
- openjdk-7-jdk
- Ant 1.9.3+（必须在 PATH 中）
- Android NDK r13b（需设置 ANDROID_NDK 和 NDK_HOME 变量）
- Android SDK，包含最新的 targets（需设置 ANDROID_SDK 变量）
- 编译器
- gcc、g++、gcc-multilib、g++-multilib（64 位 Linux 编译器）
- mesa-common-dev、libxxf86vm-dev、libxrandr-dev、libx11-dev:i386（仅 jglfw 需要）
- mingw-w64（32 位和 64 位的 Windows 编译器）
- ccache（可选）
- lib32z1

# macOS 主机
你需要：

- JDK 8+
- XCode，通过 Mac App Store 获取
- 最新版 XCode 的命令行工具
- Ant 1.9.3+（必须在 PATH 中，可用 homebrew 安装）
- ccache（可选，可用 homebrew 安装）

# 编译
原生库的编译通过 Gradle 完成。

要编译 **macOS 和 iOS** 的原生库，请运行：

```
./gradlew jnigen jnigenBuildMacOsX64 jnigenBuildMacOsXARM64 jnigenBuildIOS
```

要编译 **Windows、Linux 和 Android** 的原生库，请运行：

```
./gradlew jnigen jnigenBuild
```

你也可以单独运行某个平台自己的任务，只构建该平台的原生库。例如只构建 Android 的原生库，只需运行 `./gradlew jnigen jnigenBuildAndroid`。运行 `./gradlew tasks` 可以查看所有可用任务的列表。
