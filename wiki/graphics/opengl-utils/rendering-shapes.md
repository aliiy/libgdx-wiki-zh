---
title: 绘制形状
---
[ShapeRenderer API](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/glutils/ShapeRenderer.html)（Javadoc 顶层提供了一个示例！）

### ShapeRenderer 能做什么？

可以使用 ShapeRenderer 绘制简单形状，包括矩形和椭圆。形状可以绘制轮廓或填充，也可以为每次绘制设置颜色。它的使用方式与 sprite batch 非常相似。

下面的示例代码取自实际项目：

```java
public class MyGame extends Game {
	public final static float WIDTH = 100;
	public final static float HEIGHT = 16 * WIDTH / 9;

	FitViewport viewport;
	OrthographicCamera camera;
	ShapeRenderer shape;

	@Override
	public void create () {
		shape = new ShapeRenderer();
		camera = new OrthographicCamera();
		viewport = new FitViewport(WIDTH, HEIGHT, camera);
		...
	}

	@Override
	public void resize(int width, int height) {
		viewport.update(width, height);
	}

	...
}

public class Box {
	...
}

public class ScreenPlay implements Screen {
	final Game g;
	Array<Box> boxes;
	...

	@Override
	public void render(float delta) {
		for(Box box : boxes) {
			g.shape.setProjectionMatrix(g.camera.combined);
			g.shape.begin(ShapeType.Line);
			g.shape.setColor(Color.RED);
			g.shape.rect(box.x, box.y, box.width, box.height);
			g.shape.end();

			g.shape.setProjectionMatrix(g.camera.combined);
			g.shape.begin(ShapeType.Filled);
			g.shape.setColor(Color.BLUE);
			g.shape.ellipse(box.x, box.y, box.width, box.height);
			g.shape.end();
		}
	}

	...

}
```

### 替代方案

使用 ShapeRenderer 的缺点之一是它使用自己的 Mesh。这意味着如果要在 ShapeRenderer 和 Batch 之间交替使用，就必须在切换前分别对两者执行 start、end（以及 flush），这可能会显著降低性能。替代方案是使用第三方库 [ShapeDrawer](https://github.com/earlygrey/shapedrawer)，它使用用户提供的 Batch 绘制形状。它具备 ShapeRenderer 的大部分功能，并额外支持线段连接、倒角等功能。绘制形状时它也不会覆盖自身，因此可以使用透明颜色；从绘制线条切换到填充形状时也不需要 flush。

典型用法如下：

```java
// batch drawing
shapeDrawer.setColor(Color.RED);
shapeDrawer.line(0, 0, 100, 100);
// batch drawing
shapeDrawer.setColor(Color.BLUE);
shapeDrawer.filledCircle(50, 50, 20);
// batch drawing
```
