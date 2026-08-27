---
title: 使用 libGDX 与其他 JVM 语言
---
libGDX 主要是基于 Java 的框架。不过，由于 Java 会生成 Java 字节码，而虚拟机运行的正是这些字节码，因此只要具备良好的 Java 互操作性，就可以在任何 JVM 语言中运行 libGDX。

某些目标平台不能直接运行 Java 字节码，因此有更具体的编译要求。使用 Java 以外的语言可能会影响对这些平台的支持。

## 语言互操作指南

* [Clojure](https://clojure.org/reference/java_interop)
    * [使用 libGDX 与 Clojure](/wiki/jvm-langs/using-libgdx-with-clojure)
* [Kotlin](https://kotlinlang.org/docs/java-interop.html)
    * [使用 libGDX 与 Kotlin](/wiki/jvm-langs/using-libgdx-with-kotlin)
* [Scala](https://www.scala-lang.org/old/faq/4)
    * [使用 libGDX 与 Scala](/wiki/jvm-langs/using-libgdx-with-scala)
* [Python](https://jython.readthedocs.io/en/latest/JythonAndJavaIntegration/) (Jython)
    * [使用 libGDX 与 Python](/wiki/jvm-langs/using-libgdx-with-python)
* [Ruby](https://github.com/jruby/jruby/wiki/CallingJavaFromJRuby) (JRuby)

## 目标平台兼容性

### 桌面端

这开箱即用，因为桌面端 libGDX 后端使用计算机上安装的 JVM，通常是 OpenJDK 或 Oracle JDK。这两种 JVM 都支持多语言代码，因为它们运行的是 `.class` 文件，而不是 Java 源代码。

### Android

许多语言都可以这样使用，但有时也不可用。为了获得最佳结果，请在常用搜索引擎中搜索“[你选择的 JVM 语言] on Android”。

示例：

    * [适用于 Clojure 的 Lein-droid](https://github.com/clojure-android/lein-droid/wiki/Tutorial)
    * [适用于 Scala 的 SBT-Android](https://github.com/scala-android/sbt-android)
* [使用 IntelliJ IDEA 的 Kotlin 插件在 Android 上运行 Kotlin](http://blog.jetbrains.com/kotlin/2013/08/working-with-kotlin-in-android-studio/) Kotlin 完全支持 Android 和 Java 6，并可使用相同的代码库和功能集。

### iOS-ROBOVM

ROBOVM 后端是在 iOS 上执行 Java 字节码的 JVM。这应该可行，但尚未经过测试！

### HTML/GWT

由于 libGDX 使用 GWT，除 Java 外的 JVM 语言**无法使用 libGDX 的 HTML5 目标**。GWT 将 Java [转换](https://en.wikipedia.org/wiki/Source-to-source_compiler)为 JavaScript，而不是将 Java 字节码（`.class` 文件）转换为 JavaScript。造成这一点有几个原因，Google 员工在[这里](https://groups.google.com/d/msg/google-web-toolkit/SIUZRZyvEPg/OaCGAfNAzzEJ)进行了简要说明。

理论上，对于拥有自身 JavaScript 后端的 JVM 语言（例如 [Scala](https://www.scala-js.org/) 和 [Kotlin](https://kotlinlang.org/docs/tutorials/create-library-js.html)），可以解决这个问题。libGDX 项目的构建系统需要改为集成这些后端，而不是集成 GWT。

## 示例

许多人使用自己选择的 JVM 语言开发 libGDX。下面是一些示例。

* [Scala](https://github.com/ajhager/libgdx-sbt-project.g8)
* [Ruby](https://github.com/kabbotta/LibGDX-and-Ruby)
* [使用 Ruboto 在 Android 上运行 Ruby](https://github.com/ashes999/libgdx-ruboto)
* [Kotlin](/wiki/jvm-langs/using-libgdx-with-kotlin#examples-of-libgdx-projects-using-kotlin)

TODO（寻找一些近期示例，欢迎贡献！）


## 参考

https://web.archive.org/web/20201031162718/https://www.badlogicgames.com/wordpress/?p=2750
