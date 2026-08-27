---
title: "扩展简单的游戏"
redirect_from:
  - /dev/simple-game-extended/
  - /dev/simple_game_extended/
---

在本教程中，我们将**扩展**[上一个教程](/wiki/start/a-simple-game)制作的简单游戏“Drop”。我们会添加菜单屏幕和一些功能，让这个游戏更加完整。

先来介绍 libGDX 中几个更高级的类。

## Screen 接口
对于包含多个组件的游戏，屏幕是_基础组成部分_。屏幕包含许多你在 ApplicationListener 对象中熟悉的方法，还包含两个新方法：`show` 和 `hide`，分别在 Screen 获得或失去焦点时调用。Screen 负责处理（即处理输入并渲染）游戏的一个方面，例如菜单屏幕、设置屏幕或游戏屏幕等。

## Game 类
Game 类负责处理多个屏幕，并为此提供一些辅助方法，同时还提供一个可供使用的 ApplicationListener 实现。Screen 和 Game 对象结合起来，可以为游戏创建简单而强大的结构。

我们先创建一个继承 Game 的 `Drop` 类，其 `create()` 方法将作为游戏入口。看看代码：

```java
package com.badlogic.drop;

import com.badlogic.gdx.Game;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.graphics.g2d.BitmapFont;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.utils.viewport.FitViewport;


public class Drop extends Game {

	public SpriteBatch batch;
	public BitmapFont font;
	public FitViewport viewport;


	public void create() {
		batch = new SpriteBatch();
		// use libGDX's default font
		font = new BitmapFont();
		viewport = new FitViewport(8, 5);
		
		//font has 15pt, but we need to scale it to our viewport by ratio of viewport height to screen height 
		font.setUseIntegerPositions(false);
		font.getData().setScale(viewport.getWorldHeight() / Gdx.graphics.getHeight());
		
		this.setScreen(new MainMenuScreen(this));
	}

	public void render() {
		super.render(); // important!
	}

	public void dispose() {
		batch.dispose();
		font.dispose();
	}

}
```

我们通过实例化 SpriteBatch、BitmapFont 和 Viewport 来启动应用。对于可以共享的对象，创建多个实例是不好的实践（参见 [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself)）。SpriteBatch 对象用于将纹理等对象渲染到屏幕上；BitmapFont 对象与 SpriteBatch 一起用于将文本渲染到屏幕上。后面的 Screen 类中会进一步说明。

接下来，将 Game 的 Screen 设置为 `MainMenuScreen` 对象，并将一个 Drop 实例作为它唯一的参数。

使用 Game 实现时，一个常见错误是忘记调用 `super.render()`。如果在 Game 类中重写 render 方法却没有调用它，那么在 `create()` 方法中设置的 Screen 将不会被渲染！
{: .notice--primary}

最后再次提醒，要释放（占用资源较多的）对象！[这里](/wiki/managing-your-assets)有进一步的阅读资料。


## 主菜单
现在来深入了解 `MainMenuScreen` 类的细节。

```java
package com.badlogic.drop;

import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Screen;

public class MainMenuScreen implements Screen {

	final Drop game;

	public MainMenuScreen(final Drop game) {
		this.game = game;
	}


        //...Rest of class omitted for succinctness.

}
```

这段代码为实现 Screen 接口的 `MainMenuScreen` 类创建了构造函数。Screen 接口没有提供 `create()` 方法，因此我们改用构造函数。本游戏中构造函数唯一需要的参数是一个 `Drop` 实例，这样必要时就能调用它的方法和字段。

接下来是 `MainMenuScreen` 类中最后一个“核心”方法：`render(float)`

```java
public class MainMenuScreen implements Screen {

        //public MainMenuScreen(final Drop game)....

	@Override
	public void render(float delta) {
		ScreenUtils.clear(Color.BLACK);

		game.viewport.apply();
		game.batch.setProjectionMatrix(game.viewport.getCamera().combined);

		game.batch.begin();
		//draw text. Remember that x and y are in meters
		game.font.draw(game.batch, "Welcome to Drop!!! ", 1, 1.5f);
		game.font.draw(game.batch, "Tap anywhere to begin!", 1, 1);
		game.batch.end();

		if (Gdx.input.isTouched()) {
			game.setScreen(new GameScreen(game));
			dispose();
		}
	}

        // Rest of class still omitted...

}

```

