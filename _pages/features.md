---
permalink: /features/
title: "特性"
classes: wide2
header:
  overlay_color: "#000"
  overlay_filter: "0.4"
  overlay_image: /assets/images/features.jpg
  caption: "图片来源：[**Residual by Orangepixel**](https://store.steampowered.com/app/1290780/Residual/)"
excerpt: "libGDX 是一个 Java 游戏开发框架，它提供了一套统一的 API，可在所有受支持的平台上工作。"

intro:
  - excerpt: 'libGDX 是一个用 Java 构建的开源、跨平台游戏开发框架。与许多流行的编辑器式平台不同，libGDX 完全以代码为中心，让开发者能够对自己的游戏的方方面面进行细粒度的控制。它构建在疾速的 OpenGL 之上，可发布到桌面、HTML、Android 和 iOS 平台，是你探索从零开始实现的绝佳起点。'
feature_row:
  - image_path: /assets/images/features/crossplatform.jpeg
    title: "跨平台"
    excerpt: 'libGDX 只需一套 API 即可面向多种目标：**Windows、Linux（包括树莓派）、macOS、Android、iOS 和 Web**。开发者可以使用各种后端来访问宿主平台的能力，**而无需编写平台特定的代码**。所有平台上的渲染都通过 Open GL ES 完成。'
feature_row2:
  - image_path: /assets/images/features/reliable.png
    title: "久经考验"
    excerpt: 'libGDX 项目始于 [10 多年前](/history/)。多年来，libGDX 及其社区不断成熟：如今，libGDX 已是一个**[久经考验](/showcase/)的可靠框架**，拥有扎实的基础和文档。此外，基于 libGDX 构建的游戏数不胜数，其中许多都是开源的。'
    url: "/showcase/"
    btn_label: "看看这些项目"
    btn_class: "btn--primary"
feature_row3:
  - image_path: /assets/images/features/ecosystem.png
    title: "庞大的第三方生态"
    excerpt: 'libGDX 拥有非常庞大的第三方生态。众多[工具](/dev/tools/)和库为开发者省去了大量工作。[Awesome-libGDX](https://github.com/rafaskb/awesome-libgdx#readme) 是一个精心整理的以 libGDX 为中心的**库**清单，对于刚踏入 libGDX 世界的新人来说是一个很好的起点。'
    url: "https://github.com/rafaskb/awesome-libgdx"
    btn_label: "查看 Awesome-libGDX"
    btn_class: "btn--primary"
list1:
  - "[流式音乐播放](/wiki/audio/streaming-music)和[音效播放](/wiki/audio/sound-effects)，支持 WAV、MP3 和 OGG"
  - "可直接访问音频设备，进行 [PCM 采样播放](/wiki/audio/playing-pcm-audio)和[录音](/wiki/audio/recording-pcm-audio)"
list2:
  - "对[鼠标、键盘、触摸屏](/wiki/input/mouse-touch-and-keyboard)、[手柄](https://github.com/libgdx/gdx-controllers)、[加速度计](/wiki/input/accelerometer)、[陀螺仪](/wiki/input/gyroscope)和[指南针](/wiki/input/compass)的抽象"
  - "[手势检测](/wiki/input/gesture-detection)（识别点按、平移、快速滑动和双指缩放）"
list3:
  - "[矩阵、向量和四元数](/wiki/math-utils/vectors-matrices-quaternions)类；在可能的情况下通过原生 C 代码加速（如果你对此感兴趣，也可以关注我们的 [gdx-jnigen](/wiki/utils/jnigen) 项目）"
  - "[包围形状与包围体，以及用于拾取和剔除的 Frustum（视锥体）类](/wiki/math-utils/circles-planes-rays-etc)"
  - "[相交与重叠检测](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/Intersector.html)"
  - "[操控行为（Steering Behaviours）、队形运动、寻路、行为树和有限状态机](https://github.com/libgdx/gdx-ai)"
  - "常用的[插值器](/wiki/math-utils/interpolation)、各种[样条曲线实现](/wiki/math-utils/path-interface-and-splines)、凹多边形三角剖分器等等"
  - "2D 物理：为流行的 [Box2D 物理](/wiki/extensions/physics/box2d)引擎提供 JNI 封装（另见 [Box2DLights](https://github.com/libgdx/box2dlights)）。此外，你也可以看看 [jbump](https://github.com/implicit-invocation/jbump)，它是一个更简单的物理实现。"
  - "3D 物理：为 [Bullet 物理](/wiki/extensions/physics/bullet/bullet-physics)引擎提供 JNI 封装"
