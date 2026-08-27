---
title: 光标可见性与捕获
---
## 捕获光标

对于第一人称射击游戏等，有时需要捕获光标，使其保持在屏幕中心，并只使用位置差旋转摄像机。有时则希望手动设置光标位置。这两种操作如下所示：

```java
Gdx.input.setCursorCatched(true);
Gdx.input.setCursorPosition(x, y);
```

光标捕获仅在桌面和 GWT 后端上可用，光标定位仅在桌面后端上可用。

## 自定义光标

可以按如下方式将光标更改为自定义图像。以下示例将这张 32×32 图像转换为光标：<a href="/assets/wiki/images/cursor-visibility-and-catching1.png?nomagnify" download="badcursor">![示例自定义光标图像](/assets/wiki/images/cursor-visibility-and-catching1.png)</a>

```java
Pixmap pixmap = new Pixmap(Gdx.files.internal("badcursor.png"));
// 将热点设置在图像中央（0,0 表示左上角）
int xHotspot = 15, yHotspot = 15;
Cursor cursor = Gdx.graphics.newCursor(pixmap, xHotspot, yHotspot);
pixmap.dispose(); // We don't need the pixmap anymore
Gdx.graphics.setCursor(cursor);
```

**注意：** 不再需要光标时，应对其调用 `dispose()`。

仅支持分辨率为 2 的幂的光标。例如，如果光标为 24×24，必须填充到 32×32。请记住，如果不考虑 HDPI 显示器，光标可能会显得很小。自定义光标仅在桌面和 GWT 后端上受支持。

## 系统光标

也可以将光标更改为其他系统光标之一。这仅适用于 LWJGL3、GWT 和 Android 后端。
可以按如下方式进行：
```java
Gdx.graphics.setSystemCursor(SystemCursor.Crosshair);
```

### 支持的系统光标

光标外观会因操作系统和用户偏好而异。下图来自 Ubuntu。出于版权考虑，不展示 Windows 和 macOS 的光标，但它们的外观相似。

将鼠标悬停在表格的每一行上，即可查看光标在自己系统上的外观。

<table>
	<tr>
		<th><code>SystemCursor</code></th>
		<th>外观</th>
		<th>说明</th>
	</tr>
	<tr style="cursor: default">
		<td><code>Arrow</code></td>
		<td><img alt="default cursor" src="/assets/wiki/images/cursor-visibility-and-catching2.png" width="24" height="24"></td>
		<td>默认光标</td>
	</tr>
	<tr style="cursor: text">
		<td><code>Ibeam</code></td>
		<td><img alt="text cursor" src="/assets/wiki/images/cursor-visibility-and-catching3.png" width="24" height="24"></td>
		<td>表示可以选择文本</td>
	</tr>
	<tr style="cursor: crosshair">
		<td><code>Crosshair</code></td>
		<td><img alt="crosshair cursor" src="/assets/wiki/images/cursor-visibility-and-catching4.png" width="24" height="24"></td>
		<td>用于比默认箭头光标更精确的操作</td>
	</tr>
	<tr style="cursor: pointer">
		<td><code>Hand</code></td>
		<td><img alt="pointer cursor" src="/assets/wiki/images/cursor-visibility-and-catching5.png" width="24" height="24"></td>
		<td>表示可以跟随超链接</td>
	</tr>
	<tr style="cursor: col-resize">
		<td><code>HorizontalResize</code></td>
		<td><img alt="ew-resize cursor" src="/assets/wiki/images/cursor-visibility-and-catching6.png" width="24" height="24"></td>
		<td>表示可以水平调整项目大小</td>
	</tr>
	<tr style="cursor: row-resize">
		<td><code>VerticalResize</code></td>
		<td><img alt="ns-resize cursor" src="/assets/wiki/images/cursor-visibility-and-catching7.png" width="24" height="24"></td>
		<td>表示可以垂直调整项目大小</td>
	</tr>
	<tr style="cursor: nwse-resize">
		<td><code>NWSEResize</code></td>
		<td><img alt="nwse-resize cursor" src="/assets/wiki/images/cursor-visibility-and-catching8.png" width="24" height="24"></td>
		<td>表示可以向内或向外调整项目角落的大小<br>
		<strong>macOS：</strong> 使用私有系统 API，未来可能失效<br>
		<strong>Linux：</strong> 使用较新的标准，并非所有光标主题都支持</td>
	</tr>
	<tr style="cursor: nesw-resize">
		<td><code>NESWResize</code></td>
		<td><img alt="nesw-resize cursor" src="/assets/wiki/images/cursor-visibility-and-catching9.png" width="24" height="24"></td>
<td>表示可以向内或向外调整项目角落的大小<br>
		<strong>macOS：</strong> 使用私有系统 API，未来可能失效<br>
		<strong>Linux：</strong> 使用较新的标准，并非所有光标主题都支持</td>
	</tr>
	<tr style="cursor: move">
		<td><code>AllResize</code></td>
		<td><img alt="move cursor" src="/assets/wiki/images/cursor-visibility-and-catching10.png" width="24" height="24"></td>
		<td>表示可以向所有方向滚动/平移</td>
	</tr>
	<tr style="cursor: not-allowed">
		<td><code>NotAllowed</code></td>
		<td><img alt="not-allowed cursor" src="/assets/wiki/images/cursor-visibility-and-catching11.png" width="24" height="24"></td>
		<td>表示禁止执行某项操作<br>
		<strong>Linux：</strong> 使用较新的标准，并非所有光标主题都支持</td>
	</tr>
	<tr style="cursor: none">
		<td><code>None</code></td>
		<td><div style="width: 24px; height: 24px"></div></td>
		<td>在不希望显示光标时将其隐藏，例如播放视频期间</td>
	</tr>
</table>

请注意，`NWSEResize` 及之后的光标是 libGDX 1.11.0 新增的，早期版本中不存在。

## 其他资源

如果希望 HTML5 游戏使用 libGDX 不支持的系统光标，以下资源是很好的起点：

* [CSS `cursor` 值](https://developer.mozilla.org/en-US/docs/Web/CSS/cursor#values)
* [与平台特定代码交互](https://libgdx.com/wiki/app/interfacing-with-platform-specific-code)
* [JSNI](http://www.gwtproject.org/doc/latest/DevGuideCodingBasicsJSNI.html)
