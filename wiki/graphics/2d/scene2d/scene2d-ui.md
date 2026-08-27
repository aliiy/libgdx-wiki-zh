---
title: Scene2d.ui
---
## 概述

scene2d 是 libGDX 的 2D 场景图。其核心提供基本的 2D 场景图功能：Actor、Group、绘制、事件和 Action。这些功能足以供应用程序使用，但抽象层级相对较低。对于游戏这通常没有问题，因为大多数 Actor 都是应用特定的。构建 UI 时，scene2d.ui 包在 scene2d 之上提供了常见的 UI 控件和其他类。

继续之前，强烈建议阅读或至少浏览一下 [scene2d 文档](/wiki/graphics/2d/scene2d/scene2d)。

展示 Scene2d Actor、场景、Stage、Image 等内容的示例请参阅 [https://libGDXinfo.wordpress.com](https://libgdxinfo.wordpress.com/)。

  * [Widget 与 WidgetGroup](#widget-and-widgetgroup)
  * [布局](#layout)
  * [Stage 设置](#stage-setup)
  * [Skin](#skin)
  * [Drawable](#drawable)
  * [ChangeEvent](#changeevents)
  * [裁剪](#clipping)
  * [旋转与缩放](#rotation-and-scale)
  * [布局控件](#layout-widgets)
   * [Table](#table)
   * [Container](#container)
   * [Stack](#stack)
   * [ScrollPane](#scrollpane)
   * [SplitPane](#splitpane)
   * [Tree](#tree)
   * [VerticalGroup](#verticalgroup)
   * [HorizontalGroup](#horizontalgroup)
  * [控件](#widgets)
   * [Label](#label)
   * [Image](#image)
   * [Button](#button)
   * [TextButton](#textbutton)
   * [ImageButton](#imagebutton)
   * [CheckBox](#checkbox)
   * [ButtonGroup](#buttongroup)
   * [TextField](#textfield)
   * [TextArea](#textarea)
   * [List](#list)
   * [SelectBox](#selectbox)
   * [ProgressBar](#progressbar)
   * [Slider](#slider)
   * [Window](#window)
   * [Touchpad](#touchpad)
   * [Dialog](#dialog)
  * [不使用 scene2d.ui 的控件](#widgets-without-scene2dui)
  * [拖放](#drag-and-drop-draganddrop-class)
  * [不使用触摸或鼠标](#usage-without-touch-or-mouse)
  * [示例](#examples)

# Widget 与 WidgetGroup

UI 通常包含许多需要设置尺寸和位置的控件。手动完成这项工作耗时、难以阅读和维护，也不易适应不同屏幕尺寸。Layout 接口定义了用于更智能地布局 Actor 的方法。

Widget 和 WidgetGroup 类分别继承 Actor 和 Group，并且都实现 Layout。它们是参与布局的 Actor 的基础类。含有子 Actor 的 UI 控件应继承 WidgetGroup，否则应继承 Widget。

## 布局

UI 控件不会设置自身的尺寸和位置，而是由父控件设置每个子控件的尺寸和位置。控件会提供最小、首选和最大尺寸，父控件可以将其作为参考。一些父控件（例如 Table 和 Container）可以设置子控件尺寸和位置的约束。要在布局中指定控件尺寸，应保持控件的最小、首选和最大尺寸不变，而在父控件中设置尺寸约束。

每个控件绘制前都会先调用 `validate`。如果控件布局无效，将调用其 `layout` 方法，使控件（及其子控件）能够缓存当前尺寸下绘制所需的信息。`invalidate` 和 `invalidateHierarchy` 方法都会使控件布局失效。

当控件状态改变、需要重新计算缓存的布局信息，但控件的最小、首选和最大尺寸未受影响时，应调用 `invalidate`。这表示控件需要重新布局，但期望尺寸没有改变，因此不会影响父控件。

当控件状态改变并影响其最小、首选或最大尺寸时，应调用 `invalidateHierarchy`。这表示父控件的布局可能会受到控件新期望尺寸的影响。`invalidateHierarchy` 会对控件及其一路到根节点的所有父控件调用 `invalidate`。

## Stage 设置

大多数 scene2d.ui 布局都会使用一个尺寸等于 Stage 的 [table](/wiki/graphics/2d/scene2d/table)，所有其他控件和嵌套 Table 都放置在该 Table 中。

下面是使用根 Table 的最基本 scene2d.ui 应用示例：

```java
private Stage stage;
private Table table;

public void create () {
	stage = new Stage();
	Gdx.input.setInputProcessor(stage);

	table = new Table();
	table.setFillParent(true);
	stage.addActor(table);

	table.setDebug(true); // This is optional, but enables debug lines for tables.

	// Add widgets to the table here.
}

public void resize (int width, int height) {
	stage.getViewport().update(width, height, true);
}

public void render () {
	Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
	stage.act(Gdx.graphics.getDeltaTime());
	stage.draw();
}

public void dispose() {
	stage.dispose();
}
```

注意，根 Table 使用了 `setFillParent`，因此验证时会将其尺寸设置为父对象的尺寸（本例中为 Stage）。通常控件尺寸由父控件设置，不应使用 `setFillParent`。只有当控件的父对象不会设置子控件尺寸（例如 Stage）时，`setFillParent` 才是一个便利功能。

Table 会自动适应不同屏幕分辨率，因此上述代码设置的是使用像素坐标的 Stage。关于设置可缩放 Stage，请参阅 [Stage viewport 设置](/wiki/graphics/2d/scene2d/scene2d#viewport)。

## Skin

大多数 UI 控件由一些可配置资源组成：图像、字体、颜色等。绘制控件所需的全部资源称为“style”。每个控件都有自己的 style 类（通常是静态成员类），并提供用于设置初始 style 的构造函数，以及之后更改 style 的 `setStyle` 方法。

可以将 [libGDX 测试](https://github.com/libgdx/libgdx/tree/master/tests/gdx-tests-android/assets/data)中的 Skin 文件作为起点。需要使用：uiskin.png、uiskin.atlas、uiskin.json 和 default.fnt。这样可以快速开始使用 scene2d.ui，之后再替换 Skin 资源。

可以使用 JSON 或代码配置 style：

```java
TextureRegion upRegion = ...
TextureRegion downRegion = ...
BitmapFont buttonFont = ...

TextButtonStyle style = new TextButtonStyle();
style.up = new TextureRegionDrawable(upRegion);
style.down = new TextureRegionDrawable(downRegion);
style.font = buttonFont;

TextButton button1 = new TextButton("Button 1", style);
table.add(button1);

TextButton button2 = new TextButton("Button 2", style);
table.add(button2);
```

注意，同一个 style 可以用于多个控件。还要注意，UI 控件所需的所有图像实际上都是 Drawable 接口的实现。

Skin 类可以更方便地定义 UI 控件的样式和其他资源。更多信息请参阅 [Skin 文档](/wiki/graphics/2d/scene2d/skin)。即使不通过 JSON 定义样式，也强烈建议使用 Skin 以获得便利。

## Drawable

Drawable 接口提供一个接收 SpriteBatch、位置和尺寸的 draw 方法。实现可以绘制任意内容：纹理区域、精灵、动画等。控件中的各种图像广泛使用 Drawable。框架提供了绘制纹理区域、精灵、九宫格和纹理平铺的实现，也可以自行实现任意绘制方式。

Drawable 提供最小尺寸，可作为其绘制尺寸下限的参考。它还提供上、右、下、左四个尺寸，可作为 Drawable 上方所绘制内容周围应留多少内边距的参考。

默认情况下，NinePatchDrawable 使用对应九宫格纹理区域的上、右、下、左尺寸。不过，Drawable 尺寸与九宫格尺寸彼此独立。可以更改 Drawable 尺寸，使九宫格上绘制的内容比实际九宫格区域拥有更多或更少的内边距。

创建 Drawable 很常见，也有些繁琐。建议使用 [Skin 方法](/wiki/graphics/2d/scene2d/skin#conversions) 自动获取适当类型的 Drawable。

### ChangeEvent

大多数控件在发生变化时都会触发 ChangeEvent。这是一个通用事件，具体变化取决于控件。例如，按钮的变化是被按下，滑块的变化是位置改变，等等。

应使用 ChangeListener 检测这些事件：

```java
actor.addListener(new ChangeListener() {
	public void changed (ChangeEvent event, Actor actor) {
		System.out.println("Changed!");
	}
});
```

在可能的情况下，应使用 ChangeListener 而不是 ClickListener，例如处理按钮时。ClickListener 响应控件上的输入事件，只知道控件是否被点击。即使控件已禁用，ClickListener 仍可能检测到点击，而且它无法处理控件因按键或程序调用而发生的变化。此外，大多数控件的 ChangeEvent 都可以取消，使控件恢复变化前的状态。

### 裁剪

最简单的裁剪方式是在 Table 上使用 `setClip(true)`。Table 中的 Actor 会被裁剪到 Table 边界内，同时会执行剔除，使完全位于 Table 边界外的 Actor 不被绘制。

使用 Table 的 `add` 方法添加的 Actor 会获得一个表格单元，并由 Table 设置尺寸和位置。与其他 Group 一样，也可以使用 `addActor` 方法向 Table 添加 Actor，但 Table 不会以这种方式添加的 Actor 设置尺寸和位置。当 Table 仅用于裁剪时，这种方式很有用。

## 旋转与缩放

如[前文所述](/wiki/graphics/2d/scene2d/scene2d#group-transform)，启用变换的 scene2d Group 会在绘制子 Actor 前刷新 SpriteBatch。UI 通常有几十甚至上百个 Group，为每个 Group 刷新会严重限制性能，因此大多数 scene2d.ui Group 默认将 transform 设为 false。Group 禁用变换后，旋转和缩放会被忽略。

可以根据需要启用变换，但有一些注意事项。并非所有控件在旋转或缩放时都支持全部功能。例如，可以为 Table 启用变换，然后旋转和缩放它；子控件会随之旋转和缩放，输入也会正确路由。不过，其他控件绘制时可能不会考虑旋转和/或缩放。解决办法是将控件包裹在启用了变换的 Table 或 Container 中，并在 Table 或 Container 上设置旋转和缩放，而不是在控件上设置：

```java
TextButton button = new TextButton("Text Button", skin);
Container wrapper = new Container(button);
wrapper.setTransform(true);
wrapper.setOrigin(wrapper.getPrefWidth() / 2, wrapper.getPrefHeight() / 2);
wrapper.setRotation(45);
wrapper.setScaleX(1.5f);
```

注意，执行布局的 scene2d.ui Group（例如 Table）计算布局时，会使用经过变换控件未缩放、未旋转的边界。

执行裁剪的控件（例如 ScrollPane）使用 `glScissor`，而它使用与屏幕对齐的矩形。因此这些控件不能旋转。

如果许多 Group 启用变换导致 Batch 频繁刷新，可以将 `CpuSpriteBatch` 用于 Stage。它使用 CPU 执行变换，从而避免刷新 Batch。

## 布局控件

### Table

[Table 类](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Table.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Table.java)）使用类似 HTML 表格的逻辑表格设置子控件的尺寸和位置。Table 易于使用，功能也比手动设置控件尺寸和位置强大得多，因此 scene2d.ui 广泛使用 Table 布局控件。基于 Table 的布局不依赖绝对定位，因此能自动适应不同的控件尺寸和屏幕分辨率。

使用 scene2d.ui 构建 UI 前，强烈建议阅读 [Table 文档](/wiki/graphics/2d/scene2d/table)。

### Container

[Container 类](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Container.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Container.java)）相当于只有一个子控件的 Table，但更加轻量。Container 具有表格单元的全部约束，适合设置单个控件的尺寸和对齐方式。使用 Scene2D 开发时，如果调整对象内容的对齐和尺寸遇到困难，Container 可以带来更好的开发体验。虽然该类的优势通常在 Table 中最明显，但在 Table 之外的某些场景中也同样有用。

### Stack

[Stack](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Stack.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Stack.java)）是一个将每个子控件布局为自身尺寸的 WidgetGroup。需要将控件层叠在一起时很有用。首先添加的控件绘制在底部，最后添加的控件绘制在顶部。

### ScrollPane

[ScrollPane](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/ScrollPane.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/ScrollPane.java)）使用滚动条和/或鼠标、触摸拖动滚动子控件。控件大于 ScrollPane 时会自动启用滚动。如果控件在某个方向上小于 ScrollPane，则会在该方向调整为 ScrollPane 的尺寸。ScrollPane 提供了许多设置，用于控制触摸是否以及如何控制滚动、滚动条是否淡出等。ScrollPane 为背景、水平滚动条和滑块、垂直滚动条和滑块提供 Drawable。启用触摸（默认设置）时，所有 Drawable 都是可选的。

注意：ScrollPane 对拖动过程中动态改变尺寸或移动的子控件支持不佳。在 ScrollPane 中放置拖动时会移动的子控件，会导致 ScrollPane 闪烁。

### SplitPane

[SplitPane](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/SplitPane.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/SplitPane.java)）包含两个控件，并水平或垂直分成两部分。用户可以拖动分隔条调整控件尺寸。子控件始终填满 SplitPane 的对应半区。SplitPane 为可拖动分隔条提供 Drawable。

### Tree

[Tree](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Tree.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Tree.java)）显示节点层级。每个节点可以拥有子节点，并展开或折叠。每个节点都有一个 Actor，可以完全自由地决定各项的显示方式。Tree 为节点 Actor 旁的加号和减号图标提供 Drawable。

### VerticalGroup

[VerticalGroup](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/VerticalGroup.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/VerticalGroup.java)）相当于只有一列的 Table，但更加轻量。VerticalGroup 允许在中间插入和移除控件，而 Table 不支持。

### HorizontalGroup

[HorizontalGroup](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/HorizontalGroup.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/HorizontalGroup.java)）相当于只有一行的 Table，但更加轻量。HorizontalGroup 允许在中间插入和移除控件，而 Table 不支持。

## 控件

### Label

[Label](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Label.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Label.java)）使用位图字体和颜色显示文本。文本可以包含换行符。可以启用自动换行，此时 Label 的宽度应由父控件设置。文本行可以相互对齐，全部文本也可以在 Label 控件内对齐。

使用相同字体的 Label 尺寸相同，但颜色可以不同。位图字体通常不适合缩放，尤其是在较小尺寸下。建议为每种字号使用单独的位图字体。位图字体图像应打包到 Skin 的 atlas 中，以减少纹理绑定。

要创建包含不同颜色文本的标签，用于创建标签的 [BitmapFont](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/BitmapFont.html) 必须启用标记语言，方法是在通过构造函数传入的 [BitmapFont.BitmapFontData](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/BitmapFont.BitmapFontData.html) 对象中进行设置。如果使用 [AssetManager](/wiki/managing-your-assets)，可以在调用 `load` 时传入适当的 [BitmapFontParameter](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/assets/loaders/BitmapFontLoader.BitmapFontParameter.html) 对象来提供这些数据。

### Image

[Image](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Image.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Image.java)）只显示一个 Drawable。Drawable 可以是纹理、纹理区域、九宫格、精灵等，也可以通过多种方式在 Image 控件边界内缩放和对齐。

有关 Image 的使用教程（创建、旋转、调整大小以及使用重复纹理创建图像），请参阅 [Image 教程](https://libgdxinfo.wordpress.com/basic_image/)。

### Button

[Button](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Button.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Button.java)）本身只是一个空按钮，但它继承 Table，因此可以向其中添加其他控件。它有通常显示的 `up` 背景，以及按下时显示的 `down` 背景。它还有一个每次点击都会切换的 checked 状态；如果定义了 `checked` 背景，选中时会使用它代替 `up`。此外还有按下和未按下偏移量，用于偏移按钮的全部内容。

### TextButton

[TextButton](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/TextButton.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/TextButton.java)）继承 Button 并包含一个 Label。TextButton 为 Button 增加位图字体，以及 up、down 和 checked 状态下文本的颜色。

TextButton 继承 Button，而 Button 继承 Table，因此可以使用 Table 方法向 TextButton 添加控件。

### ImageButton

[ImageButton](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/ImageButton.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/ImageButton.java)）继承 Button 并包含一个 Image 控件。ImageButton 为 Button 增加 Image 控件在 up、down 和 checked 状态下使用的 Drawable。

注意，ImageButton 继承 Button，而 Button 已经为 up、down 和 checked 状态提供背景 Drawable。只有需要在按钮背景上方放置 Drawable（例如图标）时，才需要使用 ImageButton。

ImageButton 继承 Button，而 Button 继承 Table，因此可以使用 Table 方法向 ImageButton 添加控件。

### CheckBox

[CheckBox](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/CheckBox.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/CheckBox.java)）继承 TextButton，并在 Label 左侧增加 Image 控件。它为 Image 控件提供选中和未选中状态下的 Drawable。

### ButtonGroup

[ButtonGroup](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/ButtonGroup.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/ButtonGroup.java)）不是 Actor，也没有视觉表现。向其中添加按钮后，它会限制选中按钮数量的最小值和最大值，因此可以将按钮（Button、TextButton、CheckBox 等）用作“单选”按钮。

### TextField

[TextField](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/TextField.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/TextField.java)）是单行文本输入框。它为背景、文本光标和文本选择提供 Drawable，为输入文本以及文本框为空时显示的提示信息分别提供字体和字体颜色。可以启用密码模式，此时会以星号代替输入文本。

### TextArea

[TextArea](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/TextArea.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/TextArea.java)）类似 TextField，但允许输入多行文本。

### List

[List](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/List.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/List.java)）是显示文本项并突出显示选中项的列表框。List 提供字体、选中项背景 Drawable，以及选中和未选中项的字体颜色。List 不会自行滚动，但通常会放入 ScrollPane 中。

### SelectBox

[SelectBox](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/SelectBox.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/SelectBox.java)）是下拉列表，允许从列表中选择多个值中的一个。未激活时显示选中值，激活后显示可选值列表。SelectBox 提供背景、列表背景和选中项背景的 Drawable、字体和字体颜色，以及项目之间间距的设置。

### ProgressBar

[ProgressBar](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/ProgressBar.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/ProgressBar.java)）是用于直观显示某项活动进度或给定范围内变量值的控件。进度条有一个范围（min、max），以及所表示各个值之间的步进。完成百分比通常从空进度条开始，随着任务或数值接近上限逐渐填满。

进度条可以设置为水平或垂直方向，但递增方向始终固定。水平进度条向右增长，垂直进度条向上增长。可以为进度条数值变化启用动画，使其随时间更平滑地填充。

### Slider

[Slider](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Slider.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Slider.java)）是允许用户设置数值的水平指示器。Slider 有一个范围（min、max）以及所表示各个值之间的步进。Slider 提供背景、滑块，以及滑块前后部分的 Drawable。

禁用触摸、设置滑块前方 Drawable 并隐藏滑块的 Slider 可以替代进度条，因为两个控件共享相同代码并使用相同视觉样式。可以为 Slider 数值变化启用动画，使进度填充更平滑。


### Window

[Window](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Window.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Window.java)）是一个在内容上方带标题栏并显示标题的 Table。它可以选择作为模态对话框使用，阻止触摸事件传递给下方控件。Window 提供背景 Drawable，以及标题使用的字体和字体颜色。

### Touchpad

[Touchpad](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Touchpad.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Touchpad.java)）是屏幕上的摇杆，可在圆形区域内移动。它提供背景 Drawable，以及用户拖动的摇杆柄 Drawable。若想为摇杆元素实现“跟随模式”，请参阅[此处示例](https://github.com/libgdx/libgdx/issues/6688#issuecomment-962640273)。

### Dialog

[Dialog](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/ui/Dialog.html)（[代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/scenes/scene2d/ui/Dialog.java)）是一个包含内容 Table 和下方按钮 Table 的窗口。可以向 Dialog 添加任意内容，同时它提供便利方法，可向内容 Table 添加 Label，向按钮 Table 添加按钮。

## 不使用 scene2d.ui 的控件

不使用 Table 或 scene2d.ui 其余部分时，Widget 也可以作为 scene2d 中的普通 Actor 使用。Widget 有默认尺寸，也可以像其他 Actor 一样绝对定位。如果改变 Widget 的尺寸，必须调用 Widget 的 `invalidate` 方法，使其按新尺寸重新布局。

某些 Widget（例如 Table）构造后没有默认尺寸，因为其首选尺寸取决于将要包含的 Widget。添加 Widget 后，可以使用 `pack` 方法将控件的宽高设置为首选宽高。如果尺寸发生改变，该方法还会调用 `invalidate`，然后调用 `validate` 使控件调整到新尺寸。

## 拖放（DragAndDrop 类）
注意，要让 Table 成为拖动起始/源 Actor，并让 Table 及其全部内容触发拖动，必须启用 Table.setTouchable(Enabled)。默认设置为 ChildrenOnly。

## 不使用触摸或鼠标

Scene2d.ui 主要针对触摸或鼠标控制设计。Stage 提供 `setKeyboardFocus` 和 `setScrollFocus` 方法，用于设置接收滚动和键盘事件的 Actor。不过，它不支持完整的类型焦点，因此无法仅使用键盘操作。
为仅使用控制器或键盘操作的游戏设计界面时，需要焦点系统。[gdx-controllerutils 项目](https://github.com/MrStahlfelge/gdx-controllerutils)的 scene2d 模块包含一个向 scene2d.ui 添加此功能的 `ControllerMenuStage`。[查看文档](https://github.com/MrStahlfelge/gdx-controllerutils/wiki/Button-operable-Scene2d)。

## 示例

目前请参阅以下测试程序：

  * [UISimpleTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/UISimpleTest.java#L37)
 * [TableLayoutTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/TableLayoutTest.java#L35)
 * [UITest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/UITest.java#L50)
 * [ImageTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/ImageTest.java#L30)
 * [LabelTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/LabelTest.java#L34)
 * [ScrollPaneTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/ScrollPaneTest.java#L36)