list4:
  - "适用于所有平台的[文件系统抽象](/wiki/file-handling)"
  - "简单直观的[资产管理](/wiki/managing-your-assets)"
  - "用于轻量级设置存储的[偏好设置](/wiki/preferences)"
  - "[JSON](/wiki/utils/reading-and-writing-json) 与 [XML](/wiki/utils/reading-and-writing-xml) 序列化"
  - "自定义的、[经过优化的集合类](/wiki/utils/collections)，支持原始类型"
list5:
  - "轻松集成[游戏服务](https://github.com/MrStahlfelge/gdx-gamesvcs)，例如 Google Play Games、Apple Game Center 等等。"
  - "用于[应用内购买](https://github.com/libgdx/gdx-pay)的跨平台 API。"
  - "第三方支持：Google 的 [Firebase](https://github.com/mk-5/gdx-fireapp)、[Steamworks API](https://github.com/code-disaster/steamworks4j)、[gameanalytics.com](https://github.com/MrStahlfelge/gdx-gameanalytics) 以及 Facebook 的 [Graph API](https://github.com/TomGrill/gdx-facebook)。"
  - "轻松集成 [AdMob](/wiki/third-party/admob-in-libgdx)"
list6:
  - "所有平台均可通过 [OpenGL ES 2.0/3.0/3.1/3.2](/wiki/graphics/opengl-es-support) 进行渲染"
  - a:
    title: "**底层 OpenGL 辅助工具：**"
    items:
      - "顶点数组和顶点缓冲对象"
      - "[网格（Mesh）](/wiki/graphics/opengl-utils/meshes)"
      - "[纹理](/wiki/graphics/2d/spritebatch-textureregions-and-sprites)"
      - "[帧缓冲对象](/wiki/graphics/opengl-utils/frame-buffer-objects)"
      - "[着色器](/wiki/graphics/opengl-utils/shaders)，可与网格轻松配合使用"
      - "[立即模式渲染](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/glutils/ImmediateModeRenderer.html)模拟"
      - "简单的[形状渲染](/wiki/graphics/opengl-utils/rendering-shapes)"
      - "自动进行软件或硬件 mipmap 生成"
      - "自动处理 OpenGL ES 上下文丢失"
  - b:
    title: "**高层 2D API：**"
    items:
      - "[正交相机](/wiki/graphics/2d/orthographic-camera)"
      - "高性能的[精灵（Sprite）](/wiki/graphics/2d/spritebatch-textureregions-and-sprites)批处理与缓存"
      - "[纹理图集](/wiki/graphics/2d/using-textureatlases)，支持去除空白边距。既可以[离线](/wiki/graphics/2d/packing-atlases-offline)生成，也可以[在运行时](/wiki/graphics/2d/packing-atlases-at-runtime)生成"
      - "[位图字体](/wiki/graphics/2d/fonts/bitmap-fonts)。既可以离线生成，也可以[从 TTF 文件加载](/wiki/extensions/gdx-freetype)"
      - "[2D 粒子系统](/wiki/graphics/2d/2d-particleeffects)"
      - "[TMX 瓦片地图支持](/wiki/graphics/2d/tile-maps)"
      - "[2D 场景图 API](/wiki/graphics/2d/scene2d/scene2d)"
  - c:
    title: "**强大的 UI 解决方案：**"
    items:
      - "基于场景图 API 的 [2D UI 库](/wiki/graphics/2d/scene2d/scene2d-ui)"
      - "大量[官方](/wiki/graphics/2d/scene2d/scene2d-ui#widgets)和第三方控件"
      - "完全支持[皮肤定制](/wiki/graphics/2d/scene2d/skin)；并提供用于创建 UI 皮肤的 [Composer](https://github.com/raeleus/skin-composer)"
  - d:
    title: "**高层 3D API：**"
    items:
      - "贴花（Decal）批处理，适用于 3D 公告牌或[粒子系统](/wiki/graphics/3d/3d-particle-effects)"
      - "Wavefront OBJ 和 MD5 的基础加载器"
      - "[3D 渲染 API](/wiki/graphics/3d/3d-graphics)，带有材质、动画和光照系统，并支持通过 fbx-conv 加载 FBX 模型"
      - "第三方对 [GLTF 2.0](https://github.com/mgsx-dev/gdx-gltf) 的支持"
      - "基础的 [VR 支持](/wiki/graphics/3d/virtual-reality)"
  - "第三方[后处理](https://github.com/crashinvaders/gdx-vfx)着色器效果"
