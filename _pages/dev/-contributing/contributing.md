---
permalink: /dev/contributing/
title: "贡献指南"
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

为 libGDX 做贡献有多种形式：你可以[报告 issue](/dev/issues/)、在 [Discord](/community/) 上提供帮助、在 [Patreon](/funding/) 页面上赞助，以及向 GitHub 上的项目回馈[代码](https://github.com/libgdx/libgdx/)和[文档](/wiki/)。更多详情请查看 GitHub 上的 [CONTRIBUTING.md](https://github.com/libgdx/libgdx/blob/master/.github/CONTRIBUTING.md) 文件！

如果你想向项目提交代码，请花一点时间看看下面的贡献准则。

# 贡献准则
## API 修改与新增
如果你修改了某个公共 API，或者新增了一个 API，请务必把这些变更添加到仓库根目录下的 [CHANGES](https://github.com/libgdx/libgdx/blob/master/CHANGES) 文件中。

如果你想听听其他开发者的意见，可以在我们的 issue 跟踪器上打开一个 issue，提交 PR 并在 GitHub 上发起讨论，或者加入我们的官方 [Discord 服务器](/community/discord/)。

## 贡献者许可协议
libGDX 基于 [Apache 2.0 许可证](http://en.wikipedia.org/wiki/Apache_License)授权。在我们能够接受（大型）代码贡献之前，需要你签署我们的[贡献者许可协议](https://github.com/libgdx/libgdx/blob/master/CLA.txt)。只需把它打印出来，填好空白处，并将一份副本发送到 contact@badlogicgames.com，邮件主题为 `[libGDX] CLA`。

签署 CLA 之后，我们才能使用和分发你的代码。这是一份非独占许可，因此你保留对代码的全部权利。它是我们的一种保障，以防有人贡献了关键代码之后又决定将其收回。
{: .notice--info}

## 格式化
只要你参与编写 libGDX 的任何代码，我们就要求你使用我们的格式化工具。为了省去麻烦，我们已通过 [Spotless](https://github.com/diffplug/spotless) 把格式化工具集成到了构建系统中。这样你就可以在本地运行 `./gradlew spotlessApply` 来格式化文件，同时还能确保 PR 通过 GitHub Actions 自动完成格式化。

另外，你可以在[这里](https://github.com/libgdx/libgdx/blob/master/eclipse-formatter.xml)找到 Eclipse 格式化工具文件，它也可以导入到 IntelliJ IDEA 和 Android Studio 中。具体做法请参阅[官方文档](https://blog.jetbrains.com/idea/2014/01/intellij-idea-13-importing-code-formatter-settings-from-eclipse/)。

## 代码风格
libGDX 没有官方的编码规范，但我们坚持常见的 Java 风格，你也应当如此。

<div class="notice--warning" style="padding-left: 10px">
<b>请<u>不要</u>做以下任何事情：</b>
<ul>
  <li>标识符中使用下划线</li>
  <li><a href="https://en.wikipedia.org/wiki/Hungarian_notation">匈牙利命名法</a></li>
  <li>给字段或参数加前缀</li>
  <li>大括号另起一行</li>
</ul>
</div>

还有一些需要记住的注意事项：

- 创建新文件时，务必添加 Apache 文件头，示例见[这里](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/Application.java#L1-L15)
- 遵循你所修改文件中已有的代码风格
- 如果你创建了新类，请添加文档说明该类的用途和适用范围。对于显而易见的方法，则不必添加 javadoc。
- 如果你的类是线程安全的，请在文档中注明。libGDX 的类默认被假定为非线程安全，所以请务必注明。

## 兼容性
由于 libGDX 是跨平台的，在贡献代码时有些东西你必须避免。例如，GWT [并不支持所有的 Java 特性](http://www.gwtproject.org/doc/latest/RefJreEmulation.html)，Android [也不支持所有的桌面 JVM 特性](https://developer.android.com/studio/write/java8-support)。

### GWT 兼容性注意事项
如果某些 Java 特性在 GWT 上不受支持，就必须对它们进行模拟或避免使用。原生代码（`Matrix4`）同样需要进行模拟。模拟的示例见[这里](https://github.com/libgdx/libgdx/blob/master/backends/gdx-backends-gwt/src/com/badlogic/gdx/backends/gwt/emu/com/badlogic/gdx/math/Matrix4.java)。

<div class="notice--info" style="padding-left: 10px">
<b>GWT 上常见的限制包括：</b>
<ul>
  <li>格式化：不支持 String.format()。</li>
  <li>正则表达式。不过，我们提供了对 <a href="https://github.com/libgdx/libgdx/blob/master/backends/gdx-backends-gwt/src/com/badlogic/gdx/backends/gwt/emu/java/util/regex/Pattern.java">Pattern</a> 和 <a href="https://github.com/libgdx/libgdx/blob/master/backends/gdx-backends-gwt/src/com/badlogic/gdx/backends/gwt/emu/java/util/regex/Matcher.java">Matcher</a> 的基础模拟。</li>
  <li>反射。请改用 <a href="/wiki/utils/reflection">libGDX 反射</a>。</li>
  <li>多线程：GWT 支持 <a href="https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/utils/Timer.java">Timers</a>，但严格来说不支持线程。</li>
</ul>
</div>

对于添加到 libGDX 的每个新文件，你都需要判断它是否与 GWT 兼容，并在 [GWT 模块](https://github.com/libgdx/libgdx/blob/master/gdx/res/com/badlogic/gdx.gwt.xml)中**包含**或**排除**它。要包含一个类文件，需要在 `gdx/src/com/badlogic/gdx.gwt.xml` 文件中添加一个新条目。例如可以参考[这个 PR](https://github.com/libgdx/libgdx/pull/5018/files#diff-13b547f0d1b0872d60d67db4ca0b266d)。
如果新文件没有被添加到 `gdx/src/com/badlogic/gdx.gwt.xml`，就可能出现类似

```
[ERROR] Errors in 'jar:file:<...>'
      [ERROR] Line <line num>: No source code is available for type com.badlogic.gdx.graphics.g3d.environment.PointShadowLight; did you forget to inherit a required module?
[ERROR] Aborting compile due to errors in some input files
```

这样的错误。

## 性能注意事项
由于该框架的一部分目标平台是移动端和 Web 端，加之它是一个专注于游戏开发的框架，因此尽可能把性能做到极致非常重要。在移动平台上尤其如此：内存管理非常关键，所以我们在 libGDX 核心中不创建任何垃圾对象。

<div class="notice--info" style="padding-left: 10px">
<b>几条与性能相关的准则：</b>
<ul>
  <li>避免任何临时对象的分配</li>
  <li>不要制作防御性拷贝</li>
  <li>避免加锁；除非明确说明，libGDX 不是线程安全的。</li>
  <li>使用 libGDX 在 <a href="https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/utils">com.badlogic.gdx.utils</a> 包中提供的集合类，不要使用 Java 集合</li>
  <li>对每帧可能被调用数千次的方法，不要做参数检查</li>
  <li>必要时使用对象池，并尽可能避免把内部的对象池暴露给用户</li>
</ul>
</div>

## 代码改动的规模
为了降低引入错误行为的风险，同时提高你的 PR 被合并的机会，我们请你让 PR 保持小而聚焦。

- 提交的 PR 应专门用于解决 _某一个_ issue 或特性。混杂了多件事情的 PR 审查起来要困难得多，并且会被拒绝。
- 让代码改动尽可能小。

<br/>

# 其他开发资源
有几篇与为 libGDX 做贡献相关的 wiki 文章：

- [添加新的 keycode](/wiki/misc/adding-new-keycodes)
- [构建 bullet wrapper](/wiki/misc/building-the-bullet-wrapper)
- [发布流程](/wiki/misc/release-process)