这里的代码相当直接，唯一需要注意的是，我们必须调用 game 的 SpriteBatch 和 BitmapFont 实例，而不是创建自己的实例。`game.font.draw(SpriteBatch, String, float, float)` 用于将文本渲染到屏幕上。libGDX 自带预制字体 Arial，因此使用默认构造函数也能获得字体。

然后检查屏幕是否被触摸。如果被触摸，就将游戏的屏幕设置为 GameScreen 实例，再释放当前的 MainMenuScreen 实例。MainMenuScreen 中其余需要实现的方法留空，因此继续省略它们（这个类中没有需要释放的内容）。

还要记得在 resize 时更新 viewport。

```java
@Override
public void resize(int width, int height) {
	game.viewport.update(width, height, true);
}
```

## 游戏屏幕
主菜单完成后，终于可以制作游戏了。为避免重复，也避免为了实现一个和 Drop 一样简单的游戏而另想点子，我们会直接采用[原游戏](/wiki/start/a-simple-game)中的大部分代码。


```java
package com.badlogic.drop;


import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.Screen;
import com.badlogic.gdx.audio.Music;
import com.badlogic.gdx.audio.Sound;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Rectangle;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.ScreenUtils;

public class GameScreen implements Screen {
	final Drop game;

	Texture backgroundTexture;
	Texture bucketTexture;
	Texture dropTexture;
	Sound dropSound;
	Music music;
	Sprite bucketSprite;
	Vector2 touchPos;
	Array<Sprite> dropSprites;
	float dropTimer;
	Rectangle bucketRectangle;
	Rectangle dropRectangle;
	int dropsGathered;

	public GameScreen(final Drop game) {
		this.game = game;

		// load the images for the background, bucket and droplet
		backgroundTexture = new Texture("background.png");
		bucketTexture = new Texture("bucket.png");
		dropTexture = new Texture("drop.png");

		// load the drop sound effect and background music
		dropSound = Gdx.audio.newSound(Gdx.files.internal("drop.mp3"));
		music = Gdx.audio.newMusic(Gdx.files.internal("music.mp3"));
		music.setLooping(true);
		music.setVolume(0.5F);

		bucketSprite = new Sprite(bucketTexture);
		bucketSprite.setSize(1, 1);
		
		touchPos = new Vector2();
		
		bucketRectangle = new Rectangle();
		dropRectangle = new Rectangle();
		
		dropSprites = new Array<>();
	}

	@Override
	public void show() {
		// start the playback of the background music
		// when the screen is shown
		music.play();
	}

	@Override
	public void render(float delta) {
		input();
		logic();
		draw();
	}

	private void input() {
		float speed = 4f;
		float delta = Gdx.graphics.getDeltaTime();
        
		if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
			bucketSprite.translateX(speed * delta);
		}
		else if (Gdx.input.isKeyPressed(Input.Keys.LEFT)) {
			bucketSprite.translateX(-speed * delta);
		}
	
		if (Gdx.input.isTouched()) {
			touchPos.set(Gdx.input.getX(), Gdx.input.getY());
			game.viewport.unproject(touchPos);
			bucketSprite.setCenterX(touchPos.x);
		}
	}

	private void logic() {
		float worldWidth = game.viewport.getWorldWidth();
		float worldHeight = game.viewport.getWorldHeight();
		float bucketWidth = bucketSprite.getWidth();
		float bucketHeight = bucketSprite.getHeight();
		float delta = Gdx.graphics.getDeltaTime();
	
		bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));
		bucketRectangle.set(bucketSprite.getX(), bucketSprite.getY(), bucketWidth, bucketHeight);
	
		for (int i = dropSprites.size - 1; i >= 0; i--) {
			Sprite dropSprite = dropSprites.get(i);
			float dropWidth = dropSprite.getWidth();
			float dropHeight = dropSprite.getHeight();

            dropSprite.translateY(-2f * delta);
			dropRectangle.set(dropSprite.getX(), dropSprite.getY(), dropWidth, dropHeight);
	
			if (dropSprite.getY() < -dropHeight) dropSprites.removeIndex(i);
			else if (bucketRectangle.overlaps(dropRectangle)) {
				dropsGathered++;
				dropSprites.removeIndex(i);
				dropSound.play();
			}
		}
	
		dropTimer += delta;
		if (dropTimer > 1f) {
			dropTimer = 0;
			createDroplet();
		}
	}

	private void draw() {
		ScreenUtils.clear(Color.BLACK);
		game.viewport.apply();
		game.batch.setProjectionMatrix(game.viewport.getCamera().combined);
		game.batch.begin();
		
		float worldWidth = game.viewport.getWorldWidth();
		float worldHeight = game.viewport.getWorldHeight();
        
		game.batch.draw(backgroundTexture, 0, 0, worldWidth, worldHeight);
		bucketSprite.draw(game.batch);
	
		game.font.draw(game.batch, "Drops collected: " + dropsGathered, 0, worldHeight);
	
		for (Sprite dropSprite : dropSprites) {
			dropSprite.draw(game.batch);
		}
	
		game.batch.end();
	}

	private void createDroplet() {
		float dropWidth = 1;
		float dropHeight = 1;
		float worldWidth = game.viewport.getWorldWidth();
		float worldHeight = game.viewport.getWorldHeight();
	
		Sprite dropSprite = new Sprite(dropTexture);
		dropSprite.setSize(dropWidth, dropHeight);
		dropSprite.setX(MathUtils.random(0F, worldWidth - dropWidth));
		dropSprite.setY(worldHeight);
		dropSprites.add(dropSprite);
	}

	@Override
	public void resize(int width, int height) {
		game.viewport.update(width, height, true);
	}

	@Override
	public void hide() {
	}

	@Override
	public void pause() {
	}

	@Override
	public void resume() {
	}

	@Override
	public void dispose() {
		backgroundTexture.dispose();
		dropSound.dispose();
		music.dispose();
		dropTexture.dispose();
		bucketTexture.dispose();
	}
}
```

