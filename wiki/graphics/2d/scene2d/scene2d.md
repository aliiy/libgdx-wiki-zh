---
title: Scene2d
---
## 概述

scene2d 是一个 2D 场景图，通过 Actor 层级构建应用程序和 UI。如果要了解 scene2d 的 UI 组件，请参阅 [Scene2d.ui](/wiki/graphics/2d/scene2d/scene2d-ui)。

Scene2d 示例（Image、Label 等）请参阅 [https://libgdxinfo.wordpress.com](https://libgdxinfo.wordpress.com/basic_action/)。

它提供以下功能：

  * Group 的旋转和缩放会应用于所有子 Actor。子 Actor 始终在自己的坐标系中工作，父对象的变换会透明地应用。

  * 通过 [SpriteBatch](/wiki/graphics/2d/spritebatch-textureregions-and-sprites) 简化 2D 绘制。每个 Actor 都在自身未旋转、未缩放的坐标系中绘制，其中 0,0 是 Actor 的左下角。

  * 对旋转和缩放后的 Actor 进行命中检测。每个 Actor 都使用自身未旋转、未缩放的坐标系判断是否命中。

  * 将输入及其他事件路由到相应的 Actor。事件系统十分灵活，允许父 Actor 在子 Actor 之前或之后处理事件。

  * Action 系统便于随时间操控 Actor。Action 可以串联和组合，以实现复杂效果。

scene2d 非常适合为游戏菜单、HUD 覆盖层、工具及其他 UI 进行布局、绘制和输入处理。[scene2d.ui](/wiki/graphics/2d/scene2d/scene2d-ui) 包提供了许多专门用于构建 UI 的 Actor 和其他工具。

场景图的缺点是将模型与视图耦合在一起。Actor 存储了游戏中通常被视为模型数据的信息，例如尺寸和位置。Actor 同时也是视图，因为它们知道如何绘制自身。这种耦合使 MVC 分离变得困难；但如果只将其用于 UI，或应用本身不在意 MVC，这种耦合就不是问题。

scene2d 的核心包含三个类：

1. Actor 类是图中的节点，具有位置、矩形尺寸、原点、缩放、旋转和颜色。

1. Group 类是一种可以拥有子 Actor 的 Actor。

1. Stage 类拥有相机、SpriteBatch 和根 Group，并负责绘制 Actor 以及分发输入事件。

### Stage

Stage 是一个 InputProcessor。收到输入事件后，它会将事件派发给相应的 Actor。如果 Stage 被用作其他内容上方的 UI（例如 HUD），可以使用 InputMultiplexer 先让 Stage 尝试处理事件。如果 Stage 中的 Actor 处理了事件，Stage 的 InputProcessor 方法会返回 true，表示事件已处理，不应继续传给下一个 InputProcessor。

Stage 有一个接收上一帧以来 delta 时间的 `act` 方法。它会调用场景中每个 Actor 的 `act` 方法，使 Actor 能够根据时间执行操作。默认情况下，Actor 的 `act` 方法会更新该 Actor 上的所有 Action。调用 Stage 的 `act` 并非强制，但省略后 Actor 的 Action 和进入/离开事件不会发生。

### 视口

Stage 的视口由一个 [Viewport](/wiki/graphics/viewports) 实例决定。Viewport 管理 `Camera`，控制 Stage 在屏幕上的显示方式、Stage 的宽高比（是否拉伸）以及是否出现黑边（letterboxing）。Viewport 还负责在屏幕坐标与 Stage 坐标之间转换。

可以在 Stage 构造函数中指定 viewport，也可以使用 `setViewport` 指定。如果应用运行在窗口可调整大小的环境（例如桌面）中，应在应用窗口大小改变时设置 Stage 的 viewport。

下面是使用 `ScreenViewport` 的最基本 scene2d 应用示例，其中不包含 Actor。在此 viewport 中，Stage 中的每个单位对应 1 个像素。因此 Stage 不会被拉伸，但可见的 Stage 范围会随屏幕或窗口大小而变化。这通常适用于 UI 应用。

```java
private Stage stage;

public void create () {
	stage = new Stage(new ScreenViewport());
	Gdx.input.setInputProcessor(stage);
}

public void resize (int width, int height) {
	// See below for what true means.
	stage.getViewport().update(width, height, true);
}

public void render () {
	float delta = Gdx.graphics.getDeltaTime();
	Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
	stage.act(delta);
	stage.draw();
}

public void dispose () {
	stage.dispose();
}
```

更新 viewport 时传入 `true` 会调整相机位置，使其居中于 Stage，从而让 0,0 成为左下角。这适用于通常不会改变相机位置的 UI。自行管理相机位置时传入 false 或省略布尔参数。如果没有设置 Stage 位置，默认情况下 0,0 位于屏幕中心。

下面是使用 `StretchViewport` 的示例。Stage 的 640x480 尺寸会拉伸到屏幕大小，可能改变 Stage 的宽高比。

```java
	stage = new Stage(new StretchViewport(640, 480));
```

下面是使用 `FitViewport` 的示例。Stage 的 640x480 尺寸会在不改变宽高比的情况下缩放以适应屏幕，然后在两侧添加黑边填充剩余空间（letterboxing）。

```java
	stage = new Stage(new FitViewport(640, 480));
```

下面是使用 `ExtendViewport` 的示例。Stage 的 640x480 尺寸首先在不改变宽高比的情况下缩放以适应屏幕，然后增大 Stage 较短的边以填满屏幕。宽高比不会改变，也不会出现黑边，但 Stage 可能在一个方向上变得更长。

```java
	stage = new Stage(new ExtendViewport(640, 480));
```

下面是使用带最大尺寸的 `ExtendViewport` 的示例。与之前一样，Stage 的 640x480 尺寸首先在不改变宽高比的情况下缩放以适应屏幕，然后增大较短的边以填满屏幕。不过，Stage 尺寸不会超过 800x480 的最大值。这种方式可以在支持多种宽高比的同时显示更多世界内容，并避免出现黑边。

```java
	stage = new Stage(new ExtendViewport(640, 480, 800, 480));
```

大多数显示黑边的 viewport 都会使用 `glViewport`，因此 Stage 无法在黑边区域内绘制。可以将 `glViewport` 设置为整个屏幕，从而在 Stage 外的黑边区域绘制。

```java
// Set the viewport to the whole screen.
Gdx.gl.glViewport(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());

// Draw anywhere on the screen.

// Restore the stage's viewport.
stage.getViewport().update(Gdx.graphics.getWidth(), Gdx.graphics.getHeight(), true);
```

更多信息请参阅 [Viewport](/wiki/graphics/viewports)。

## 绘制

调用 Stage 的 `draw` 时，会对 Stage 中的每个 Actor 调用 draw。可以重写 Actor 的 `draw` 方法来执行绘制：

```java
public class MyActor extends Actor {
	TextureRegion region;

	public MyActor () {
		region = new TextureRegion(...);
                setBounds(region.getRegionX(), region.getRegionY(),
			region.getRegionWidth(), region.getRegionHeight());
	}

	@Override
	public void draw (Batch batch, float parentAlpha) {
		Color color = getColor();
		batch.setColor(color.r, color.g, color.b, color.a * parentAlpha);
		batch.draw(region, getX(), getY(), getOriginX(), getOriginY(),
			getWidth(), getHeight(), getScaleX(), getScaleY(), getRotation());
	}
}
```

这个 `draw` 方法使用 Actor 的位置、原点、尺寸、缩放和旋转绘制区域。传入 draw 的 Batch 已配置为在父对象坐标中绘制，因此 0,0 是父对象的左下角。即使父对象经过旋转和缩放，绘制也依然简单。Batch 的 begin 已经调用。如果像示例中这样将 `parentAlpha` 与 Actor 的 alpha 相乘，子 Actor 会受到父对象透明度的影响。注意，Batch 的颜色可能被其他 Actor 修改，因此每个 Actor 绘制前都应设置自己的颜色。

如果对 Actor 调用 `setVisible(false)`，则不会调用它的 draw 方法，也不会接收输入事件。

如果 Actor 需要以不同方式绘制，例如使用
`ShapeRenderer`，应结束 Batch，并在方法末尾重新开始 Batch。当然，这会导致刷新 Batch，因此应谨慎使用。可以使用 Batch 的变换矩阵和投影矩阵：

```java
private ShapeRenderer renderer = new ShapeRenderer();

public void draw (Batch batch, float parentAlpha) {
	batch.end();

	renderer.setProjectionMatrix(batch.getProjectionMatrix());
	renderer.setTransformMatrix(batch.getTransformMatrix());
	renderer.translate(getX(), getY(), 0);

	renderer.begin(ShapeType.Filled);
	renderer.setColor(Color.BLUE);
	renderer.rect(0, 0, getWidth(), getHeight());
	renderer.end();

	batch.begin();
}
```

## Group 变换

Group 旋转或缩放时，子 Actor 会照常绘制，而 Batch 的变换会使它们正确地旋转或缩放。Group 绘制前会刷新 Batch，以便设置变换。如果有几十个甚至更多 Group，这种刷新可能成为性能瓶颈。如果 Group 中的 Actor 没有旋转或缩放，可以对 Group 使用 `setTransform(false)`。这样绘制时每个子 Actor 的位置会加上 Group 的位置，即使 Batch 没有进行变换，子 Actor 也会出现在正确位置。带有旋转或缩放的 Group 不能使用此方式。

## 命中检测

Actor 的 `hit` 方法接收一个点，并返回该点处层级最深的 Actor；如果没有命中 Actor，则返回 null。默认的 `hit` 方法如下：

```java
public Actor hit (float x, float y, boolean touchable) {
	if (touchable && getTouchable() != Touchable.enabled) return null;
	return x >= 0 && x < width && y >= 0 && y < height ? this : null;
}
```

坐标使用 Actor 的坐标系。点位于 Actor 边界内时，该方法直接返回 Actor。也可以使用更复杂的检测方式，例如 Actor 为圆形时。`touchable` 布尔参数表示是否遵守 Actor 的可触摸状态，因此可以对不可触摸的 Actor 执行非触摸用途的命中检测。

在 Stage 上调用 `hit` 时，会对 Stage 的根 Group 调用 `hit`，根 Group 再对每个子 Actor 调用 `hit`。找到的第一个非 null Actor 会作为包含给定点且层级最深的 Actor 返回。

## 事件系统

scene2d 使用通用事件系统。每个 Actor 都有一个监听器列表，在该 Actor 上发生事件时会通知这些监听器。事件分两个阶段传播。首先在“捕获”阶段，事件从根节点向下传递给目标 Actor，只有捕获监听器会收到通知。这让父 Actor 有机会在子 Actor 看到事件前拦截并取消事件。接着在“正常”阶段，事件从目标 Actor 向上​​传递到根节点，只有普通监听器会收到通知。这样 Actor 可以自行处理事件，也可以让父 Actor 尝试处理。

通知每个 Actor 时提供的事件对象包含事件状态。target 是事件发源的 Actor，listener actor 是附加监听器的 Actor。事件还有几个重要方法。调用事件的 `stop` 后，当前 Actor 的其余监听器仍会收到通知，但之后其他 Actor 不再接收事件。这可用于在捕获阶段阻止子 Actor，或在正常阶段阻止父 Actor 看到事件。调用 `cancel` 会像 stop 一样停止传播，并阻止触发事件的代码执行原本的默认操作。例如，对于复选框勾选事件，取消事件可以阻止复选框被勾选。

例如，假设一个 Group（按钮）包含一个子 Actor（标签）。点击标签时会触发捕获监听器，通常没有捕获监听器。接着通知标签的普通监听器，此时标签既是 target 也是 listener actor。如果事件没有被停止，按钮会收到事件并通知其普通监听器；此时标签是 target，按钮是 listener actor。事件会继续向上传递直到根节点。这一系统允许父 Actor 上的单个监听器处理其子 Actor 的事件。

### InputListener

将 EventListener 添加到 Actor 后即可接收事件通知。EventListener 是包含 `handle(Event)` 方法的接口。实现 EventListener 的类会使用 `instanceof` 判断是否应处理事件。对于大多数事件类型，框架都提供了专用监听器类。例如，[InputListener](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/scenes/scene2d/InputListener.html) 用于接收和处理 InputEvent。Actor 只需添加 InputListener 即可开始接收输入事件。InputListener 有多个可重写方法，下面展示其中两个：

```java
actor.setBounds(0, 0, texture.getWidth(), texture.getHeight());

actor.addListener(new InputListener() {
	public boolean touchDown (InputEvent event, float x, float y, int pointer, int button) {
		System.out.println("down");
		return true;
	}
	
	public void touchUp (InputEvent event, float x, float y, int pointer, int button) {
		System.out.println("up");
	}
});
```

注意，Actor 必须指定边界，才能接收其边界内的输入事件。

要处理触摸和鼠标事件，请重写 `touchDown`、`touchDragged` 和 `touchUp`。只有当 touchDown 返回 true 时，才会接收 touchDragged 和 touchUp 事件。此外，即使 touchDragged 和 touchUp 发生在 Actor 外部，也仍会被接收，这简化了最常见的触摸事件场景。

要处理触摸或鼠标进入、离开 Actor 的事件，请重写 `enter` 或 `exit`。

要处理没有按下鼠标按键时的鼠标移动（仅发生在桌面平台），请重写 `mouseMoved` 方法。

要处理鼠标滚动（仅发生在桌面平台），请重写 `scrolled` 方法。该方法只会在具有滚动焦点的 Actor 上调用，滚动焦点通过对 Stage 调用 setScrollFocus 设置和清除。

要处理键盘输入，请重写 `keyDown`、`keyUp` 和 `keyTyped` 方法。这些方法只会在具有键盘焦点的 Actor 上调用，键盘焦点通过对 Stage 调用 `setKeyboardFocus` 设置和清除。

如果对 Actor 调用 `setTouchable(false)` 或 `setVisible(false)`，它将不会接收输入事件。

### 其他监听器

框架还为常见的输入事件处理提供了其他监听器。ClickListener 包含一个布尔值：在 Actor 上按下触摸或鼠标按键时为 true；Actor 被点击时会调用 `clicked` 方法。ActorGestureListener 可以检测 Actor 上的 tap、longPress、fling、pan、zoom 和 pinch 手势。

```java
actor.addListener(new ActorGestureListener() {
	public boolean longPress (Actor actor, float x, float y) {
		System.out.println("long press " + x + ", " + y);
		return true;
	}

	public void fling (InputEvent event, float velocityX, float velocityY, int button) {
		System.out.println("fling " + velocityX + ", " + velocityY);
	}

	public void zoom (InputEvent event, float initialDistance, float distance) {
		System.out.println("zoom " + initialDistance + ", " + distance);
	}
});
```

## Action

每个 Actor 都有一个 Action 列表。Actor 的 `act` 方法会在每帧更新这些 Action。libGDX 内置了许多类型的 Action，可以实例化、配置并添加到 Actor。Action 完成后会自动从 Actor 中移除。

```java
MoveToAction action = new MoveToAction();
action.setPosition(x, y);
action.setDuration(duration);
actor.addAction(action);
```

有关 Action 的教程请参阅 [https://libgdxinfo.wordpress.com](https://libgdxinfo.wordpress.com/basic_action/)。

### Action 对象池

为了避免每次需要时都分配新的 Action，可以使用对象池：

```java
Pool<MoveToAction> pool = new Pool<MoveToAction>() {
	protected MoveToAction newObject () {
		return new MoveToAction();
	}
};
MoveToAction action = pool.obtain();
action.setPool(pool);
action.setPosition(x, y);
action.setDuration(duration);
actor.addAction(action);
```

Action 完成后会从 Actor 中移除，并放回对象池以便复用。不过，上面的代码相当冗长。Actions 类（注意是复数）提供了便捷方法，也可以提供对象池中的 Action：

```java
MoveToAction action = Actions.action(MoveToAction.class);
action.setPosition(x, y);
action.setDuration(duration);
actor.addAction(action);
```

更方便的是，Actions 类提供了返回已配置对象池 Action 的方法。

```java
actor.addAction(Actions.moveTo(x, y, duration));
```

Actions 类提供了许多便捷方法，可以通过一次调用完整配置内置 Action。使用静态导入还可以进一步简化代码，从而无需每次都写出 "Actions."。注意，Eclipse 不会自动添加静态导入，必须手动添加。

```java
import static com.badlogic.gdx.scenes.scene2d.actions.Actions.*;
...
actor.addAction(moveTo(x, y, duration));
```

### 复杂 Action

通过同时或按顺序运行 Action，可以构建更复杂的 Action。ParallelAction 包含一个 Action 列表并同时运行它们；SequenceAction 也包含一个列表，但会依次运行。对 Actions 类使用静态导入，可以非常方便地定义复杂 Action：

```java
actor.addAction(sequence(moveTo(200, 100, 2), color(Color.RED, 6), delay(0.5f), rotateTo(180, 5)));
```

### Action 完成

要在 Action 完成时运行代码，可以使用包含 RunnableAction 的序列：

```java
actor.addAction(sequence(fadeIn(2), run(new Runnable() {
	public void run () {
		System.out.println("Action complete!");
	}
})));
```

### 插值

对于随时间操控 Actor 的 Action，可以设置补间曲线，方法是为 Action 提供一个 Interpolation 实例。Interpolation 类提供了许多便捷的静态字段，也可以自行编写插值方式。每种插值的交互式演示请参阅 [InterpolationTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/InterpolationTest.java)。

```java
MoveToAction action = Actions.action(MoveToAction.class);
action.setPosition(x, y);
action.setDuration(duration);
action.setInterpolation(Interpolation.bounceOut);
actor.addAction(action);
```

Actions 类提供了接收插值参数的方法，也可以使用静态导入更方便地访问 Interpolation 的静态字段。下面使用了 `bounceOut` 和 `swing` 插值：

```java
import static com.badlogic.gdx.scenes.scene2d.actions.Actions.*;
import static com.badlogic.gdx.math.Interpolation.*;
...
actor.addAction(parallel(moveTo(250, 250, 2, bounceOut), color(Color.RED, 6), delay(0.5f), rotateTo(180, 5, swing)));
actor.addAction(forever(sequence(scaleTo(2, 2, 0.5f), scaleTo(1, 1, 0.5f), delay(0.5f))));
```

### 外部链接

  * [netthreads](https://web.archive.org/web/20200805185955/http://www.netthreads.co.uk/2012/01/31/libgdx-example-of-using-scene2d-actions-and-event-handling/) 完整记录的 scene2d 示例游戏。
  * [gdx-ui-app](https://github.com/broken-e/gdx-ui-app) 基于 scene2d、便于开发的库。
  * [我的游戏应该使用 scene2d 吗？](https://jvm-gaming.org/t/libgdx-actor-to-use-or-not-to-use-or-when-to-use/41938/7)
  * [Street Race 游戏教程](https://theinvader360.blogspot.co.uk/2013/05/street-race-swipe-libgdx-scene2d.html)
