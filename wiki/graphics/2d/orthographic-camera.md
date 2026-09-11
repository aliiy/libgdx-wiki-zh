---
title: 正交摄像机
---
本页介绍 [OrthographicCamera](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/OrthographicCamera.html) 类及其用法。
正交摄像机仅用于 2D 环境，因为它实现平行（正交）投影；无论对象位于世界中的什么位置，最终图像都不会产生缩放因子。

一个实现摄像机缩放和移动的简单示例代码见 [https://libgdxinfo.wordpress.com](https://libgdxinfo.wordpress.com/basic_camera/)。

# 说明

Camera 类的工作方式类似现实世界中的简易摄像机。它可以：
 * 移动和旋转摄像机；
 * 放大和缩小；
 * 更改视口；
 * 在窗口坐标和世界空间之间投影/反投影点。

使用摄像机可以轻松在游戏世界中移动，而无需手动操作矩阵。所有投影矩阵和视图矩阵操作都封装在实现中。

position 字段表示摄像机中心的位置。
摄像机会扩展世界中选定的视口，使其匹配设备屏幕尺寸。

下面的小应用展示如何使用简单的 `OrthographicCamera` 在平面世界中移动。


```java
import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.graphics.GL20;
import com.badlogic.gdx.graphics.OrthographicCamera;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.MathUtils;

public class OrthographicCameraExample implements ApplicationListener {

	static final int WORLD_WIDTH = 100;
	static final int WORLD_HEIGHT = 100;

	private OrthographicCamera cam;
	private SpriteBatch batch;

	private Sprite mapSprite;
	private float rotationSpeed;

	@Override
	public void create() {
		rotationSpeed = 0.5f;

		mapSprite = new Sprite(new Texture(Gdx.files.internal("sc_map.png")));
		mapSprite.setPosition(0, 0);
		mapSprite.setSize(WORLD_WIDTH, WORLD_HEIGHT);

		float w = Gdx.graphics.getWidth();
		float h = Gdx.graphics.getHeight();

		// Constructs a new OrthographicCamera, using the given viewport width and height
		// Height is multiplied by aspect ratio.
		cam = new OrthographicCamera(30, 30 * (h / w));

		cam.position.set(cam.viewportWidth / 2f, cam.viewportHeight / 2f, 0);
		cam.update();

		batch = new SpriteBatch();
	}

	@Override
	public void render() {
		handleInput();
		cam.update();
		batch.setProjectionMatrix(cam.combined);

		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

		batch.begin();
		mapSprite.draw(batch);
		batch.end();
	}

	private void handleInput() {
		if (Gdx.input.isKeyPressed(Input.Keys.A)) {
			cam.zoom += 0.02;
		}
		if (Gdx.input.isKeyPressed(Input.Keys.Q)) {
			cam.zoom -= 0.02;
		}
		if (Gdx.input.isKeyPressed(Input.Keys.LEFT)) {
			cam.translate(-3, 0, 0);
		}
		if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
			cam.translate(3, 0, 0);
		}
		if (Gdx.input.isKeyPressed(Input.Keys.DOWN)) {
			cam.translate(0, -3, 0);
		}
		if (Gdx.input.isKeyPressed(Input.Keys.UP)) {
			cam.translate(0, 3, 0);
		}
		if (Gdx.input.isKeyPressed(Input.Keys.W)) {
			cam.rotate(-rotationSpeed, 0, 0, 1);
		}
		if (Gdx.input.isKeyPressed(Input.Keys.E)) {
			cam.rotate(rotationSpeed, 0, 0, 1);
		}

		cam.zoom = MathUtils.clamp(cam.zoom, 0.1f, 100/cam.viewportWidth);

		float effectiveViewportWidth = cam.viewportWidth * cam.zoom;
		float effectiveViewportHeight = cam.viewportHeight * cam.zoom;

		cam.position.x = MathUtils.clamp(cam.position.x, effectiveViewportWidth / 2f, 100 - effectiveViewportWidth / 2f);
		cam.position.y = MathUtils.clamp(cam.position.y, effectiveViewportHeight / 2f, 100 - effectiveViewportHeight / 2f);
	}

	@Override
	public void resize(int width, int height) {
		cam.viewportWidth = 30f;
		cam.viewportHeight = 30f * height/width;
		cam.update();
	}

	@Override
	public void resume() {
	}

	@Override
	public void dispose() {
		mapSprite.getTexture().dispose();
		batch.dispose();
	}

	@Override
	public void pause() {
	}

}

```

```java
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Application;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3ApplicationConfiguration;

public class DesktopLauncher {
	public static void main (String[] arg) {
		Lwjgl3ApplicationConfiguration config = new Lwjgl3ApplicationConfiguration();
		config.setForegroundFPS(60);
		config.setTitle("orthographic-camera-example");
		new Lwjgl3Application(new OrthographicCameraExample(), config);
	}
}
```

上面的类是使用正交摄像机在世界中移动的 libGDX 应用。世界大小使用可以自行定义的任意单位；在本例中，世界大小为 100x100 个单位。

```java
    static final int WORLD_WIDTH = 100;
    static final int WORLD_HEIGHT = 100;
```

很多人会错误地用像素来思考世界单位，这是应该避免的做法。它会导致不必要的常量乘除运算、代码中充斥奇怪的“每单位像素数”比例、对渲染管线理解不足，并使代码变得混乱！停止用像素“思考”后，还可以轻松避免许多其他问题。


那么这些单位究竟是什么？它们代表什么？应该将对象设置为多大？屏幕上会显示多少单位？下面很快就会说明这些问题。




```java
	private OrthographicCamera cam;  #1
	private SpriteBatch batch;       #2

	private Sprite mapSprite;        #3
	private float rotationSpeed;     #4
```



**#1** - 用于观察世界并由我们控制的 `OrthographicCamera` 实例。

**#2** - 用于渲染世界的 `SpriteBatch` 实例。

**#3** - 用于绘制世界地图的 `Sprite`。

**#4** - 摄像机旋转速度。



***


```java
@Override
public void create() {
	rotationSpeed = 0.5f;                                                    #1

	mapSprite = new Sprite(new Texture(Gdx.files.internal("sc_map.png")));   #2
	mapSprite.setPosition(0, 0);                                             #3
	mapSprite.setSize(WORLD_WIDTH, WORLD_HEIGHT);                            #4

	float w = Gdx.graphics.getWidth();                                       #5
	float h = Gdx.graphics.getHeight();                                      #6
	cam = new OrthographicCamera(30, 30 * (h / w));                          #7
	cam.position.set(cam.viewportWidth / 2f, cam.viewportHeight / 2f, 0);    #8
	cam.update();                                                            #9

	batch = new SpriteBatch();                                               #10
}
```


创建 ApplicationListener 新实例时会调用 `create` 方法，我们在这里初始化变量。

**#1** - 将当前旋转速度设为 0.5 度。

**#2** - 使用 `sc_map.png` 文件创建新的 Texture 和 `Sprite`。从[这里](https://user-images.githubusercontent.com/12996613/34653163-6a5c206c-f3e8-11e7-8913-87738e62bc81.png)下载文件，将其重命名为 `sc_map.png`，并放入 `assets/` 目录。

**#3** - 将 `mapSprite` 的位置设为 `0,0`。（这并非严格必要，因为 Sprite 的默认 x、y 本来就是 `0,0`。）

**#4** - 将 `mapSprite` 的宽度设为 `WORLD_WIDTH`、高度设为 `WORLD_HEIGHT`。因此 Sprite 的尺寸为 100x100，也就是世界的大小。

**#5** - 创建一个局部变量，保存应用显示区域当前的 `width`（单位为像素）。

**#6** - 创建一个局部变量，保存应用显示区域当前的 `height`（单位为像素）。

**#7** - 创建 `OrthographicCamera`。两个参数指定要创建的视口宽度和高度，决定各个轴上可见的世界范围。

本例中，视口宽度使用 `30`，高度使用 `30 * (h / w)`。宽度很直观，表示 X 轴上可见 30 个单位；高度则使用 `30` 乘以显示器的 `aspect ratio`，从而保证绘制对象的比例正确。如果忽略宽高比，直接将宽度和高度都设为 30，那么除非设备屏幕是正方形（通常不是），一个 30x30 的对象就会显示为被压扁的矩形。30x30 的对象为什么不是正方形？因为我们假定的 30x30 视口与设备的宽高比不匹配。


```
下面是一些例子：

如果将摄像机视口宽高都设为 100（`new OrthographicCamera(100, 100)`）并正确居中，就能一次看到“完整”的地图，也就是“完整”的世界。

如果将视口宽度设为 100、高度设为 50（`new OrthographicCamera(100, 50)`），任意时刻都能看到地图的“一半”。

如果将视口宽高都设为 50（`new OrthographicCamera(50, 50)`），任意时刻都能看到地图的“四分之一”。
```


**#8** - 将摄像机初始位置设为地图左下角。不过，摄像机的位置表示摄像机中心。

因此需要将摄像机位置分别偏移半个视口宽度和半个视口高度，使摄像机左下角实际位于 0,0。


**#9** - 更新摄像机！操作摄像机后必须调用此步骤，因为它会更新底层的所有矩阵。

**#10** - 创建 `SpriteBatch` 实例。

至此设置完成！现在开始渲染并操作摄像机。


***


```java
@Override
public void render() {
	handleInput();                             #1
	cam.update();                              #2                             
	batch.setProjectionMatrix(cam.combined);   #3

	Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);  #4

	batch.begin();                             #5
	mapSprite.draw(batch);                     #6
	batch.end();                               #7
}
```



**#1** - 根据按下的不同按键更新摄像机的位置、缩放和旋转，从而控制摄像机。

**#2** - 更新 `OrthographicCamera`。我们刚刚通过 `handleInput()` 方法操作了它，因此必须记得调用 `update()` 方法。

**#3** - 使用摄像机的视图矩阵和投影矩阵更新 `SpriteBatch` 实例。

**#4** - 清除屏幕（实际是清除颜色缓冲区）。

**#5** - 开始使用 `SpriteBatch`。

**#6** - 绘制 `mapSprite`！

**#7** - 结束使用 `SpriteBatch`。


***


下面深入了解摄像机的控制方式，这些操作都在 `handleInput()` 方法中完成。

```java
	private void handleInput() {
		if (Gdx.input.isKeyPressed(Input.Keys.A)) {
			cam.zoom += 0.02;
			//If the A Key is pressed, add 0.02 to the Camera's Zoom
		}
		if (Gdx.input.isKeyPressed(Input.Keys.Q)) {
			cam.zoom -= 0.02;
			//If the Q Key is pressed, subtract 0.02 from the Camera's Zoom
		}
		if (Gdx.input.isKeyPressed(Input.Keys.LEFT)) {
			cam.translate(-3, 0, 0);
			//If the LEFT Key is pressed, translate the camera -3 units in the X-Axis
		}
		if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
			cam.translate(3, 0, 0);
			//If the RIGHT Key is pressed, translate the camera 3 units in the X-Axis
		}
		if (Gdx.input.isKeyPressed(Input.Keys.DOWN)) {
			cam.translate(0, -3, 0);
			//If the DOWN Key is pressed, translate the camera -3 units in the Y-Axis
		}
		if (Gdx.input.isKeyPressed(Input.Keys.UP)) {
			cam.translate(0, 3, 0);
			//If the UP Key is pressed, translate the camera 3 units in the Y-Axis
		}
		if (Gdx.input.isKeyPressed(Input.Keys.W)) {
			cam.rotate(-rotationSpeed, 0, 0, 1);
			//If the W Key is pressed, rotate the camera by -rotationSpeed around the Z-Axis
		}
		if (Gdx.input.isKeyPressed(Input.Keys.E)) {
			cam.rotate(rotationSpeed, 0, 0, 1);
			//If the E Key is pressed, rotate the camera by rotationSpeed around the Z-Axis
		}

		cam.zoom = MathUtils.clamp(cam.zoom, 0.1f, 100/cam.viewportWidth);

		float effectiveViewportWidth = cam.viewportWidth * cam.zoom;
		float effectiveViewportHeight = cam.viewportHeight * cam.zoom;

		cam.position.x = MathUtils.clamp(cam.position.x, effectiveViewportWidth / 2f, 100 - effectiveViewportWidth / 2f);
		cam.position.y = MathUtils.clamp(cam.position.y, effectiveViewportHeight / 2f, 100 - effectiveViewportHeight / 2f);
	}
```

由此可见，该方法会轮询按键；如果按下了某个按键，就对摄像机执行相应操作。

最后 5 行负责将摄像机限制在世界边界内。

需要确保摄像机的缩放不会增大或减小到导致世界倒置，或显示超出世界范围的值。为此，可以计算 `effectiveViewportWidth` 和 `effectiveViewportHeight`，它们就是 viewport 的宽度/高度乘以 zoom（表示当前缩放下可看到的世界范围）。然后使用 `clamp` 将摄像机缩放限制在需要的范围内：使用 `0.1f` 防止缩放过近，使用 `100/cam.viewportWidth` 防止看到超过整个世界宽度的区域。

最后两行负责确保摄像机不会移动到世界边界之外，也就是任一轴小于 0 或大于 100。


***


应用尺寸发生变化时该怎么办？这时需要针对不同分辨率或宽高比的设备实现不同策略。下面列出几种基本策略，帮助你理解整体思路。

如果想使用更高层次的处理方式，应使用视口，请参阅[视口 Wiki 文章](/wiki/graphics/viewports)。


*以下 resize 策略可以保证，无论设备的像素宽度是多少，你在 x 轴上始终能看到 30 个单位。*
```java
	@Override
	public void resize(int width, int height) {
		cam.viewportWidth = 30f;                 // Viewport of 30 units!
		cam.viewportHeight = 30f * height/width; // Lets keep things in proportion.
		cam.update();
	}

```

*以下 resize 策略会根据分辨率显示更少或更多的世界内容*
```java
	@Override
	public void resize(int width, int height) {
		cam.viewportWidth = width/32f;  //We will see width/32f units!
		cam.viewportHeight = cam.viewportWidth * height/width;
		cam.update();
	}

```



***


用于启动监听器的主应用是一个简单的 LWJGL 应用。
```java
	public static void main(String[] args) {
		new LwjglApplication(new OrthographicCameraExample());
	}
```


***

结果如下：

![images/orthographic-camera.png](/assets/wiki/images/orthographic-camera.png)

大多数情况下无需访问摄像机的内部实现，因为以下方法已经涵盖了最常见的使用场景：

| *方法* | *描述* |
|:--------:|:--------------|
| `lookAt(float x, float y, float z)` | 重新计算摄像机的方向，使其看向由各轴上坐标所定义的点。- 2D 情况下会忽略 z 轴 |
| `translate(float x, float y, float z)` | 在每个轴上将摄像机移动给定的距离。- 注意 OrthographicCamera 会忽略 z |
| `rotate(float angle, float axisX, float axisY, float axisZ)` | 将摄像机的方向向量和上向量绕给定轴旋转给定角度。方向向量和上向量不会被正交化。该角度会被保留，因此摄像机会在上一次旋转的基础上再旋转 `angle`。|
| `update()` |  重新计算摄像机的投影矩阵、视图矩阵和视锥体平面 |