这段代码与原实现几乎有 95% 相同，区别在于现在使用构造函数，而不是 `ApplicationListener` 的 `create()` 方法，并像 `MainMenuScreen` 类那样传入一个 `Drop` 对象。Screen 设置为 `GameScreen` 后，我们还会立即开始播放音乐。此外，在游戏左上角添加了一个字符串，用于记录收集到的雨滴数量。

注意，`GameScreen` 类的 `dispose()` 方法不会自动调用，参见 [Screen API](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Screen.html)。释放工作由你负责。可以从 Game 类的 `dispose()` 方法调用它：让 `GameScreen` 类将自身引用传给 Game 类，或者在 Drop 类的 `dispose()` 方法中调用 `screen.dispose()`。这很重要，否则即使退出应用，`GameScreen` 的资源仍可能继续存在并占用内存。

就是这样，完整的游戏已经完成。这就是 Screen 接口和抽象 Game 类，以及创建包含多个状态的多面游戏所需了解的全部内容。**完整 Java 代码**见[这里](https://github.com/libgdx/libgdx.github.io/tree/dev/assets/downloads/tutorials/extended-game-java)。如果你使用 **Kotlin** 开发，完整代码见[这里](https://github.com/libgdx/libgdx.github.io/tree/dev/assets/downloads/tutorials/extended-game-kotlin)。

## 未来
完成本教程后，你应该已经基本了解 libGDX 的工作方式以及接下来可以期待什么。仍有一些地方可以改进，例如使用[内存管理](/wiki/articles/memory-management#object-pooling)类回收所有 Rectangle，而不是每次删除雨滴都让垃圾回收器清理它们。OpenGL 也不太喜欢我们在一次批处理中交给它太多不同的图像（本例只有两张图，因此没有问题）。通常应将所有图像放入单个 `Texture`，也称为 `TextureAtlas`。此外，查看 [Viewport](/wiki/graphics/viewports) 几乎肯定会有所帮助。Viewport 有助于处理不同的屏幕尺寸/分辨率，并决定屏幕内容是否需要拉伸、是否应保持宽高比等。

要继续学习 libGDX，我们强烈**推荐阅读我们的 [wiki](/wiki/)**，并查看主 GitHub 仓库中的演示和测试。如果有任何问题，欢迎**加入我们的官方 [Discord 服务器](/community/)**，我们很乐意提供帮助！

最好的实践就是亲自动手去做。再会，祝编码愉快！
