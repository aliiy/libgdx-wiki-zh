---
title: Google Summer of Code 2014
# 未列入目录
---

本页是 GSoC 2014 的一份 [RFC](https://en.wikipedia.org/wiki/Request_for_Comments)。
{: .notice--info}

## 简介
我们假设你已经知道 Google Summer of Code 是什么；如果不知道，请访问 [Google Summer of Code](https://www.google-melange.com/archive/gsoc/2013) 网站了解一般信息。

对于**学生**，建议先了解 libGDX，然后阅读[学生信息](/wiki/misc/google-summer-of-code-2014#Information_for_Students)章节。

*导师*必须阅读[导师信息](/wiki/misc/google-summer-of-code-2014#Information_for_Mentors)章节，在下方列表中的现有创意下添加自己的名字，并可选择创建和添加新创意。

## 什么是 libGDX？

[libGDX](https://libgdx.com) 是一个跨平台游戏开发框架。你使用 Java 编写游戏，即可让它立即运行在 Windows、Linux、Mac、[Steam](https://store.steampowered.com/app/207710)、[Android](https://play.google.com/store/apps/details?id=com.moistrue.zombiesmasher)、[iOS](https://itunes.apple.com/ph/app/clash-of-the-olympians/id590049663?mt=8)、[Facebook](https://www.facebook.com/stargazergame) 和 HTML/WebGL 上。所有这些平台共享完整的 Java 代码库。有关 libGDX 功能集的更多信息，请参阅[这里](https://libgdx.com/features/)。

libGDX 诞生于 3 年前，源于用单一代码库支持多个平台的愿望。此后它成长为一个大型 OSS 项目，拥有超过 [100 名专业和业余贡献者](http://www.ohloh.net/p/libgdx)，数千名开发者使用它来创造自己梦想中的游戏。从参加 48 小时 [Ludum Dare](http://www.ludumdare.com/) 挑战的[作品](http://www.ludumdare.com/compo/author/bompo/)，到[最畅销的移动游戏](https://play.google.com/store/apps/details?id=com.bithack.apparatus&feature=search_result#?t=W251bGwsMSwxLDEsImNvbS5iaXRoYWNrLmFwcGFyYXR1cyJd)，再到 [Google Ingress](https://play.google.com/store/apps/details?id=com.nianticproject.ingress&feature=search_result#?t=W251bGwsMSwxLDEsImNvbS5uaWFudGljcHJvamVjdC5pbmdyZXNzIl0) 这样的增强现实实验。

libGDX 已得到广泛采用，尤其是在 Android 上，它为[所有已安装应用的 3.2%](https://www.appbrain.com/stats/libraries/details/libgdx/libgdx) 提供支持，其中包括许多收入最高的游戏。在这一平台上，它已经可以与 Unity3D 竞争。

我们的[社区](https://libgdx.com/community/)和整个 libGDX 开发团队都期待你的加入。为数千个应用提供动力，为数百万用户带来欢乐！

## 学生信息
作为学生，你可能会问自己为什么应该参加 libGDX 的 Google Summer of Code 项目。这里提供一些思考方向，帮助你决定是否申请我们的项目。

libGDX 为学生提供探索多种技术的机会：

  * 不同的操作系统、平台和硬件（桌面端、Android、iOS、HTML5/WebGL）
  * 不同的语言（C、C++、Java、C#、Javascript）
  * 不同的软件开发领域（数据结构、2D 和 3D 图形、音频、外设通信等）

在许多大学环境中，这样广泛的技术环境通常很难得。

你将在全球分布式团队中工作，这种工作方式正变得越来越普遍。你将学会应对这类环境中的沟通困难：不同的时区、不同的语言能力（英语是团队通用语言，但并非所有人都是母语者），以及文本表达能力有限所造成的误解，都会影响团队的协作方式。

libGDX 是一个用于生产环境的工业级框架，每天有数百万用户游玩使用它开发的数千款游戏。修改 libGDX 代码意味着承担责任，并考虑修改对所有基于它构建的应用造成的影响。重大改动需要与团队讨论，学会提出充分、有力的论证非常重要。

最后，也许最重要的是，libGDX 代表游戏。许多 libGDX 团队成员正是因为想编写游戏才开始编程。如果你希望在游戏开发领域提升技能，那么 libGDX 就适合你。

### 步骤
下面的创意由 libGDX 贡献者和社区整理。如果想从中选择创意作为提案，或提出自己的创意，最好在开始准备提案前先了解 libGDX 及其底层技术。这样可以更准确地估算完成具体项目所需的工作。如果计划申请 libGDX 的 GSoC 项目，请遵循以下步骤：

  1. 在 [Github](https://www.github.com/libgdx/libgdx) 上 Fork 项目。
  2. 熟悉如何使用 [libgdx 源代码](/wiki/start/import-and-running)。
  3. 在论坛注册并介绍自己。访问 IRC（#libgdx、irc.freenode.org），了解社区。[这个论坛主题](https://web.archive.org/web/20200928221625/https://www.badlogicgames.com/forum/viewtopic.php?f=11&t=7889)是目前大多数 GSoC 学生自我介绍的地方，请订阅它以接收新消息通知。订阅按钮位于页面底部。
   4. 从下方选择一个项目创意，或提出自己的创意。使用我们的[学生申请模板]（FIXME (todo)）准备申请。你需要在 2013 年 4 月 22 日至 5 月 3 日期间，通过 [Google Summer of Code 2013 网站](http://www.google-melange.com/)提交申请，还需要签署[学生参与协议](http://www.google-melange.com/gsoc/document/show/gsoc_program/google/gsoc2013/student_agreement)。有关流程的更多信息，请阅读 [GSoC 常见问题](http://www.google-melange.com/gsoc/document/show/gsoc_program/google/gsoc2013/help_page)，这是必读内容！
  5. 通过 IRC（irc.freenode.org、#libgdx）或论坛联系下方列出的导师。
  6. 在 Github 上为你对 libGDX 修复的问题或完成的改进发送 pull request，并在申请中注明。选拔学生时，我们会优先考虑已证明能够与社区交流并阅读[贡献指南](https://libgdx.com/dev/contributing/)的人。

## 导师信息
由于导师承担相当多的责任，我（badlogic）希望将候选导师限制在贡献者范围内。当然也可以有例外。Nex 和我担任项目管理员，这一角色不同于导师。

担任导师意味着承诺；一旦同意成为导师，在我们向 GSoC 提交申请后就无法退出。

### 步骤
  1. 给我（badlogic）发送电子邮件。
  2. 改进或向下方列表添加新创意。
   3. 阅读 [GSoC 常见问题](http://www.google-melange.com/gsoc/document/show/gsoc_program/google/gsoc2013/help_page)，其中说明导师的所有义务。
   4. 阅读 [GSoC 导师手册](http://en.flossmanuals.net/GSoCMentoring/)，其中提供开展指导工作的建议。
  5. 我们在[这个主题](https://web.archive.org/web/20150920202444/http://www.badlogicgames.com/forum/viewtopic.php?f=23&t=8113)中组织导师活动。请订阅它，订阅按钮位于页面底部。
  6. 在论坛和 IRC 上关注学生，欢迎他们加入社区并向他们介绍社区情况。

## 创意列表指南
请使用以下格式提交创意：

   * **标题：**使用 `### 项目：标题`
   * **目标：**保持简短，可以概括性描述
   * **所需技能：**语言、平台等
   * **链接：**更多信息、论坛主题等
   * **潜在导师：**仅限贡献者

如果你不是贡献者，请将创意发布到[这个主题](https://web.archive.org/web/20200928221625/https://www.badlogicgames.com/forum/viewtopic.php?f=11&t=7889)（FIXME (todo)）。

请在每个创意后添加 `----` 作为分隔符。

## 创意

### 项目：应用内购买扩展
**目标**：创建一个 libGDX 扩展，使应用内购买尽可能支持更多平台。iOS 和 Android 是必须支持的平台，GWT/桌面端支持则更好。

**所需技能**：Java、C#、基本 iOS 知识（了解 Xamarin.iOS 更佳）、基本 Android 知识（FIXME (xamarin -> robovm)）

**链接**：[https://github.com/libgdx/libgdx/pull/146](https://github.com/libgdx/libgdx/pull/146) 核心贡献者提供的 API 草案

**导师**：[noblemaster](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[tamas](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：社交网络扩展
**目标**：创建一个 libGDX 扩展，以支持社交网络交互，例如获取好友列表。理想情况下应支持所有平台（桌面端、GWT、Android、IOS）。

**所需技能**：Java、C#、基本 iOS 知识（了解 Xamarin.iOS 更佳）、基本 Android 知识（FIXME (xamarin -> robovm)）

**导师**：[nex](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)、[tamas](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)

----

### 项目：RoboVM/iOS 后端

（FIXME：已完成？）
**目标**：创建一个基于 [RoboVM](http://www.robovm.org) 的 iOS libGDX 后端。

**所需技能**：Java、C/C++、OpenGL ES、iOS，可能还需要 LLVM

**链接**：[https://web.archive.org/web/20200426122040/https://www.badlogicgames.com/forum/viewtopic.php?f=23&t=7883](https://web.archive.org/web/20200426122040/https://www.badlogicgames.com/forum/viewtopic.php?f=23&t=7883) 介绍可能实现方式的说明。

**导师**：[noblemaster](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)

----
### 项目：Avian VM/iOS 后端
**目标**：创建一个基于 [Avian VM](http://oss.readytalk.com/avian/) 的 iOS libGDX 后端。

**所需技能**：Java、C/C++、ObjectiveC、OpenGL ES、iOS

**链接**：[https://web.archive.org/web/20200426122040/https://www.badlogicgames.com/forum/viewtopic.php?f=23&t=7883](https://web.archive.org/web/20200426122040/https://www.badlogicgames.com/forum/viewtopic.php?f=23&t=7883) 介绍 RoboVM 的可能实现方式，同样的方法也适用于 Avian VM。

**导师**：[noblemaster](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)

----

### 项目：通用 2D 关卡编辑器

**目标**：利用 libGDX 的 scene2d 创建可移植的 2D 关卡编辑器，支持创建任意关卡地图，并通过地图 API 加载。额外加分项是通过插件提供可扩展能力。

**所需技能**：Java、基本图形编程；了解 scene2d 或 OSGi 更佳

**链接**：[https://docs.google.com/document/d/1iNo5yB39-iXV10I2bxPHpuk84EoEpU7_L9HSuPKN5tE](https://docs.google.com/document/d/1iNo5yB39-iXV10I2bxPHpuk84EoEpU7_L9HSuPKN5tE) 我们希望包含的功能和需求简要草案。

**导师**：[nex](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)、[nate](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)、[bach](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)

----

### 项目：Oculus Rift 后端
*目标*：创建一个后端，让 libGDX 支持具有极低延迟的虚拟现实头戴设备 [Oculus Rift](http://www.oculusvr.com/)。我们可能需要为学生提供设备：要么购买，要么请求 Oculus 团队赞助。我们希望扩展现有后端，或专门为 Oculus Rift 编写新后端。该扩展可以将 libGDX 的应用领域拓展到艺术装置、科学可视化等非游戏领域。

**所需技能**：Java、C/C++、3D 编程（包括 GLSL 着色器）、线性代数

**链接**：[Oculus Rift 初次体验反应，仅仅因为很有趣 :)](https://www.youtube.com/watch?v=KJo12Hz_BVI)

**导师**：[xoppa](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[bach](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：XBox Kinect 扩展

**目标**：创建一个扩展，让用户能够在 libGDX 桌面项目中使用 Kinect。Kinect 可能需要由我们提供或通过赞助取得。扩展还应提供一个或多个演示，展示其工作方式和潜力。该扩展可以将 libGDX 的应用领域拓展到艺术装置、科学可视化等非游戏领域。

**所需技能**：Java、C/C++、3D 编程（包括 GLSL 着色器）、线性代数

**链接**：[OpenKinect，我们可以封装并公开其功能的库](http://openkinect.org/wiki/Main_Page)

*导师*：[xoppa](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：Leap Motion 扩展

**目标**：[Leap Motion](https://www.leapmotion.com/) 是一种新型控制器，可以追踪手部和手指的动作，让用户以更自然的方式与数字媒体交互（可以想象电影《少数派报告》中的场景）。本项目旨在创建一个扩展，让 libGDX 用户能够使用该设备。此外还应创建一组演示，展示扩展的使用方式及其整体潜力。该扩展可以将 libGDX 的应用领域拓展到艺术装置、科学可视化等非游戏领域。

设备需要由赞助方提供，或由学生/导师购买。设备计划在 5 月发货，可能会太晚。

这个创意最初由 Fisherman 在论坛提交。

**所需技能**：Java、游戏编程，可能还需要 Lua、JavaScript、Squirrel 等脚本语言

**链接**：
[Block54 Leap Motion 演示](https://www.youtube.com/watch?v=1x-eAvASIFc)
[Leap Motion 开发者信息](https://www.leapmotion.com/developers)

*导师*：[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、
[Xoppa](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：新 3D API 的实验性功能

**目标**：libGDX 的 3D API 目前由几位核心贡献者负责开发。我们希望探索一些实验性功能，包括但不限于：延迟渲染、不同的[阴影映射](https://en.wikipedia.org/wiki/Shadow_mapping)技术（尤其适合移动设备的技术）、[CPU 端蒙皮](https://en.wikipedia.org/wiki/Skeletal_animation)（可能需要修改 API）、针对移动 GPU 优化默认 über-shader，以及使用 [GPU 厂商](https://developer.qualcomm.com/mobile-development/development-devices/trepn-profiler)提供的工具分析并改进着色器、实现类似《战神 3》的[动态光照](https://developer.qualcomm.com/mobile-development/development-devices/trepn-profiler)。我们也欢迎其他更具实验性的功能。上述大多数工作用不满 3 个月即可完成，建议学生至少选择两项。

**所需技能**：Java、3D 编程（包括 GLSL 着色器）、线性代数

**链接**：[核心开发者关于新 3D API 的讨论](https://web.archive.org/web/20200928230726/https://www.badlogicgames.com/forum/viewtopic.php?f=23&t=7020)，具体主题的链接请参见上方目标描述。

*导师*：[xoppa](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[bach](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：改进 GDX Remote

**目标**：Gdx remote 允许在桌面端运行应用，并连接一个向应用发送输入事件的设备。这样无需将应用部署到设备上，就能在桌面环境中测试加速度计控制等功能。目前的实现非常初级。理想情况下，还希望以最低延迟将桌面端视频流传输到设备。

**所需技能**：Java、网络编程

**链接**：[包含当前实现视频的博客文章](https://web.archive.org/web/20200928224908/https://www.badlogicgames.com/wordpress/?p=1590)

**导师**：[nate](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[nex](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：WebSocket 支持

**目标**：libGDX 目前仅提供基础的网络支持（HTTP、TCP）。我们希望添加 WebSocket 支持，以便 HTML5 后端能够进行网络编程。这样就能实现类似 [Chrome World Wide Maze](http://chrome.com/maze/) 或 [Browser Quest](http://browserquest.mozilla.org/) 的项目。添加 WebSocket 支持需要修改当前网络 API，具体来说需要修改 Socket#getInputStream。

**所需技能**：Java、C#、网络编程、GWT

*链接*：[libGDX 网络 API 入口](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/Net.java)

*导师*：[tamas](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[nex](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：简化的 3D 物理 API 和 HTML5 实现
**目标**：libGDX 封装了 [bullet physics](http://bulletphysics.org/wordpress/)，这是一个 OSS 3D 物理库。目前 Bullet 扩展仅支持桌面端和 Android（iOS 支持待定）。我们希望创建一个简化的 3D 物理 API，可以参考 [Bullet 的 C-API](https://code.google.com/p/bullet/source/browse/trunk/src/Bullet-C-Api.h) 设计。这样也能基于 [ammo.js](https://github.com/kripken/ammo.js/) 或其他 JavaScript 3D 物理库，为 HTML5 后端创建实现。

注意，Box2D 已经在包括 HTML5 在内的所有平台上完整运行。这是通过在 HTML5 后端使用 JBox2D 实现的。对 Bullet 采用同样的方式似乎不太可行。

**所需技能**：Java、GWT

**链接**：参见上方目标中的链接。

**导师**：[xoppa](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：脚本支持

**目标**：libGDX 目前与 JVM 语言紧密耦合。脚本可以帮助游戏开发者快速验证创意，也能让技术美术更容易与游戏机制交互。可以创建一个跨平台脚本扩展。它不必提供针对 libGDX 的专用绑定，但应易于在所有支持的平台上集成和定制。JavaScript 似乎是最佳候选方案（例如桌面端使用 [Nashorn](http://openjdk.java.net/projects/nashorn/)、GWT 中使用原生 JavaScript、Android 上使用 [V8](https://code.google.com/p/v8/)、iOS 上使用 [JavascriptCore](http://trac.webkit.org/wiki/JavaScriptCore)；[Lua](http://www.lua.org/) 也可以作为选项）。最终结果应是一个让用户更容易在游戏中集成脚本的 libGDX 扩展。

这个项目可以与下面的高级游戏引擎项目合作完成。

**所需技能**：Java、C/C++，熟悉至少一种候选脚本语言

**链接**：参见目标描述中的链接

**导师**：[bach](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[tamas](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：高级游戏引擎

**目标**：对于没有游戏编程经验的人来说，libGDX 这个框架可能令人望而生畏。构建在 libGDX 之上的高级游戏引擎可以降低入门门槛。我们提议在 libGDX 之上构建一个高级 2D 游戏引擎。良好的 API 设计、文档和示例都是挑战的一部分。可以从 [Corona](https://coronalabs.com/product/)、[Flixel](http://flixel.org/)、[HaxePunk](https://github.com/HaxePunk/HaxePunk) 或 [Cocos2D](https://web.archive.org/web/20180818232745/http://www.cocos2d-iphone.org/) 等项目中获取灵感。我们也不排除 3D 引擎，但考虑到 Google Summer of Code 的时间限制，2D 引擎成功的机会更大。理想情况下，引擎应基于[组件/实体系统模式](https://gamadu.com/artemis/)。

这个项目可以与上面的脚本支持项目合作完成。

**所需技能**：Java、游戏编程，可能还需要 Lua、JavaScript、Squirrel 等脚本语言

**链接**：参见上方描述中的链接。

**导师**：[bach](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[tamas](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[nate](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors、[badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors

----

### 项目：命令行项目管理

（FIXME：已通过 Gradle 完成？）

**目标**：libGDX 项目通常以 Eclipse 为主要开发环境。虽然我们支持 [Maven](/wiki/articles/maven-integration) 以及其他 IDE 和开发环境，但集成并不够直接。由于 GWT 和 Android 在这方面属于相对次要的支持对象，Maven 存在一些问题。此外，Maven Android 和 GWT 项目与 IDE 的集成也不完善。除了 IDE 方面的问题，项目的打包和部署也可能很繁琐。我们希望开发一个命令行应用，用于创建新的 libGDX 项目、为各种 IDE 创建项目文件、创建 POM 和 Gradle 构建文件、自动更新依赖、移除和添加扩展，以及将应用打包并部署到已连接的设备。[Loom Engine](http://theengine.co/loom) 和 [Haxe NME](http://www.nme.io/developer/documentation/getting-started/) 提供了类似工具。

**所需技能**：Java、Maven、Gradle、Eclipse、IntelliJ、NetBeans
**链接**：[包含需求的 Google 文档](https://docs.google.com/document/d/1yy3Q5B0K06yz_Oool1ZCtavtSvASJa56lic_5Yg1C9c/edit?usp=sharing)

**导师**：
[tamas](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors#Tamas),[bach](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors), [nate](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors), [badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors)

----

### 项目：通过静态代码分析工具提高稳健性

**目标**：libGDX 用于生产环境，因此需要具备很高的稳健性。提高稳健性的一种方式是使用静态分析工具发现不良实践和错误。对 libGDX 这样规模的代码库进行分析是一项挑战。不仅代码规模是问题，游戏框架还可能依赖某些出于性能考虑的模式，而静态分析工具会错误地将其识别为问题。对于这个创意，我们希望探索如何利用静态分析工具提升 libGDX 的质量，以及如何将其整合到日常工作流中。无论使用哪种分析工具，都需要通过新增规则进行调整，以满足游戏框架的要求。

**所需技能**：Java、Maven、Gradle、Eclipse、IntelliJ、NetBeans

**链接**：[Wikipedia 上的静态分析工具列表](https://en.wikipedia.org/wiki/List_of_tools_for_static_code_analysis#Java)

**导师**：
[nate](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors), [badlogic](https://code.google.com/p/libgdx/wiki/GoogleSummerOfCode2013Mentors


（FIXME，或许可以在这里添加导师列表……不确定）
