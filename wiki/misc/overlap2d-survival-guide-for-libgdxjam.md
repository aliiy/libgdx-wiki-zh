---
title: "#libGDXJAM 的 Overlap2D 生存指南"
# 不列入目录
---
如果你打算参加 #libGDXJAM，并正在考虑（或已经决定）选择 Overlap2D 编辑器作为主要工具，请继续阅读！

在本文中，我会以 Overlap2D 创作者的身份，尽可能详细地介绍如何与 O2D 协作并合理使用它！

# 入门

### 前置条件

  1. 确保已安装 JDK 1.8（运行 Overlap2D 需要它；你也可以同时安装 1.7 和 1.8）。
  2. 从我们的[网站](http://overlap2d.com/)下载编辑器。
  3. 创建一个舒适的工作目录。
  4. 准备一些测试资源（PNG 精灵），之后可以替换成自己的资源。
  5. 进一步了解 [Ashley](https://github.com/libgdx/ashley/wiki)（我们的运行时使用这种架构）。

### 使用 Overlap2D

使用 Overlap2D 通常包括以下几个步骤：
  1. 使用 [setup tool](http://bitly.com/1i3C7i3) 创建主要的 libGDX 项目。
  2. 在 Overlap2D 中创建空项目。
  3. 在编辑器中制作测试场景（导入一些图片并将内容放到场景中）。
  4. 将这些数据导出到 libGDX 项目的 assets 文件夹。
  5. 使用 overlap2d-libgdx-runtime 在游戏中渲染场景。

我可以继续长篇大论，让你读到厌烦；或者你也可以直接观看这个视频，了解完整的详细步骤：[https://www.youtube.com/watch?v=bhvHm2sM0qo](https://www.youtube.com/watch?v=bhvHm2sM0qo)

需要注意以下几点：
* 使用 setup app 时，点击 Third Party Extensions，从列表中选择 overlap2d，并确保选中 freetype 和 box2d 复选框。
* 对于本次 JAM，最好使用最新的运行时 0.1.2-SNAPSHOT（它不是默认值，请确保在 build.gralde 文件中设置该版本）。
* 创建 o2d 项目时，不必考虑多种分辨率和超大纹理。毕竟这只是一次 JAM。建议使用较小的摄像机世界尺寸（例如 800x480 或类似大小），并将每个世界单位的像素数设在 1-4 之间。


# 你要制作什么游戏？

先了解一下你的计划，这样才能更有针对性地提供帮助。

### 横版卷轴或跑酷游戏

如果你制作的是横版卷轴或跑酷游戏，也就是角色在背景上从左向右行走或奔跑，那么 Overlap2D 非常适合你。你可以创建背景、前景等多个图层，将树木和山脉等内容组合成组并放置在后方，再将主角（可能是一段动画）放在前方。为主角设置唯一标识符，诸如此类。
我们的[文档](http://overlap2d.com/documentation/)中还有关于这类用法的系列教程。

### 俯视平铺地图

这类游戏可以是塔防、策略或地牢游戏。此时，你需要让世界由 tile 组成。
确定要使用的 tile 图片（确保它们大小相同且为正方形），并将它们整齐地放在场景中的某处。为每个图片添加标签 "tile"。在上方面板找到网格大小，并将其设置为 tile 的尺寸（这样内容就会自动吸附到网格）。现在可以复制粘贴初始 tile，并将它们放到合适的位置。之后还可以添加 "wall" 或 "turret" 等标签，用来标识它们的行为，以及玩家能否穿过它们。当然，你还需要在代码中编写 System，根据这些标签执行相应逻辑。这里有一个我制作的示例项目 "Tower defense"，可以[查看](https://github.com/azakhary/thm)。

### 动态生成世界

如果你不希望预先制作完整地图，而是希望每次随机生成地图，可以制作一些预定义的世界 "chunks"，将它们转换为 composite items，放入 library，然后从 library 中随机加载并拼接起来。

### 我需要用它制作 UI

你的游戏本身可能比较特殊，不需要预定义的场景数据，也许所有内容都由代码生成，这完全没问题。但如果你想用 overlap2d 制作菜单、对话框和按钮，也同样可以做到。
在 overlap2d 中制作按钮很简单：选择按钮资源，右键并转换为按钮。这样会创建一个包含若干预定义图层的 composite。进入其中并将内容放到正确位置（例如 pressed 图层）。你可以直接在编辑器中测试按钮。
对话框可以使用 9patch 图片作为背景（按钮也一样）。如果没有 9patch 图片，可以直接在编辑器中创建：右键普通图片并选择 "Convert to 9patch"，然后在打开的对话框中进行设置。之后可以将所有按钮和文本转换为 composite items，并把对话框放入 library。最后，在代码中根据 library 数据创建 CompositeActor。（使用 resource manager 获取 VO 对象，再将其传给 CompositeActor 构造函数。）


# 技巧与窍门

* 如果需要在嵌套 item 中导航，最好的方法是使用辅助类 ItemWrapper。将 entity 包装进其中，然后使用 getChild 等方法进行导航。
* 如果有许多对象需要以相同方式运行（例如移动的云朵），最好给场景中的所有云朵添加相同的标签。然后使用 sceneLoader.addComponentsByTagName 方法为所有云朵添加 cloud component。接着创建一个 System 管理这组组件，让一个类负责处理你的 "cloud" 逻辑。
* 如果有一个需要独立逻辑的唯一对象（例如玩家），只需为它设置唯一 id，然后为其编写 IScript。Overlap2D 提供了用于 iScripts 的 System，可以使用 ItemWrapper 类将 IScript 附加到 item 上。IScript 是你编写的、实现特定接口的自定义类，确保它包含 init、act 和 dispose 方法。
* 也可以使用 entity engine 渲染 UI，只需将 UI 放到场景中即可。但如果需要让摄像机缩小并移动，最好为 UI 创建单独的 stage，并使用 CompositeActor 渲染它。
* 编写系统时，使用 Gdx.input 监视用户输入，它提供了你可能需要的一切，不必使用老式的事件监听器。
* 如果出现 composite 嵌套 composite、其中又嵌套 composite，并且内部还有各种物理形状和 body，最后它们全都行为异常，那么……别这样做。保持简单，一切就会正常工作 :-P
