---
title: 主机支持？
---
libGDX 的主机支持一直是争议很大的话题。本页概述如何让游戏运行在你喜欢的主机上，包括 Xbox、PlayStation 和 Nintendo Switch。

## 基本思路
让 libGDX 游戏运行在主机上的主要障碍是这些平台没有 JVM。要解决这一点，需要将代码转换为目标平台能够运行的语言，或以其他方式编译应用。相关思路可以参考 libGDX 的 Web 后端（使用 [GWT](https://www.gwtproject.org/) 将 Java 源代码转换为 Javascript）和 iOS 后端（使用 [RoboVM](https://github.com/MobiVM/robovm) 提前编译器）。

此外，还需要为目标设备提供绑定的自定义 libGDX 后端。

## 成功案例
过去有一些游戏成功采用了这种方式：
 - [Orangepixel 的游戏](https://www.orangepixel.net/category/games/)，通过转译为 C# 运行<sup><a href="https://web.archive.org/web/20231211232755/https://cdn.discordapp.com/attachments/348229413785305089/1154868391887245332/image.png">[1]</a></sup>
 - [Pathway](https://store.steampowered.com/app/546430/Pathway/)，使用 RoboVM 的自定义分支和 SDL 后端<sup><a href="https://www.reddit.com/r/NintendoSwitch/comments/npx21u/comment/h07ls1u/">[2]</a></sup>
 - [Slay the Spire](https://store.steampowered.com/app/646570/Slay_the_Spire/)，由 [Sickhead Games](https://www.sickhead.com/) 先移植到 C#，再移植到 C++<sup><a href="https://pbs.twimg.com/media/ETkH_QvXkAAD2N7?format=png">[3]</a></sup>

## 其他资源
如果你想研究 libGDX 的主机支持，下面的资源也可能有所帮助：
- **[Graal Native Image](https://www.graalvm.org/22.0/reference-manual/native-image/)** 可能会很有用
 - **GWT/[TeaVM](/roadmap/#teavm)** 生成的 Javascript 代码可以用于 UWP 应用；关于这种方案的讨论见[这里](https://web.archive.org/web/20200428040905/https://www.badlogicgames.com/forum/viewtopic.php?f=17&t=14766)和[这里](https://github.com/libgdx/libgdx/issues/5330)
 - **[IKVM](https://github.com/ikvm-revived/ikvm)**（libGDX[过去曾使用过](https://code.google.com/archive/p/libgdx/wikis/IOSWIP.wiki)）可能是另一种可行方案
 - Anuken's Ark 提供 **SDL 后端**[实现](https://github.com/Anuken/Arc/tree/master/backends/backend-sdl)；SDL 有可运行于 Nintendo Switch 的[移植版本](https://wiki.libsdl.org/Installation#nintendo_switch)
- TheLogicMaster 在 **[SwitchGDX](https://github.com/TheLogicMaster/SwitchGDX)** 中提供了可运行的 Nintendo Switch homebrew 后端，该后端使用 CodenameOne 的 [ParparVM](https://github.com/codenameone/CodenameOne/tree/master/vm) 的[自定义分支](https://github.com/TheLogicMaster/clearwing-vm)，将 Java 代码转译为 C++
- **TeaVM** 也可用于生成 C 代码，示例请参阅[这里](https://github.com/konsoletyper/teavm/blob/5a0c4183896f42ccfc8010c7a7dc2cceb5956c21/samples/benchmark/src/main/java/org/teavm/samples/benchmark/teavm/Gtk3BenchmarkStarter.java)
- **[mini2Dx](https://github.com/mini2Dx/mini2Dx)** 项目也通过其 [KAVA](https://viridiansoftware.com/software/kava) 转译器追求类似目标。
