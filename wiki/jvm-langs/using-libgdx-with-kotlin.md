---
title: 使用 Kotlin 编写 libGDX
---
[Kotlin](https://kotlinlang.org) 是由 [JetBrains](https://www.jetbrains.com)（[IntelliJ IDEA](https://www.jetbrains.com/idea/) 的创建者）推出的现代静态类型 JVM 语言（Kotlin 也支持 Eclipse）。如果你使用过 C# 或喜欢它的特性，会因为 Kotlin 拥有许多 C# 特性而感到熟悉。

由于 GWT 的工作方式，Kotlin 无法使用 HTML5 目标。[TeaVM](https://github.com/konsoletyper/teavm) 是 GWT 的替代方案，支持 Kotlin 源文件。[libGDX 支持](https://github.com/xpenatan/gdx-teavm)仍在开发中，但已经可以构建并制作可在网页上运行的游戏。你可以在 Gdx-Liftoff 的平台菜单中启用它。

# Kotlin 语言简介

主要特性：

* null 安全类型（更多错误在编译期发现，而不是总在运行时发现）
* 高阶函数
* 运行良好的 Lambda（Java 实际上并没有闭包）
* 比 Java 更简洁的语法（分号可选；不需要 `new` 关键字）
* 扩展函数（类似 C#），可以通过静态方法扩展功能，例如创建 `"a string".myCustomFunction()`
* 字符串插值：`println("size is ${list.size} out of $maxElements")`
* 运算符重载
* 透明地面向 Java 6，不会像 Java 那样损失同等的语言特性，因此特别适合 Android。
* 与 Java 库以及项目中的其他 Java 源文件 100% 互操作，而且非常顺畅。还提供将现有 Java 代码转换为 Kotlin 的按钮。
* 属性：无需编写样板式 getter 和 setter
* 区间和区间运算符：`if (x in 0..10) println("in range!")`
* 内联方法，可以减少方法数量，也能优化使用 Lambda 的方法
* 以及更多特性，请参阅语言参考文档。

Kotlin 也不像其他一些语言那样强迫你采用特定写法。也就是说，你可以编写与 Java 非常相似的 Kotlin 代码（不使用 Lambda、不使用高阶函数、采用相同的类和面向对象设计等）。它是一种更务实的语言，而不是学术化或强制性的语言。

决定是否使用 Kotlin 以及学习这门语言时，请参阅 [Kotlin 语言参考文档](https://kotlinlang.org/docs/reference/)。也可以阅读 [Kotlin 与 Java 的比较](https://kotlinlang.org/docs/reference/comparison-to-java.html)。

# 将现有项目迁移到 Kotlin

本指南介绍如何将现有 libGDX 项目迁移到 Kotlin。你也可以从[全新应用](https://libgdx.com/dev/project-generation/)开始。

* [配置 Gradle](#configure-gradle)
  * [设置 Kotlin Gradle 插件](#set-up-the-kotlin-gradle-plugin)
  * [应用 Kotlin Gradle 插件](#apply-the-kotlin-gradle-plugin)
  * [配置依赖](#configuring-dependencies)
* [将代码从 Java 转换为 Kotlin](#convert-your-code-from-java-to-kotlin)
* [构建并运行](#build-and-run)
* [使用 Kotlin 的 libGDX 项目示例](#examples-of-libgdx-projects-using-kotlin)

## 配置 Gradle

更新：Gdx-Liftoff 提供了在新项目中启用 Kotlin 支持的选项，并会为你处理大部分配置。以下说明仅为保留历史参考。
{: .notice--warning}

这一步主要是遵循 [Kotlin 官方手册中的说明](https://kotlinlang.org/docs/reference/using-gradle.html)。

### 设置 kotlin-gradle 插件

将以下内容添加到父项目的 `build.gradle` 中：

```gradle
buildscript {
    ext.kotlinVersion = '<version to use>'

    dependencies {
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion"
    }
}
```

由于 Gradle 配置中很可能已经存在 `buildscript` 块，请只按需添加其中的子项。

### 应用 kotlin-gradle 插件

将所有 `apply plugin: "java"` 替换为 `apply plugin: "kotlin"`。检查父项目的 `build.gradle` 以及各个子项目（core、desktop、ios、android）。

在 android 子项目中，将 `apply plugin: "kotlin-android"` 添加到 `apply plugin: "android"` 行之后。

### 配置依赖

将 Kotlin 的 stdlib 添加到 core 项目的依赖列表中：

```gradle
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib:$kotlinVersion"
}
```

如果还打算使用 Kotlin 的反射功能，也请添加相应的库：

```Kotlin
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-reflect:$kotlinVersion"
}
```

#### IntelliJ IDEA 用户注意事项

如果让 IntelliJ IDEA 自动配置 `build.gradle`，并选择了 Kotlin 1.1 或更高版本，它可能会添加以下依赖：

```Kotlin
dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jre8:$kotlinVersion"
}
```

如果目标平台不支持 Java 8 库（例如大多数 Android 手机），项目将无法编译。你可能需要将其替换为 `kotlin-stdlib` 库。

## 将代码从 Java 转换为 Kotlin

不需要立即迁移全部或任何 Java 代码，两种语言可以完全互操作。

不过，如果决定将 Java 代码迁移到 Kotlin，IntelliJ IDEA 提供了方便的转换功能。

打开任意 Java 文件，例如 `DesktopLauncher`，然后从菜单中选择 *Code → Convert Java File to Kotlin File*。对所有想迁移的文件重复此过程。该功能仍处于早期阶段，无法保证完全没有错误，但能帮助你找到更符合 Kotlin 习惯的项目编写方式。转换后可能出现一些错误，尤其是某些 `Class<>` 的用法，以及无法推断空安全性的 Java 代码（因为 Java 缺少这类信息）。

## 构建并运行

至此，你已经成功在 libGDX 应用中启用了 Kotlin。构建并运行项目，确认一切正常。

## Kotlin libGDX 扩展

- [KTX](https://github.com/libktx/ktx) 是一组库，通过扩展函数、工具类等功能，让 libGDX 的大多数方面更符合 Kotlin 的使用习惯。它包含资源管理、libGDX 自定义集合、Box2D、协程、数学相关类、Actor、国际化、依赖注入、类型安全的 GUI 构建等工具。

# 使用 Kotlin 的 libGDX 项目示例

下面是一些使用 Kotlin 的项目示例，可以帮助你了解项目结构、语言特性的利用方式以及构建系统等基础内容。

* [Ore Infinium](https://github.com/sreich/ore-infinium)（桌面端，中等规模，使用 artemis-odb、kryonet、ktx、protobuf）
* [HitKlack](https://github.com/TobseF/hitklack)（桌面端和 Android，小型项目，包含用于说明 Kotlin 特性的代码示例）
* [SplinterSweets](https://github.com/reime005/splintersweets)（桌面端、Android、iOS（Multi-OS Engine），集成 Google Play Games 和 Admob，规模较小且简单）
* [Herring.io](https://github.com/czyzby/egu2016)、[Neighbourhood Watch](https://github.com/czyzby/egu-2016)（桌面端，由一个团队在 _EGU Jam 2016_ 中使用 [KTX](https://github.com/libktx/ktx) 于不到 30 小时内完成）
* [Horde!](https://github.com/czyzby/bialjam17)（桌面端，在不到 40 小时内制作，赢得 BialJam 2017）
* [BlockBunny](https://github.com/haxpor/blockbunny)（桌面端（支持控制器）、Android、iOS（Multi-OS Engine）；在 ForeignGuyMike 原始教程视频的基础上进行了优化、修改和改进）
* [OMO](https://github.com/haxpor/omo)（PC、Android 和 iOS（Multi-OS Engine）；在 ForeignGuyMike 原始项目的基础上进行了修改和改进）
* [Asteroids](https://github.com/haxpor/asteroids)（PC、Android 和 iOS（Multi-OS Engine）；支持游戏手柄，在 ForeignGuyMike 原始项目的基础上进行了修改和改进）
* [Unciv](https://github.com/yairm210/Unciv)（PC、Android；开源的《文明 V》Android/桌面端重制版）
