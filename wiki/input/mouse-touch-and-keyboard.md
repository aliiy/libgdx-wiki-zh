---
title: 鼠标、触摸和键盘
redirect_from:
  - /wiki/mouse,-touch-&-keyboard
  - /wiki/input/on-screen-keyboard
---
libGDX 支持的主要输入设备包括桌面端/浏览器上的鼠标、Android 上的触摸屏以及键盘。下面介绍 libGDX 如何对这些设备进行抽象。

## 键盘
键盘通过生成按键按下和释放事件来传递用户输入。每个事件都包含一个用于标识被按下或释放按键的键码。这些键码因平台而异。libGDX 通过提供自己的键码表来隐藏这一差异，详见 [Keys](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Input.Keys.html) [（源码）](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/Input.java#L69) 类。可以通过[轮询](/wiki/input/polling)查询当前正在按下的按键。

仅凭键码无法知道用户实际输入了哪个字符。字符信息通常由多个按键的状态推导而来，例如字符 'A' 是由 'a' 和 'shift' 同时按下产生的。通常，根据键盘状态（哪些按键处于按下状态）推导字符并不简单。幸运的是，操作系统通常提供事件监听器机制，不仅报告键码事件（按键按下/按键释放），还会报告字符。libGDX 在底层使用这一机制来提供字符信息。请参阅[事件处理](/wiki/input/event-handling)。

由于大多数 Android 和 iOS 设备没有实体键盘，可以使用 `Gdx.input.setOnscreenKeyboardVisible(true)` 调出屏幕键盘。还可以通过传入 [`OnscreenKeyboardType`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Input.OnscreenKeyboardType.html) 指定要显示的键盘类型。

## 鼠标与触摸
鼠标和触摸输入允许用户指向屏幕上的对象。两种输入机制都以相对于屏幕左上角的 2D 坐标报告交互位置，其中 x 轴正方向向右，y 轴正方向向下。

鼠标输入还会提供按下了哪个按钮的信息。大多数鼠标都有左键、右键和中键，此外通常还带有滚轮，可在许多应用中用于缩放或滚动。

触摸输入没有按钮的概念，而且根据硬件不同，可能需要跟踪多根手指，因此更加复杂。第一代 Android 手机只支持单点触控。从 Motorola Droid 等手机开始，多点触控成为大多数 Android 手机的标准功能。

请注意，不同设备对触摸的实现可能差异很大，这会影响指针索引的指定和释放方式，以及触摸事件触发的时机。务必尽可能在多种设备上测试控制方案。市场上还有许多输入测试应用，可以帮助确定特定设备如何报告触摸，并协助设计适用于多种设备的最佳控制方案。

libGDX 对鼠标和触摸输入采用统一的处理方式。我们将鼠标输入视为触摸输入的一种特殊形式，只跟踪一根手指，并在报告坐标的同时报告按下了哪些按钮。对于触摸输入，我们支持跟踪多根手指（指针），并为所有事件报告鼠标左键。

请注意，在 Android 上，坐标系相对于竖屏模式还是横屏模式，取决于应用的设置。

鼠标和触摸输入既可以[轮询](/wiki/input/polling)，也可以通过[事件处理](/wiki/input/event-handling)处理。

### 触摸点

要获取触摸点或鼠标光标正确的世界坐标，需要使用工作在世界空间中的摄像机，将原始屏幕位置坐标反投影。下面是一个完整示例。

```java
public class SimplerTouchTest extends ApplicationAdapter implements InputProcessor {
	// we will use 32px/unit in world
	public final static float SCALE = 32f;
	public final static float INV_SCALE = 1.f/SCALE;
	// this is our "target" resolution, note that the window can be any size, it is not bound to this one
	public final static float VP_WIDTH = 1280 * INV_SCALE;
	public final static float VP_HEIGHT = 720 * INV_SCALE;

	private OrthographicCamera camera;
	private ExtendViewport viewport;		
	private ShapeRenderer shapes;

	@Override public void create () {
		camera = new OrthographicCamera();
		// pick a viewport that suits your thing, ExtendViewport is a good start
		viewport = new ExtendViewport(VP_WIDTH, VP_HEIGHT, camera);
		// ShapeRenderer so we can see our touch point
		shapes = new ShapeRenderer();
		Gdx.input.setInputProcessor(this);
	}

	@Override public void render () {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
		shapes.setProjectionMatrix(camera.combined);
		shapes.begin(ShapeRenderer.ShapeType.Filled);
		shapes.circle(tp.x, tp.y, 0.25f, 16);
		shapes.end();
	}

	Vector3 tp = new Vector3();
	boolean dragging;
	@Override public boolean mouseMoved (int screenX, int screenY) {
		// we can also handle mouse movement without anything pressed
//		camera.unproject(tp.set(screenX, screenY, 0));
		return false;
	}

	@Override public boolean touchDown (int screenX, int screenY, int pointer, int button) {
		// ignore if its not left mouse button or first touch pointer
		if (button != Input.Buttons.LEFT || pointer > 0) return false;
		camera.unproject(tp.set(screenX, screenY, 0));
		dragging = true;
		return true;
	}

	@Override public boolean touchDragged (int screenX, int screenY, int pointer) {
		if (!dragging) return false;
		camera.unproject(tp.set(screenX, screenY, 0));
		return true;
	}

	@Override public boolean touchUp (int screenX, int screenY, int pointer, int button) {
		if (button != Input.Buttons.LEFT || pointer > 0) return false;
		camera.unproject(tp.set(screenX, screenY, 0));
		dragging = false;
		return true;
	}

	@Override public void resize (int width, int height) {
		// viewport must be updated for it to work properly
		viewport.update(width, height, true);
	}

	@Override public void dispose () {
		// disposable stuff must be disposed
		shapes.dispose();
	}

	@Override public boolean keyDown (int keycode) {
		return false;
	}

	@Override public boolean keyUp (int keycode) {
		return false;
	}

	@Override public boolean keyTyped (char character) {
		return false;
	}

	@Override public boolean scrolled (int amount) {
		return false;
	}

	public static void main (String[] args) {
		Lwjgl3ApplicationConfiguration config = new Lwjgl3ApplicationConfiguration();
		config.setWindowedMode(1280, 720);
		new Lwjgl3Application(new SimplerTouchTest(), config);
	}
}
```
