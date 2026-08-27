---
title: 获取帮助
---
当你遇到困难或 bug 时，[libGDX 社区](https://libgdx.com/community/)很乐意提供帮助，但也需要你的配合，让帮助过程尽可能顺利。

## 目录

* [先自行排查](#helping-yourself)
* [让我们更好地帮助你](#help-us-help-you)
* [标题](#title)
* [背景](#context)
* [相关性](#relevance)
* [问题描述](#problem-statement)
* [异常](#exceptions)
* [代码片段](#code-snippets)
* [可执行示例代码](#executable-example-code)
  * [示例资源](#example-resources)
  * [最简应用](#barebones-application)
  * [最简 SpriteBatch](#barebones-spritebatch)
  * [最简 Stage](#barebones-stage)
* [确实可执行](#actually-executable)
* [态度](#attitude)
* [格式](#formatting)

## 先自行排查

请先检查以下简短清单，确保没有错过容易找到的解决方案。

  * 你使用的是最新的 nightly build 吗？可以将 `build.gradle` 中的 `gdxVersion` 改为 [GitHub](https://github.com/libgdx/libgdx#readme) 上列出的 snapshot 版本。请先尝试这一点，因为问题每天都在修复。
  * 你读过 [wiki](/wiki/) 上的文档吗？查看 [Javadocs](https://javadoc.io/doc/com.badlogicgames.gdx) 和[源代码](https://github.com/libgdx/libgdx)也很有帮助（不要害羞！）。还可以在[测试](https://github.com/libgdx/libgdx/tree/master/tests/gdx-tests/src/com/badlogic/gdx/tests)中搜索特定类，查找示例代码。
  * 你在我们的 [Discord 服务器](https://libgdx.com/community/discord/)中搜索过相关问题吗？
  * 你在[问题跟踪器](https://github.com/libgdx/libgdx/issues?q=is%3Aissue)中搜索过相关问题吗？请务必搜索“所有问题”，而不只是“开放问题”。

**如果问题仍未解决，可以通过 [libGDX Discord](https://libgdx.com/community/discord/) 获取帮助。那里有很多活跃用户，其中任何一位都可能立即回答你的问题。**

否则，如果你想在[跟踪器](https://github.com/libgdx/libgdx/issues)上[提交新问题](https://github.com/libgdx/libgdx/blob/master/.github/CONTRIBUTING.md)，请继续阅读。

## 让我们更好地帮助你
如果你认为问题、错误或疑似 bug 与某个特定后端有关，请在问题中提供以下信息。如果你在 Discord 上提问，也请准备好这些信息。

**Android 后端问题**
 - **注意：**由于设备制造商造成的问题或驱动程序缺陷，Android 问题有时会更难处理。
  - 请在 bug 报告中提供设备名称和 Android 版本，以便我们尝试修复问题或为设备实现变通方案。

**桌面后端问题（LWJGL 2 和 3）**
  - 请列出操作系统及版本、架构，以及必要时的 OpenGL 版本。
  - 还请明确指出哪些后端存在该问题。

**iOS（RoboVM）后端问题**
  - 请列出 iOS 版本和出现问题的设备。

**GWT（WebGL）后端问题**
  - 请列出操作系统及版本和架构。
  - 请列出浏览器及浏览器版本。

提供这些信息可以大幅减少我们的工作量，也能显著提高问题得到解决或实现修复方案、变通方案的可能性。

## 标题

写一个清晰简短的标题。无法描述问题的标题（例如“请帮忙”），或包含全大写、感叹号等内容的标题，会大幅降低问题被阅读的可能性。

## 背景

描述你想要实现的目标。如果说明原因有助于回答问题，也请一并说明。如果某些解决方案不可接受，请列出它们及原因。

尽量只保留相关信息。如果不确定，可以加入额外信息；但如果内容很长，请另提供一份摘要。

## 问题描述

简洁地描述问题。说明你尝试过的每种方法，并分别解释预期结果和实际发生的情况。

如果做不到这一点，你很可能会被忽略。没人愿意猜测你的问题是什么，而且他们通常没有时间或耐心询问你一开始就应提供的信息。

## 异常

如果发生了异常，请包含完整的异常消息和堆栈跟踪。

通常，紧接在最深层（最靠近底部）的异常消息之后的第一行行号最为相关。如果这一行位于你的代码中，除了完整的异常消息和堆栈跟踪，还应包含该行及其上下各 1-2 行代码。

```
Exception in thread "LWJGL Application" com.badlogic.gdx.utils.GdxRuntimeException: java.lang.NullPointerException
	at com.badlogic.gdx.backends.lwjgl.LwjglApplication$1.run(LwjglApplication.java:111)
Caused by: java.lang.NullPointerException
	at com.badlogic.gdx.scenes.scene2d.ui.Button.setStyle(Button.java:155) <- **MOST IMPORTANT LINE**
	at com.badlogic.gdx.scenes.scene2d.ui.TextButton.setStyle(TextButton.java:55)
	at com.badlogic.gdx.scenes.scene2d.ui.Button.<init>(Button.java:74)
	at com.badlogic.gdx.scenes.scene2d.ui.TextButton.<init>(TextButton.java:34)
	at com.badlogic.gdx.backends.lwjgl.LwjglApplication.mainLoop(LwjglApplication.java:125)
	at com.badlogic.gdx.backends.lwjgl.LwjglApplication$1.run(LwjglApplication.java:108)
```

## 代码片段

代码片段通常不太有用。除非你明显误用了 API，否则大多数问题无法仅凭代码片段解决。代码片段往往只能让人模糊猜测可能出错的地方，而不是给出真正的答案。请改为提供**可执行示例代码**。

## 可执行示例代码

可以复制、粘贴并运行的示例代码是获得帮助的最佳方式。它能让帮助者立即看到问题，从而快速修改代码或修复 bug、验证修复并展示结果。无论如何，都需要编写可执行示例来正确测试、修复并验证问题。如果你无法自行调试和修复问题，提供可执行示例仍然能帮助大家。

创建可执行示例代码确实需要一些时间。你需要拆分应用，并在一个能复现问题的新最简应用中重建相关部分。很多时候，仅仅这样做就能找到问题；如果仍未找到，你也能更快获得帮助，而帮助者也有更多时间帮助其他人。

示例代码应完全包含在单个类中（必要时使用静态成员类），并且包含 main 方法，可以直接复制、粘贴并运行。不要使用 GdxTest，因为它无法直接复制、粘贴和运行。

有关如何制作可执行示例代码的更多信息，请参阅 [SSCCE](http://sscce.org/) 和 [MCVE](https://stackoverflow.com/help/minimal-reproducible-example)。

### 示例资源

可执行示例通常需要图像或声音文件等资源。如果帮助者必须下载你的专用资源，就会增加额外工作。最好使用 [libgdx 测试](https://github.com/libgdx/libgdx/tree/master/tests/gdx-tests-android/assets)中的资源，这样示例代码就可以直接粘贴到 `gdx-tests-lwjgl` 项目中运行。

编写可执行示例最简单的方法，是将下面的某个最简应用粘贴到 `gdx-tests-lwjgl` 项目中，然后仅使用[测试资源](https://github.com/libgdx/libgdx/tree/master/tests/gdx-tests-android/assets)修改它以展示问题。注意，测试资源由 `gdx-tests-lwjgl` 从 `gdx-tests-android` 项目引入。

### 最简应用

下面是一个简单的最简可执行应用，可以作为创建自己可执行示例代码的基础。

```java
import com.badlogic.gdx.*;
import com.badlogic.gdx.backends.lwjgl.LwjglApplication;
import com.badlogic.gdx.graphics.GL20;

public class Barebones extends ApplicationAdapter {
	public void create () {
		// your code here
	}

	public void render () {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		// your code here
	}

	public static void main (String[] args) throws Exception {
		new LwjglApplication(new Barebones());
	}
}
```

### 最简 SpriteBatch

这个最简应用使用 SpriteBatch 绘制来自 `gdx-tests-lwjgl` 项目的图像。

```java
import com.badlogic.gdx.*;
import com.badlogic.gdx.backends.lwjgl.LwjglApplication;
import com.badlogic.gdx.graphics.*;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;

public class BarebonesBatch extends ApplicationAdapter {
	SpriteBatch batch;
	Texture texture;

	public void create () {
		batch = new SpriteBatch();
		texture = new Texture(Gdx.files.internal("badlogic.jpg"));
	}

	public void render () {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		batch.begin();
		batch.draw(texture, 100, 100);
		batch.end();
	}

	public static void main (String[] args) throws Exception {
		new LwjglApplication(new BarebonesBatch());
	}
}
```

### 最简 Stage

这个最简应用包含一个 [scene2d](/wiki/graphics/2d/scene2d/scene2d) Stage，并使用 [scene2d.ui](/wiki/graphics/2d/scene2d/scene2d-ui) 绘制标签和按钮。它使用来自 gdx-tests-lwjgl 项目的 [Skin](/wiki/graphics/2d/scene2d/skin)。

```java
import com.badlogic.gdx.*;
import com.badlogic.gdx.backends.lwjgl.LwjglApplication;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.scenes.scene2d.Stage;
import com.badlogic.gdx.scenes.scene2d.ui.*;
import com.badlogic.gdx.utils.viewport.*;

public class BarebonesStage extends ApplicationAdapter {
	Stage stage;

	public void create () {
		stage = new Stage(new ScreenViewport());
		Gdx.input.setInputProcessor(stage);

		Skin skin = new Skin(Gdx.files.internal("skin.json"));
		Label label = new Label("Some Label", skin);
		TextButton button = new TextButton("Some Button", skin);

		Table table = new Table();
		stage.addActor(table);
		table.setFillParent(true);

		table.debug();
		table.defaults().space(6);
		table.add(label);
		table.add(button);
	}

	public void render () {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		stage.draw();
	}

	public void resize (int width, int height) {
		// Pass false to not modify the camera position.
		stage.getViewport().update(width, height, true);
	}

	public static void main (String[] args) throws Exception {
		new LwjglApplication(new BarebonesStage());
	}
}
```

## 确实可执行

如果你的可执行示例无法粘贴到 `gdx-tests-lwjgl` 项目并运行，那么它实际上就不是可执行示例。其他人不应为了运行它而修补你的代码，甚至不应替你添加 main 方法。

## 态度

乞求帮助或催促快速回答往往会令人反感，也会降低你获得帮助的可能性。保持礼貌，大家会在时间允许时回答你。如果你态度粗鲁，就会被忽略或得到同样粗鲁的回应。帮助你的人都很忙，只是出于善意免费提供帮助；他们不欠你什么，也没有义务关心你或你的问题。

## 格式

如果你花一点时间把帖子排版清楚，别人也更可能花时间回复。包括在适当位置使用大写字母，用段落区分想法，使用完整词语（而不是“u”“bcoz”等），将代码放入代码块等。如果英语不是你的母语，我们理解。无需道歉，只要尽力认真表达即可。
