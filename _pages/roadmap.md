---
permalink: /roadmap/
title: "路线图"
classes: wide2
header:
  overlay_color: "#000"
  overlay_filter: "0.45"
  overlay_image: /assets/images/roadmap.jpg
  caption: "图片来源：[**Slidebean**](https://unsplash.com/photos/iW9oP7Ljkbg)"

excerpt: "在这里，你可以进一步了解我们对 libGDX 未来的规划，以及即将到来的更新中值得期待的内容。"
---

<!--
Available status values:

{% include status.html is='planned' %} // is planned for the future
{% include status.html is='wip' %} // work in progress
{% include status.html is='close' %} // nearly done
{% include status.html is='done' %} //in the next release
 -->

这里列出了我们目前为 libGDX 规划的**主要特性和改进**的概览。由于我们都是在业余时间做这些事，所以没有给出任何具体的日期和期限——计划随时可能调整。如果你有兴趣为其中任何一项计划出一份力，欢迎到 [Discord](https://libgdx.com/community/discord/) 上联系我们！

还有许多其他改进正在进行中，它们或许因为不够大而没能列在这里，但同样值得关注。如果你想随时了解 libGDX 目前的动态，一定要阅读我们**定期发布的[进展报告](/news/devlog/)**。

<table>
  <tr>
    <td><h4>LWJGL 3 的 AWT 支持</h4>
    <br>目前，由于 GLFW 的一些限制，AWT 和 Swing 尚无法在 LWJGL 3 后端上使用。我们有一些绕过这一问题的思路，非常欢迎有人帮忙！<sup><a href="https://github.com/libgdx/libgdx/pull/6247">1</a>, <a href="https://github.com/libgdx/libgdx/pull/6772">2</a></sup></td>
    <td>{% include status.html is='planned' %}</td>
  </tr>
  <tr>
    <td><h4>Box2D 更新</h4>
    <br>2020 年 7 月，原版 <a href="https://github.com/erincatto/box2d">Box2D</a> 迎来了 6 年多以来的首次更新！我们正在努力把这些改动纳入 libGDX。<sup><a href="https://github.com/libgdx/libgdx/issues/5948">1</a>, <a href="https://github.com/libgdx/gdx-box2d">2</a></sup></td>
    <td>{% include status.html is='wip' %}</td>
  </tr>
  <tr>
    <td><h4>游戏主机支持</h4>
    <br>不少用户都探讨过 libGDX 的游戏主机支持这一话题。<sup><a href="/wiki/articles/console-support">1</a></sup></td>
    <td>{% include status.html is='planned' %}</td>
  </tr>
  <tr>
    <td><h4>几何/细分/计算着色器</h4>
    <br>我们非常想研究几何着色器、细分着色器和计算着色器。不过目前还不能作出任何承诺，因为这还只是一个遥远的设想。<sup><a href="https://github.com/libgdx/libgdx/pull/4963">1</a>, <a href="https://github.com/mgsx-dev/libgdx/tree/modern-shaders/compute">2</a></sup></td>
    <td>{% include status.html is='wip' %}</td>
  </tr>
  <tr>
    <td><h4>复兴 gdx-video</h4>
    <br>我们已经拟定了一些计划，来复兴旧的 <a href="https://github.com/libgdx/gdx-video">gdx-video</a> 扩展。首批快照版本现已发布！</td>
    <td>{% include status.html is='done' %}</td>
  </tr>
  <tr>
    <td><h4 id="teavm">兼容 Kotlin 的 Web 后端</h4>
    <br>与其他 JVM 语言兼容的 Web 后端已经讨论了好几年。现有的第三方方案基于 TeaVM 和 Bytecoder。<sup><a href="https://github.com/squins/gdx-backend-bytecoder">1</a>, <a href="https://github.com/Anuken/Arc/tree/6e9fd338866c05cd42ec20f26ec7fa7c3a25d6d5/backends/backend-teavm">2</a>, <a href="https://github.com/xpenatan/gdx-html5-tools">3</a></sup></td>
    <td>{% include status.html is='close' %}</td>
  </tr>
  <tr>
    <td><h4>TiledMap 扩展</h4>
    <br>我们的 TiledMap 实现还不够新，未达到我们期望的水平。因此，我们正在考虑把它迁移到独立的代码仓库，使其发布周期与 libGDX 分离，并评估它与 <a href="https://www.mapeditor.org">Tiled</a> 之外其他地图编辑器的兼容性。<sup><a href="https://github.com/libgdx/libgdx/issues?q=is%3Aissue+is%3Aopen+label%3Atilemap+">1</a>, <a href="https://github.com/libgdx/libgdx/pulls?q=is%3Apr+is%3Aopen+label%3Atilemap">2</a></sup></td>
    <td>{% include status.html is='wip' %}</td>
  </tr>
</table>

<br/>
最后更新：2025 年 6 月
