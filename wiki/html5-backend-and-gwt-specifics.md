---
title: HTML5 后端和 GWT 特性
---
欢迎来到充满魔法与奇迹的万维网！尽管有人说互联网“只是一时风潮”，我们应该继续使用 usenet 和 gopher，但 WWW 至少拥有一样那些技术没有的东西：

## libGDX 游戏

没错！你可以制作自己的 libGDX 游戏，让它运行在支持 HTML5 的 Web 浏览器中，我想那应该是 Netscape Navigator 的某种高级形式。这要归功于 GWT，也就是 Google Web Toolkit！我知道你在想什么：Google？就是那个试图让人们通过表单搜索互联网的公司？他们怎么会参与 libGDX？我也不知道。如果想使用 GWT 将自己的 libGDX 游戏部署到 Web，只需在最新的 setup jar 中创建项目，并确保勾选 `Html` 复选框。其余步骤应该很简单！

**但一开始有时并不简单**

使用 GWT 开发与运行桌面项目有一些根本差异。尤其需要熟悉两个 Gradle 任务；如果不习惯命令行，可以从 IDE 启动这些任务，但当 IDE 无法正常工作时，命令行 Gradle 往往能避免问题。开发期间的主要工具是 `gradlew html:superDev`；它能显著改善调试体验，并快速重新加载 Java 代码的更改。`gradlew html:dist` 会生成功能完整的网页，可上传到静态 Web 主机（例如免费的 [itch.io](https://itch.io/developers) 或 [GitHub Pages](https://pages.github.com/)）；它还会优化网页，让其中的游戏运行得更好，因此 `dist` 比 `superDev` 稍慢。

## superDev

superDev 允许调试 HTML5 应用程序。大多数情况下不需要这样做：如果核心游戏存在问题，可以调试桌面应用程序。但有时错误只会在 HTML5 上运行时出现。可以按以下步骤调试应用程序：

* 运行 `html:superdev` Gradle 任务。它会编译游戏并设置本地 HTTP 服务器。完成后会保持空闲，以维持服务器运行。
* 你的游戏位于此处：[http://localhost:8080/index.html](http://localhost:8080/index.html)（当前配置），或 [http://localhost:8080/html/](http://localhost:8080/html/)（使用 Jetty 插件的旧版 Gradle 配置）。请使用 *Chrome* 打开页面进行调试。
* 点击大的重新加载按钮，然后点击编译。游戏会重新编译并设置源映射。
* 游戏重启后，按 F12 打开 Chrome 的开发者控制台，并切换到 Sources 选项卡。按 Ctrl-P，输入要调试的 Java 文件名。该 Java 文件会在 Chrome 的开发者控制台中打开，你可以设置断点并逐行执行 Java 代码。不过，调试变量会使用生成的 JS 名称，但仍然可以看懂其含义。
* 完成后，可以使用 Ctrl-C 停止 Gradle 任务。

如果错误不出现在 Chrome 中，而只出现在 Firefox 或 Safari 中，那就比较麻烦了，因为无法进行调试。但可以使用调试日志；为了避免堆栈跟踪难以阅读，还可以将以下内容添加到 HTML 项目的 `build.gradle` 中来关闭混淆：

```
gwt {
  // right below compiler.strict = true
  compiler.style = org.wisepersist.gradle.plugins.gwt.Style.DETAILED
}
```

## dist 信息

这应该很简单；dist 会生成在 `html/build/dist/` 中。如果不打算调试 dist，可以删除源映射文件；它们通常有几 MB，位于 `html/build/dist/WEB-INF/deploy/html/symbolMaps`。

## 全屏功能

令人意外的是，全屏功能确实能在 HTML 后端上工作。要启用全屏，请在核心项目中调用以下方法：

```java
Gdx.graphics.setFullscreenMode(Gdx.graphics.getDisplayMode());
```

系统会提示用户按“ESC”退出全屏，移动设备上也能工作。不过有一些注意事项：iOS 上无法激活全屏。此外，如果选择 HTML Launcher 中的“Resizable Application”选项，需要将 ResizeListener 改写为如下内容：

```java
class ResizeListener implements ResizeHandler {
    @Override
    public void onResize(ResizeEvent event) {
        if (Gdx.graphics.isFullscreen()) {
            Gdx.graphics.setFullscreenMode(Gdx.graphics.getDisplayMode());
        } else {
            int width = event.getWidth() - PADDING;
            int height = event.getHeight() - PADDING;
            getRootPanel().setWidth("" + width + "px");
            getRootPanel().setHeight("" + height + "px");
            getApplicationListener().resize(width, height);
            Gdx.graphics.setWindowedMode(width, height);
        }
    }
}
```

别忘了在 getConfig() 中为移动设备设置全屏方向：

```java
cfg.fullscreenOrientation = GwtGraphics.OrientationLockType.LANDSCAPE;
```

## 移动设备上的分辨率

在移动设备上，如果游戏运行在 iframe 中或切换到全屏，会发现画面出现像素化。这是因为移动设备报告的屏幕尺寸并非真实屏幕尺寸。可以通过 `config.usePhysicalPixels = true;` 启用真实屏幕尺寸。它也会影响桌面端的 HDPI 和 Retina 屏幕，因此可能希望使用 `usePhysicalPixels = GwtApplication.isMobileDevice()`。[此 PR](https://github.com/libgdx/libgdx/pull/5691) 提供了详细信息。

## 更改加载屏幕进度条

尽管我们都喜欢 libGDX，但准备 HTML 游戏时默认的加载进度条会显得非常“新手”。制作一个自定义进度条来给朋友留下深刻印象，也为家族争光吧！将以下内容添加到 HTML 项目中的 HtmlLauncher 类：

```java
@Override
public Preloader.PreloaderCallback getPreloaderCallback() {
    return createPreloaderPanel(GWT.getHostPageBaseURL() + "preloadlogo.png");
}

@Override
protected void adjustMeterPanel(Panel meterPanel, Style meterStyle) {
    meterPanel.setStyleName("gdx-meter");
    meterPanel.addStyleName("nostripes");
    meterStyle.setProperty("backgroundColor", "#ffffff");
    meterStyle.setProperty("backgroundImage", "none");
}
```

对于 DIST 构建，需要将图片 "preloadlogo.png" 放在 HTML 项目的 "webapp" 文件夹中；对于 SUPERDEV 构建，也要将图片放在 "war" 文件夹中。调整颜色以匹配游戏主题即可。

请注意，显示加载屏幕时只能使用纯 GWT 功能。预加载完成后才能使用 libGDX API。
{: .notice--primary}

## 加快预加载过程

说到预加载器：HTML5 预加载器是必要的，因为普通的 gdx 游戏依赖所有资源在需要时都已准备就绪。它会预取资源目录中的每个文件。如果游戏启动屏幕不需要所有资源，这个过程可能耗时且没有必要；还要考虑那些没有高速互联网连接的用户。

从 1.9.12 开始，如果使用 asset manager 延后加载资源，就能大幅缩短预加载时间。你可以在 GWT 上用自己的 AssetFilter 覆盖预定义的 `AssetFilter`，对于游戏开始前不需要的所有资源文件返回 `false`。请确保这些文件只通过 AssetManager 加载，否则使用这些资源时游戏会冻结。

```
public class AssetFilter extends DefaultAssetFilter {
    @Override
    public boolean preload(String file) {
        return !file.endsWith(".png") || file.startsWith("hud/");
    }
}
```

要让编译过程使用这个资源过滤器，请将以下配置添加到你的 `GdxDefinition.gwt.xml` 文件中：

      <set-configuration-property name="gdx.assetfilterclass" value="your.package.AssetFilter"/>

（[查看使用该功能的游戏源码提交](https://github.com/MrStahlfelge/SMC-libgdx/commit/b8d595376fe98a0ac55c1cf63f5f18c83c9afdfe)）

在 1.9.12 之前，可以使用[替代后端](https://github.com/MrStahlfelge/gdx-backends)。

## 防止按键触发滚动和其他浏览器功能

在普通网页中，按下键盘上的向下箭头会使页面向上滚动。这通常没什么问题，但玩家操控游戏角色时可能不希望发生这种情况。要阻止这一行为，需要让 libGDX 捕获特殊按键，从而阻止其默认操作：

```java
Gdx.input.setCatchKey(Input.Keys.SPACE, true);
```

## 防止右键上下文菜单

与键盘按键类似，也可以阻止右键上下文菜单打断游戏。你会注意到，现有函数已经可以防止左键执行意外操作。只需再添加一行，让右键也应用这项修复。必须将以下内容添加到 "html/webapp" 文件夹（dist）和 "html/war" 文件夹（superDev）中 index.html 的脚本块：

```javascript
// prevent right click
document.getElementById('embed-html').addEventListener('contextmenu', handleMouseDown, false);
```

## 声音和音乐

你可能会遇到声音和音乐方面的问题，尤其是在移动平台上。不建议在游戏启动时立即播放声音，因为浏览器很可能会阻止这一行为。

官方 HTML5 后端的实现还有一些限制。音调无法生效，声音首次播放时会出现延迟。如果想改善这种情况，可以[查看此 PR](https://github.com/libgdx/libgdx/pull/5659)。

## GWT 与桌面 Java 的差异

### 数字

* 当某个数字非常重要，需要确保它在桌面端/Android 和 GWT 上的处理完全一致时，请使用 `long`。
* 如果确定某个数字不会特别大（具体来说，不会因超过约 20 亿或低于负 20 亿而发生数值溢出），可以放心使用 `int`。
  * 在 GWT 上，使用 `int` 的运算比使用 `long` 快得多，因为每个 `int` 都表示为 JavaScript Number，而 Web 浏览器一直都擅长处理 Number。另一方面，每个 `long` 都表示为一种特殊的 JavaScript Object，其中存储三个 Number 以确保精度。
  * JavaScript Number，也就是 `int`，与 Java 中的 `double` 几乎相同，但还支持对其执行位运算。
    * 由于 Number 的行为类似 `double`，不会溢出，可以大于 `Integer.MAX_VALUE`（2147483647）或小于 `Integer.MIN_VALUE`（-2147483648）。对它们执行任何位运算，都会将过大的数字带回正常的 `int` 范围。如果遇到看起来远大于 int 范围的可疑数值，可以尝试这个简单技巧：`int fishy = Integer.MAX_VALUE * 5; int fixed = (Integer.MAX_VALUE * 5) | 0;` 在桌面端，添加 `| 0` 不会改变任何结果，但可以修正 GWT 上变得异常的数字。也可以使用 `long`。
* GWT 上的 `long` 值存在的问题是反射无法看到它们，因此 libGDX 的 Json 类不会自动读写它们。可以使用 Json 提供的自定义序列化器功能解决这个问题，所以影响并不大。
* 浮点数可能比平常更容易出现相等性检查问题。请始终使用 `MathUtils.isEqual()` 检查浮点数是否相等。

### 其他已知限制

* 不支持的 Java 类或功能：
  * System.nanoTime
  * Java 反射。只能使用 libGDX 反射工具，详情请参阅[此 wiki 页面](/wiki/utils/reflection#gwt)。
* 不支持多线程。
* 音频：
  * 1.9.12 之前未实现声音音调。可以使用基于 WebAudioAPI 且支持音调的[替代后端](https://github.com/MrStahlfelge/gdx-backends)。
  * 播放音乐或声音前，游戏需要先获得用户交互（例如点击按钮）。这是浏览器中运行的所有游戏都会受到的限制。
* TiledMaps 应使用 Base64 编码保存。
* Pixmap
  * 不支持某些 Pixmap 方法（例如从二进制数据加载）。
  * 某些绘制内容（例如线条）会进行抗锯齿，这并不总是符合需求。如果需要非抗锯齿线条，可以[逐像素绘制](https://github.com/libgdx/libgdx/issues/6019#issuecomment-702916344)，或使用 FrameBuffer 和 ShapeRenderer 实现。
* 使用的是 WebGL 1.0，与 OpenGL 或 GLES 相比有其自身的限制，包括：
  * NPOT（非二次幂）纹理不支持 MipMap 过滤器和/或 Repeat 环绕。
  * 在着色器中启用扩展前，应针对每个扩展调用 Gdx.graphics.supportsExtension(...)。
* 某些 libGDX 扩展不受支持，或需要额外的库：
  * Bullet
  * Freetype 需要 [gdx-freetype-gwt](https://github.com/intrigus/gdx-freetype-gwt)

## 延伸阅读

[Mario 编写的原始 Super Dev 指南](https://web.archive.org/web/20201028180932/https://www.badlogicgames.com/wordpress/?p=3073)

[如何加快 GWT 编译](https://www.gamefromscratch.com/post/2013/10/07/Speeding-up-GWT-compilation-speeds-in-a-LibGDX-project.aspx)

[为 libGDX 做贡献并向 gdx.gwt.xml 添加新文件](/dev/contributing/#considerations-for-gwt-compatibility)

[YouTube 上的 HTML5 - GWT 介绍](https://www.youtube.com/watch?v=I_85usDvJvQ)
