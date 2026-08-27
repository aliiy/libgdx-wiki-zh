---
title: Java Development Kit 选择
---
 * [简介](#introduction)
 * [背景](#background)
 * [发行版](#distributions)
 * [版本](#versions)
 

注意：本 wiki 页面发布时，Java 22 是当前发布的 Java Development Kit（JDK）。

# 简介
每个项目至少需要使用一个 Java Development Kit（JDK）。它是项目代码所依赖的源头、根基或核心。
它是每个项目将使用的代码的源头、根基或核心。直接选择最新 JDK 可能很方便，但这可能在构建过程中带来挫败和困惑。本 wiki 将介绍不同的 JDK 版本和发行版。没错，发行版也各不相同！发行版由不同公司提供，可能包含基础 JDK 之外的额外功能。本页旨在消除对版本或发行版选择的困惑。


# 背景
#### 发行版
在 [Oracle](https://www.oracle.com/index.html) 更改许可模式之前，各供应商就已经提供了多种发行版。
许可证结构变化之前，就已经存在来自不同供应商的各种发行版，人们出于多种原因使用它们，例如使用不同的 Java Virtual Machine（JVM）变体来提升性能。这对个人开发者或公司开发者意味着什么？关于如何选择 JDK，有个好消息：存在可用于商业用途的免费开源发行版。它们会列在[发行版](#distributions)中。

* [Oracle - JDK Licensing - FAQs](https://www.oracle.com/java/technologies/javase/jdk-faqs.html) 
* [Lakesidesoftware - Article - 2019](https://www.lakesidesoftware.com/blog/java-did-what-understanding-how-2019-java-licensing-changes-impact-you)
* [Aspera - Article - 2019](https://www.aspera.com/en/blog/oracle-will-charge-for-java-starting-in-2019/)



#### 版本
随着许可模式的变化，[Oracle](https://www.oracle.com/index.html) 也更新了发布流程，
以更快速度纳入定期功能更新。JDK 开发团队的总体目标是推进
通过完成更大型的 Java Enhancement Proposals（JEP）([Valhalla](https://openjdk.java.net/projects/valhalla/)、
  [Panama](https://openjdk.java.net/projects/panama/))，并完成基础 JEP。作为大型 JEP 基础的相关小功能，例如 [Records](https://openjdk.java.net/jeps/384) 和
 [Sealed Classes](https://openjdk.java.net/jeps/360)，会在主要功能之间发布。
 
* [All JEPs](https://openjdk.java.net/jeps/0)


# 版本
由于 Java 所运行的平台各不相同，代码转换可能会遗漏某些功能，或无法将桌面端功能模拟到移动端或 Web。如果你针对特定平台开发，可使用的 Java 版本可能没有太多选择。作为开发者，也可能需要使用多个 JDK，以支持项目所需的功能和/或调试能力。下面列出的多数版本都提供长期支持（LTS）。热替换代码允许在运行时调试期间编译并替换代码。使用 Dynamic Code Execution Virtual Machine（DCEVM）可以增强这一功能。这是
它在技术上是一个独立发行版 [DCEVM](https://dcevm.github.io/)。一些开发者会使用 JDK 8 保持语言兼容性，使用 JDK 11 运行 DCEVM，并使用 JDK 14 进行打包。

注意：LTS（长期支持）

| 版本  | Desktop  | Android  | iOS   | HTML | DCEVM | ARM |说明 |
|:---:     |:---:     |:---:     |:---:  |:---: |:---:  |:---:|:---  |
| 7        |  X       |  X       | X     | X    | X     |     | 支持 Android 5/6
| 8        |  X       |  X       | X     | X    | X     |     | LTS - 兼容性最佳。支持 Android 7-12
| 9        |  X       |  X       |       | X    |       |     | 模块 - Oracle 更改许可模式。支持 Android 9-12
| 11       |  X       |  X       |       | X    | X     |     | LTS，支持 HTML 和 Android 11/12
| 15       |  X       |          |       |      |       |     | JPackage
| 16       |  X       |          |       |      |       |     | 
| 17       |  X       |  X       |       |      |       |     | LTS，支持 Android 13/14
| 18       |  X       |          |       |      |       |     | 
| 19       |  X       |          |       |      |       |     | 
| 20       |  X       |          |       |      |       |     | 
| 21       |  X       |          |       |      |       |     | LTS
| 22       |  X       |          |       |      |       |     | 

在这些版本中，建议使用 LTS 版本和发行版。这样，JDK 出现的问题可以由参与 JDK 维护的公司修复或提供支持。

# 发行版 #
JDK 发行版信息可在这里找到：[sdkman.io - JDKs](https://sdkman.io/jdks)。