list7:
  - "[Gdx.net](/wiki/networking)，用于简单的网络通信（TCP 套接字和 HTTP 请求）"
  - "跨平台的 [WebSocket 支持](https://github.com/MrStahlfelge/gdx-websockets)"
  - "常用的 Java 网络方案：[KryoNet](https://github.com/EsotericSoftware/kryonet) 和 [Netty](https://github.com/netty/netty)（Web 平台不支持）"

---
<link rel="stylesheet" href="/assets/css/aos.css" />

<div data-aos="fade-right" data-aos-anchor-placement="top-bottom">
{% include feature_row type="left" %}
</div>

<div data-aos="fade-left" data-aos-anchor-placement="top-bottom">
{% include feature_row id="feature_row2" type="right" %}
</div>

<div data-aos="fade-right" data-aos-anchor-placement="top-bottom">
{% include feature_row id="feature_row3" type="left" %}
</div>

# 随心所欲，任你发挥
_与许多流行的编辑器式平台不同，libGDX 完全以代码为中心，让开发者能够对自己的游戏的方方面面进行细粒度的控制。_

- **自由：** libGDX 为你提供了各种不同的工具和抽象，但你仍然可以深入到底层。libGDX 明白没有放之四海而皆准的解决方案，因此它不会强迫你使用特定的工具或编码风格：你想做什么，就尽管去做！
- **开源：** libGDX 采用 Apache 2.0 许可证授权，由社区维护，你可以[一探究竟](https://github.com/libgdx/libgdx)，看看一切是如何运作的。
- **Java：** libGDX 使用 Java，因此你可以受益于庞大的 Java 生态——强大的 IDE、开箱即用的 Git 支持、精细调校的调试器、性能分析器，以及大量久经考验的库和框架，还有丰富的资源和详尽的文档。

<br/>

# 功能齐全
_libGDX 开箱即用、面面俱到。放心编写 2D 或 3D 游戏，把底层细节交给 libGDX 处理。_
<div class="row">
  <div class="column">
    {% include list.html title="音频" items=page.list1 %}
    {% include list.html title="输入处理" items=page.list2 %}
    {% include list.html title="数学与物理" items=page.list3 %}
    {% include list.html title="服务集成" items=page.list5 %}
    {% include list.html title="文件 I/O 与存储" items=page.list4 %}
  </div>
  <div class="column">
    {% include list.html title="图形" items=page.list6 %}
    {% include list.html title="网络" items=page.list7 %}
  </div>
</div>

<br/>

# 还有……
**……一个很棒的社区！**你可以从友好的游戏与应用开发者[社区](/community/)获得支持，也可以使用社区成员创作的任何库和工具。今天就加入我们，开始制作你的第一款 libGDX 游戏吧！

<center><a href="/dev/setup/" class="btn btn--primary btn--large">开始使用！</a></center>

<style>
/* Clear floats after the columns */
.row:after {
  content: "";
  display: table;
  clear: both;
}

.column {
  float: left;
  width: 50%;
  padding-left: 15px;
  padding-right: 20px;
}

@media screen and (max-width: 600px) {
  .column {
    width: 100%;
  }
}
</style>

<script src="/assets/js/aos.js"></script>
<script>
  AOS.init({
    disable: window.matchMedia('(prefers-reduced-motion: reduce)').matches,
    once: true
  });
</script>
