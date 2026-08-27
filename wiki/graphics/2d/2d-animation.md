---
title: 2D 动画
---
2D 动画是一种使用静态图像制造运动错觉的技术。本文介绍如何使用 libGDX 的 [Animation 类](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/Animation.html)创建动画。

## 背景

动画由多个帧组成，这些帧会按照固定间隔依次显示。拍摄一个人奔跑时的连续画面，再循环依次播放这些图像，就可以制作奔跑动画。

下面的“精灵表”图像展示了一个人完整的奔跑循环。每个方框包含一帧动画；这些帧在一段时间内依次显示时，就会呈现为动画图像。

![images/sprite-animation1.png](/assets/wiki/images/sprite-animation1.png)

帧率是每秒更换帧的次数。示例精灵表的完整奔跑循环包含 30 帧（6 列、5 行）。如果角色要在一秒内完成一个循环，就必须每秒显示 30 帧，因此帧率为 30 FPS。每帧所用的时间（称为帧时间或间隔时间）是 FPS 的倒数，本例为 `0.033 seconds per frame`。

动画其实是一个非常简单的状态机。根据精灵表，奔跑中的人有 30 个状态。编号帧表示奔跑过程中依次经历的状态，同一时刻只处于其中一个状态。当前状态由动画开始后经过的时间决定。若经过时间少于 0.033 秒，则处于状态 1，绘制第一张精灵图；若时间在 0.033 到 0.067 秒之间，则处于状态 2，以此类推。循环播放时，所有帧显示完毕后会回到第一帧。

![images/sprite-animation2.png](/assets/wiki/images/sprite-animation2.png)

## Animation 类

libGDX 的 [Animation](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/Animation.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g2d/Animation.java) 类可用于方便地管理动画。它由图像列表和帧间隔时间构造。播放期间，其 `getKeyFrame` 方法接收一个已用时间参数，并返回该时间对应的图像。

Animation 有一个泛型类型参数，用于表示图像的类类型。该类型通常是 TextureRegion 或 PolygonRegion，但任何可渲染对象都可以使用。声明 Animation 时指定动画类型即可，例如 `Animation<TextureRegion> myAnimation = new Animation<TextureRegion>(/*...*/)`. 通常不建议使用 Sprite 类表示动画帧，因为 Sprite 类包含的位置数据不会在帧之间自动传递。

## TextureAtlas 示例

libGDX 的 [TextureAtlas](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/g2d/TextureAtlas.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/graphics/g2d/TextureAtlas.java) 类通常用于将多个独立的 TextureRegion 合并到较少的 Texture 中，以减少开销较高的绘制调用。（[详情](/wiki/tools/texture-packer#textureatlas)）。

TexturePacker 和 TextureAtlas 提供了生成动画的便捷方式。动画的所有源图像都应在末尾使用下划线加帧编号命名，例如 `running_0.png`、`running_1.png`、`running_2.png` 等。只要打包参数 `useIndexes` 保持为 true，TexturePacker 就会自动将这些数字用作帧编号。

加载 TextureAtlas 后，可以一次性获取完整的帧数组，并传入 Animation 构造函数：

```java
public Animation<TextureRegion> runningAnimation;

//...

runningAnimation =
    new Animation<TextureRegion>(0.033f, atlas.findRegions("running"), PlayMode.LOOP);
```

## 精灵表示例

下面的代码片段使用 animation_sheet.png 精灵表创建 Animation，并将动画渲染到屏幕上。

```java
public class Animator implements ApplicationListener {

	// Constant rows and columns of the sprite sheet
	private static final int FRAME_COLS = 6, FRAME_ROWS = 5;

	// Objects used
	Animation<TextureRegion> walkAnimation; // Must declare frame type (TextureRegion)
	Texture walkSheet;
	SpriteBatch spriteBatch;

	// A variable for tracking elapsed time for the animation
	float stateTime;

	@Override
	public void create() {

		// Load the sprite sheet as a Texture
		walkSheet = new Texture(Gdx.files.internal("animation_sheet.png"));

		// Use the split utility method to create a 2D array of TextureRegions. This is
		// possible because this sprite sheet contains frames of equal size and they are
		// all aligned.
		TextureRegion[][] tmp = TextureRegion.split(walkSheet,
				walkSheet.getWidth() / FRAME_COLS,
				walkSheet.getHeight() / FRAME_ROWS);

		// Place the regions into a 1D array in the correct order, starting from the top
		// left, going across first. The Animation constructor requires a 1D array.
		TextureRegion[] walkFrames = new TextureRegion[FRAME_COLS * FRAME_ROWS];
		int index = 0;
		for (int i = 0; i < FRAME_ROWS; i++) {
			for (int j = 0; j < FRAME_COLS; j++) {
				walkFrames[index++] = tmp[i][j];
			}
		}

		// Initialize the Animation with the frame interval and array of frames
		walkAnimation = new Animation<TextureRegion>(0.025f, walkFrames);

		// Instantiate a SpriteBatch for drawing and reset the elapsed animation
		// time to 0
		spriteBatch = new SpriteBatch();
		stateTime = 0f;
	}

	@Override
	public void render() {
		Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT); // Clear screen
		stateTime += Gdx.graphics.getDeltaTime(); // Accumulate elapsed animation time

		// Get current frame of animation for the current stateTime
		TextureRegion currentFrame = walkAnimation.getKeyFrame(stateTime, true);
		spriteBatch.begin();
		spriteBatch.draw(currentFrame, 50, 50); // Draw current frame at (50, 50)
		spriteBatch.end();
	}

	@Override
	public void dispose() { // SpriteBatches and Textures must always be disposed
		spriteBatch.dispose();
		walkSheet.dispose();
	}
}
```

![images/sprite-animation3.png](/assets/wiki/images/sprite-animation3.png)

使用下面的构造函数可以非常简单地创建动画。

| 方法签名 | 描述 |
|:-------------------|:--------------|
| `Animation (float frameDuration, TextureRegion... keyFrames)` | 第一个参数是帧时间，第二个参数是组成动画的区域（帧）数组 |

## 最佳实践
 * 将帧与其他精灵一起打包到一张纹理中，以优化渲染。使用 TexturePacker 可以轻松完成。
 * 根据游戏类型选择合理的帧数。复古街机风格可能 10 fps 就足够，而更逼真的动作需要更多帧。

## 资源

可以从[这里](/assets/wiki/images/sprite-animation4.png)获取精灵表。
