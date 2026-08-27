---
title: "一个简单的游戏"
redirect_from:
  - /dev/simple-game/
  - /dev/simple_game/
---

让我们来制作一个游戏！游戏设计很难，但如果把过程拆分成小而可实现的目标，就能创造出奇迹。在这个简单游戏教程中，你将学习如何从头制作一个基础游戏。这些是你在未来项目中继续发展的基本技能。你可以观看[视频教程](https://youtu.be/aipDYyh1Mlc)，但代码示例仍应回到这里查看。

{% include embed-gwt.html dir='a-simple-game' width="800" height="500" %}

如实时演示所示，我们要制作一个基础游戏：控制水桶收集从天而降的水滴。游戏没有分数，也没有终点目标。享受过程就好！下面是我们拆分游戏设计过程所采用的步骤：

  * [前置条件](#prerequisites)
  * [加载资源](#loading-assets)
  * [游戏生命周期](#the-game-life-cycle)
  * [渲染](#rendering)
  * [输入控制](#input-controls)
  * [游戏逻辑](#game-logic)
  * [声音和音乐](#sound-and-music)
  * [进一步学习](#further-learning)
  * [完整示例代码](#full-example-code)

## 前置条件
开始本教程前，需要先完成几件事。

  * 按照 libgdx.com 上的[设置说明](/wiki/start/setup)配置 Java 和 IDE。你需要知道如何创建项目，并使用适当的 Gradle 命令运行项目。
  * 使用以下设置在 GDX-Liftoff 中创建项目：
    * 项目名称：Drop
    * 包名：com.badlogic.drop
    * 主类：Main
  * 包含 Core 和 Desktop 平台。也可以包含其他平台，但本教程不会讨论它们。在此阶段选择其他平台可能会引入你尚未准备好处理的新问题。
  * 使用 ApplicationListener 模板

在你选择的 IDE 中打开项目。如果你了解 Java 代码，使用 libGDX 的过程会轻松许多。不过，即使你只对代码的工作方式有初步了解，也应该能够跟随本教程完成操作。

代码示例中会使用注释来解释本教程的各个方面。编写代码时不必复制这些注释：

```java
// This is a comment. It will be ignored by the compiler.
```

不过，为难以理解的代码添加说明，或标注设计的各个部分，仍是很好的实践。

```java
// Restrict bucket movement to the width of the viewport.
```

import 语句是 Java 编程的重要组成部分。幸运的是，现代 IDE 会在你输入代码时自动添加它们。示例中省略了 import 语句，但请假定你的代码需要它们。它们会出现在文件顶部、package 语句下方。

```java
import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input.Keys;
import com.badlogic.gdx.InputProcessor;
import com.badlogic.gdx.audio.Music;
import com.badlogic.gdx.audio.Sound;
```

有时，libGDX 中的名称会与另一个包中的名称相同。例如，在 IDEA 中输入 `Rectangle` 时，IDE 会提示你按 alt+enter 自动完成 import。随后出现菜单时，务必选择 libGDX 中命名的类。这些类通常位于包 `com.badlogic.gdx` 中。

![libGDX Rectangle 类](/assets/images/dev/a-simple-game/1.png)

基于 OpenGL 的游戏（例如使用 libGDX 制作的游戏）中的小数通常用 `22.5f` 这样的浮点变量表示。忘记 "f" 可能导致构建错误。相比 `double`（例如 `22.5`），更推荐使用 `float`，因为它占用更少内存，大多数硬件都支持，而且通常也是 OpenGL 所期望的类型。在 IDEA 中按 `ctrl+p` 可以查看方法所需的参数。

![方法参数](/assets/images/dev/a-simple-game/2.png)

下面的代码示例中出现省略号 `...` 时，请理解为为了简洁而移除了其他代码。根据可见代码行的上下文判断它们在文件中的位置。如果完全不知所措，文末列出了完整示例。

在测试游戏前，应先设置桌面窗口的大小。桌面版本游戏所需的任何配置，都应在 LWJGL3Launcher 类中设置。在项目文件夹中找到此文件：

![Lwjgl3Launcher](/assets/images/dev/a-simple-game/3.png)

```java
...

private static Lwjgl3ApplicationConfiguration getDefaultConfiguration() {
    Lwjgl3ApplicationConfiguration configuration = new Lwjgl3ApplicationConfiguration();
    configuration.setTitle("Drop");
    configuration.useVsync(true);
    configuration.setForegroundFPS(Lwjgl3ApplicationConfiguration.getDisplayMode().refreshRate + 1);
    configuration.setWindowedMode(800, 500); // this line changes the size of the window
    configuration.setWindowIcon("libgdx128.png", "libgdx64.png", "libgdx32.png", "libgdx16.png");

    return configuration;
}
```

## 加载资源
使用 libGDX 制作的 2D 游戏需要资源：组成项目的图像、音频及其他内容。本例需要水桶、雨滴、背景、水滴音效和音乐。如果你动手能力很强，也可以自行制作。为了简单起见，可以下载这些为本教程优化的示例资源。

<a href="/assets/downloads/tutorials/simple-game/bucket.png?nomagnify" download="bucket.png">bucket.png</a><br>
<a href="/assets/downloads/tutorials/simple-game/drop.png?nomagnify" download="drop.png">drop.png</a><br>
<a href="/assets/downloads/tutorials/simple-game/background.png?nomagnify" download="background.png">background.png</a><br>
<a href="/assets/downloads/tutorials/simple-game/drop.mp3?nomagnify" download="drop.mp3">drop.mp3</a><br>
<a href="/assets/downloads/tutorials/simple-game/music.mp3?nomagnify" download="music.mp3">music.mp3</a>

仅将这些文件保存到电脑上还不够。必须把它们放入项目的 assets 文件夹。查看项目文件夹：

![assets 文件夹](/assets/images/dev/a-simple-game/4.png)

这里有许多文件夹，分别对应 libGDX 支持的不同后端。Assets 是所有后端共享的文件夹。保存在这里的内容会随游戏一起分发。例如，桌面游戏会将这些文件包含在 JAR 分发包中。你将这个分发包交给用户，他们就能运行游戏。

注意，在 libGDX 中，文件名大小写和扩展名都很重要。`drop.png`、`drop.mp3` 和 `Drop.mp3` 是不同的文件。令人烦恼的是，通常直到尝试制作发布版本时，这个问题才会导致游戏出错。请始终以编辑器内的项目浏览器为准，因为 Windows 文件资源管理器默认隐藏文件扩展名。

libGDX 强调通过代码工作。使用任何资源前，都必须先通过代码加载它。加载应在游戏启动时完成。打开 Core 项目 > Main.java，这是我们主要进行操作的文件。

![Main 类](/assets/images/dev/a-simple-game/5.png)

在文件顶部、`public class Main` 行正下方声明变量。计划使用的每个资源都需要一个变量：

```java
public class Main implements ApplicationListener {
    Texture backgroundTexture;
    Texture bucketTexture;
    Texture dropTexture;
    Sound dropSound;
    Music music;
```

不过，不应在构造函数或 init 阶段创建这些对象。这样做会失败，因为 libGDX 需要先完成加载。将下面的代码填入 create 方法：

```java
@Override
public void create() {
    backgroundTexture = new Texture("background.png");
    bucketTexture = new Texture("bucket.png");
    dropTexture = new Texture("drop.png");
}
```

这会在 libGDX 启动后将资源加载到内存中。可以看到，背景图像被加载为纹理。游戏通过纹理将图像保存在显存中。为游戏中的每个元素使用不同纹理其实效率不高，应该把它们放进一个大的 Texture 中。请在 wiki 中了解 [TexturePacker](/wiki/tools/texture-packer)。现在暂时保留独立纹理，因为这样更容易讲解。

同样，我们使用 Sound 处理项目中的雨滴音频文件。声音会完整加载到内存中，因此可以快速、重复地播放。而音乐文件太大，无法全部保存在内存中，会以数据块的形式从文件流式读取。声音和音乐并没有严格的区分规则，但可以将时长短于 10 秒的音频视为声音。

```java
@Override
public void create() {
    ...
    
    dropSound = Gdx.audio.newSound(Gdx.files.internal("drop.mp3"));
    music = Gdx.audio.newMusic(Gdx.files.internal("music.mp3"));
}
```

现在需要管理许多资源。我们应该使用 [AssetManager](/wiki/managing-your-assets) 处理它们，wiki 中也有相关介绍。不过这超出了本教程的范围，暂时保持简单。

## 游戏生命周期
到目前为止完成的工作都在 create 方法中。游戏运行时会立即执行 create，因此在那里加载资源很合理。这些其他方法是做什么的？libGDX 的[生命周期](/wiki/app/the-life-cycle)页面对此有更详细的说明。

由于实现了 `ApplicationListener` 接口，你的类中会包含 `create()`、`render()`、`resize(int width, int height)`、`pause()`、`resume()` 和 `dispose()`。你将使用这些方法制作本游戏以及今后使用 libGDX 制作的所有游戏。许多可用的高级系统会将这些方法的直接使用抽象掉，但它们仍然是代码的基础。

本例的大部分代码会位于 create 和 render 方法中。例如，我们不会使用 `dispose`，因为这样简单的应用不需要清理资源。对于包含多个屏幕的游戏，这一点才更为重要。

## 渲染
现在来谈谈渲染。大多数现代游戏基本上只是操作纹理，将它们绘制到屏幕上，形成你最终看到的图像，也就是帧。

这个过程每秒重复许多次，从而产生运动的假象。这正是我们要在这里做的事。先从一些样板代码开始。所谓样板代码，就是几乎不需要修改、会反复使用的相同代码。你制作的所有游戏中都会看到这种模式。声明新变量：

```java
public class Main implements ApplicationListener {
    ...

    SpriteBatch spriteBatch;
    FitViewport viewport;
```

在 create 方法中初始化这些变量：

```java
@Override
public void create() {
    ...

    spriteBatch = new SpriteBatch();
    viewport = new FitViewport(8, 5);
}
```

viewport 决定我们如何查看游戏。它就像从现实世界通往另一个世界（游戏世界）的窗口。viewport 控制这个“窗口”的大小以及它在屏幕上的位置。你可以使用多种 viewport。容易理解的一种是 FitViewport，它确保无论窗口大小如何，都能始终看到完整的游戏视图。参数决定可见游戏世界以游戏单位表示的大小，它会“适配”窗口。每个 viewport 还有一个 camera，控制游戏世界中可见的部分及缩放级别。请在 wiki 中进一步了解 [viewport 和 camera](/wiki/graphics/viewports)。

务必记得在 resize 方法中更新 viewport：

```java
@Override
public void resize(int width, int height) {
    viewport.update(width, height, true); // true centers the camera
}
```

现在代码会变得更复杂。将代码拆分到不同方法中是很好的实践。为此，我们先添加几个将在 render 方法中使用的新方法：

```java
@Override
public void render() {
    // organize code into three methods
    input();
    logic();
    draw();
}

private void input() {

}

private void logic() {

}

private void draw() {

}
```

现在先关注 `draw()` 方法。

```java
private void draw() {
    ScreenUtils.clear(Color.BLACK);
    viewport.apply();
    spriteBatch.setProjectionMatrix(viewport.getCamera().combined);
    spriteBatch.begin();

    spriteBatch.end();
}
```

`ScreenUtils.clear(Color.BLACK);` 会清空屏幕。每帧清空屏幕是很好的实践，否则会出现奇怪的图形错误。你可以使用任意颜色，但这次我们就使用黑色。

你是否想过，为什么喜欢的游戏有时 FPS（每秒帧数）很低？游戏卡顿通常与正在渲染的纹理数量以及玩家显卡的性能有关。有一些技巧可以缓解这个问题。例如，一次性将所有绘制调用发送给图形处理器（GPU）会更高效。绘制单个纹理的过程称为一次绘制调用，SpriteBatch 就是 libGDX 用来合并这些绘制调用的工具。

`spriteBatch.setProjectionMatrix(viewport.getCamera().combined);` 展示了如何将 Viewport 应用到 SpriteBatch。这是让图像显示在正确位置所必需的。

正确安排 begin 和 end 行的顺序很重要。绝不能在 begin 和 end 之外使用 SpriteBatch 绘制，否则会收到错误消息。

```java
spriteBatch.begin();
// add lines to draw stuff here
spriteBatch.end();
```

那么就开始吧。提供的坐标决定水桶在屏幕上的绘制位置。坐标从左下角开始，向右和向上增长。我们的游戏世界使用虚拟单位描述，最好将其定义为米。作为参考，水桶宽 100 像素、高 100 像素。为简单起见，我们规定 100 像素等于 1 米，因此水桶大小为 1x1 米。每米对应的像素数可以任意设定，但应选择简单且符合游戏世界的值。通常，这个值可以依据图块大小或玩家角色的高度确定。游戏逻辑实际上不应了解像素。

![坐标平面](/assets/images/dev/a-simple-game/6.png)

添加绘制水桶的代码行：

```java
private void draw() {
    ScreenUtils.clear(Color.BLACK);
    viewport.apply();
    spriteBatch.setProjectionMatrix(viewport.getCamera().combined);
    spriteBatch.begin();

    spriteBatch.draw(bucketTexture, 0, 0, 1, 1); // draw the bucket with width/height of 1 meter

    spriteBatch.end();
}
```

现在这段代码应会在屏幕底部左下角绘制水桶。你可以在 IDEA 中调用适当的 Gradle 命令运行游戏，或者按照[设置指南](/wiki/start/setup)为所选开发环境执行必要步骤。如果一切顺利，你会看到勇敢而孤独的水桶置身虚空的黑暗中。

![虚空中的水桶](/assets/images/dev/a-simple-game/7.png)

用背景让这个场景明亮起来。绘制背景与绘制水桶类似，只需按照 viewport 的宽度和高度绘制，以确保覆盖整个视图：

```java
private void draw() {
    ScreenUtils.clear(Color.BLACK);
    viewport.apply();
    spriteBatch.setProjectionMatrix(viewport.getCamera().combined);
    spriteBatch.begin();

    // store the worldWidth and worldHeight as local variables for brevity
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();

    spriteBatch.draw(bucketTexture, 0, 0, 1, 1); // draw the bucket
    spriteBatch.draw(backgroundTexture, 0, 0, worldWidth, worldHeight); // draw the background

    spriteBatch.end();
}
```

运行游戏即可看到背景。

![没有水桶的背景](/assets/images/dev/a-simple-game/8.png)

但水桶去哪了？我们需要讨论绘制顺序。绘制会按照代码中列出的顺序连续发生。实际过程如下：

1. 清空屏幕。
2. 将水桶绘制到后备缓冲区。
3. 将背景绘制到所有内容之上，然后把最终图像显示在屏幕上。

每帧都会重复这个过程。要解决问题，只需重新排列绘制调用的顺序。

```java
private void draw() {
    ScreenUtils.clear(Color.BLACK);
    viewport.apply();
    spriteBatch.setProjectionMatrix(viewport.getCamera().combined);
    spriteBatch.begin();

    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();

    // rearrange these two lines
    spriteBatch.draw(backgroundTexture, 0, 0, worldWidth, worldHeight); // draw the background
    spriteBatch.draw(bucketTexture, 0, 0, 1, 1); // draw the bucket

    spriteBatch.end();
}
```

![带水桶的背景](/assets/images/dev/a-simple-game/9.png)

确保游戏显示背景和水桶。现在先跳过水滴的渲染，等完成创建水滴的逻辑后再回来处理。

## 输入控制
没有任何屏幕移动或动作的游戏并不好玩。现在让玩家能够控制水桶。获取用户输入有许多方式，我们将关注几种：键盘、鼠标和触摸。

我们需要某种方式记录玩家水桶在游戏世界中的位置。Texture 不保存位置状态。当然，你可以使用提供的重载方法，每帧告诉 SpriteBatch 在哪里绘制它。但如果想旋转或调整大小呢？想做的操作越多，这些方法就会变得越复杂。

![过长的方法参数](/assets/images/dev/a-simple-game/10.png)

改用 Sprite 吧。Sprite 能完成这些操作并保存状态，也就是说，它会记住自身属性，不必每帧重新定义。

```java
public class Main implements ApplicationListener {
    ...
    Sprite bucketSprite; // Declare a new Sprite variable
```

```java
@Override
public void create() {
    ...
    bucketSprite = new Sprite(bucketTexture); // Initialize the sprite based on the texture
    bucketSprite.setSize(1, 1); // Define the size of the sprite
}
```

删除绘制水桶的 `spriteBatch.draw(bucketTexture, 0, 0, 1, 1);` 行。Sprite 的绘制方式不同：

```java
private void draw() {
    ScreenUtils.clear(Color.BLACK);
    viewport.apply();
    spriteBatch.setProjectionMatrix(viewport.getCamera().combined);
    spriteBatch.begin();

    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();

    spriteBatch.draw(backgroundTexture, 0, 0, worldWidth, worldHeight);
    bucketSprite.draw(spriteBatch); // Sprites have their own draw method

    spriteBatch.end();
}
```
再次运行游戏，输出应该没有任何变化。这就对了！如果看不到水桶，请确认已正确调整上面指出的代码行。

### 键盘
现在捕获玩家输入。通过这种方式可以检测玩家是否按下键盘按键，操作需要发生在 input 方法中。

```java
private void input() {
    if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
        // todo: Do something when the user presses the right arrow
    }
}
```

这称为键盘轮询。每次绘制帧时，我们都会检查是否有按键按下。`Gdx.input.Input.Keys` 中列出了几乎所有可能的按键。我们要响应用户按下右箭头键。

![按键列表](/assets/images/dev/a-simple-game/11.png)

很好，但按下按键后应该发生什么？我们需要移动水桶 Sprite 的坐标。

```java
private void input() {
    float speed = .25f;

    if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
        bucketSprite.translateX(speed); // Move the bucket right
    }
}
```

变量 `speed` 决定水桶移动的速度。给 x 加值会让水桶向右移动，本质上就是“将水桶的 x 设置为当前值再多一点”。从 x 减值会让水桶向左移动。

将逻辑放在 render 方法中的一个不良副作用是，代码在不同硬件上的行为会不同，这是帧率差异造成的。每秒帧数越多，每秒移动的距离就越大。

![FPS 对比](/assets/images/dev/a-simple-game/12.png)

为了解决这个问题，需要使用 delta time。Delta time 是测得的帧间时间。将移动量乘以 delta time 后，无论在什么硬件上运行游戏，移动都会保持一致。

```java
private void input() {
    float speed = .25f;
    float delta = Gdx.graphics.getDeltaTime(); // retrieve the current delta

    if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
        bucketSprite.translateX(speed * delta); // Move the bucket right
    }
}
```

这意味着此处选择的数值就是水桶一秒内移动的距离。计算随时间发生的事情时，记得使用 delta time。将数值调整为能让水桶以合适速度移动的值，例如 `4f`。现在复制向左移动的代码，将加号改为减号即可向左移动。

```java
private void input() {
    float speed = 4f;
    float delta = Gdx.graphics.getDeltaTime();

    if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
        bucketSprite.translateX(speed * delta); // move the bucket right
    } else if (Gdx.input.isKeyPressed(Input.Keys.LEFT)) {
        bucketSprite.translateX(-speed * delta); // move the bucket left
    }
}
```

再次运行游戏，确认可以使用键盘让水桶左右移动。

### 鼠标和触摸控制
鼠标和触摸控制相关。要响应用户点击或触摸屏幕，调用下面的方法：

```java
private void input() {
    float speed = 4f;
    float delta = Gdx.graphics.getDeltaTime();

    if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
        bucketSprite.translateX(speed * delta);
    } else if (Gdx.input.isKeyPressed(Input.Keys.LEFT)) {
        bucketSprite.translateX(-speed * delta);
    }

    if (Gdx.input.isTouched()) { // If the user has clicked or tapped the screen
        // todo:React to the player touching the screen
    }
}
```

玩家已经点击了屏幕，但点击的是哪里？可以使用 Gdx.input.getX() 和 Gdx.input.getY() 方法获取位置。不过这些值是窗口坐标，与我们选择的每米像素数无关。由于窗口坐标从左上角开始，坐标方向也是上下颠倒的。我们需要声明一个 Vector2 对象进行计算。

```java
public class Main implements ApplicationListener {
    ...
    Vector2 touchPos;
```

初始化 Vector2：

```java
@Override
public void create() {
    ...

    touchPos = new Vector2();
}
```

注意，我们为 Vector2 创建了一个实例变量，而不是在本地创建对象。重复使用这个 Vector2，可以避免游戏频繁触发垃圾回收器，从而防止游戏出现卡顿尖峰。下面是使用 Vector2 移动水桶的方法：

```java
private void input() {
    float speed = 4f;
    float delta = Gdx.graphics.getDeltaTime();

    if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
        bucketSprite.translateX(speed * delta);
    } else if (Gdx.input.isKeyPressed(Input.Keys.LEFT)) {
        bucketSprite.translateX(-speed * delta);
    }

    if (Gdx.input.isTouched()) {
        touchPos.set(Gdx.input.getX(), Gdx.input.getY()); // Get where the touch happened on screen
        viewport.unproject(touchPos); // Convert the units to the world units of the viewport
        bucketSprite.setCenterX(touchPos.x); // Change the horizontally centered position of the bucket
    }
}
```

这会将窗口坐标转换为世界空间中的坐标。这段代码实际上也支持移动设备，不过你还应阅读 libGDX 提供的[其他输入功能](/wiki/input/event-handling)。运行游戏并点击屏幕移动水桶。

## 游戏逻辑
现在玩家可以左右移动，但水桶可能完全移出屏幕。我们需要阻止这种情况。libGDX 的 `MathUtils` 类提供了一些有用的方法，可以使用 `clamp()` 实现目标。记住，屏幕左侧从 0 开始。这段代码检测水桶是否向左移动得太远，如果是，就将其位置限制在允许到达的最远位置。将下面几行添加到 logic 方法中：

```java
private void logic() {
    // Store the worldWidth and worldHeight as local variables for brevity
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();

    // Clamp x to values between 0 and worldWidth
    bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth));
}
```

试试游戏。它基本能工作，但水桶会向右多移动一点，实际上多出一个完整单位。这是因为水桶 Sprite 的原点位于图像左下角。解决方法是从右边界减去水桶宽度。

```java
private void logic() {
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();

    // Store the bucket size for brevity
    float bucketWidth = bucketSprite.getWidth();
    float bucketHeight = bucketSprite.getHeight();

    // Subtract the bucket width
    bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));
}
```

现在生成雨滴。雨滴不止一个，因此需要用列表记录它们。libGDX 提供了许多有用的[集合](/wiki/utils/collections)来帮助完成这件事。声明列表：

```java
public class Main implements ApplicationListener {
    ...
    Array<Sprite> dropSprites;
```

初始化列表：

```java
public void create() {
    ...

    dropSprites = new Array<>();
}
```

和之前一样，建议将代码组织到不同方法中。创建一个生成水滴的新方法，将它放在 draw 方法之后。

```java
private void draw() {
    ...
}

private void createDroplet() {
    // create local variables for convenience
    float dropWidth = 1;
    float dropHeight = 1;
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();
    
    // create the drop sprite
    Sprite dropSprite = new Sprite(dropTexture);
    dropSprite.setSize(dropWidth, dropHeight);
    dropSprite.setX(0);
    dropSprite.setY(worldHeight);
    dropSprites.add(dropSprite); // Add it to the list
}

@Override
public void pause() {

}
```

水滴大小与玩家相同。将 y 位置设在屏幕顶部，就会看起来像从天上落下。`dropSprites.add(dropSprite);` 行将水滴加入列表，以便在渲染循环中管理。

我们将在 create 方法中调用 `createDroplet()`。

```java
public void create() {
    ...
    dropSprites = new Array<>();

    createDroplet();
}
```

绘制每个水滴很简单。将 Sprite 绘制代码添加到 draw 方法：

```java
private void draw() {
    ScreenUtils.clear(Color.BLACK);
    viewport.apply();
    spriteBatch.setProjectionMatrix(viewport.getCamera().combined);
    spriteBatch.begin();

    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();

    spriteBatch.draw(backgroundTexture, 0, 0, worldWidth, worldHeight);
    bucketSprite.draw(spriteBatch);

    // draw each sprite
    for (Sprite dropSprite : dropSprites) {
        dropSprite.draw(spriteBatch);
    }

    spriteBatch.end();
}
```

现在运行程序，你会发现什么也没有发生，因为水滴还没有移动代码。在水桶逻辑之后开始编写水滴逻辑：

```java
private void logic() {
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();
    float bucketWidth = bucketSprite.getWidth();
    float bucketHeight = bucketSprite.getHeight();

    bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));

    float delta = Gdx.graphics.getDeltaTime(); // retrieve the current delta

    // loop through each drop
    for (Sprite dropSprite : dropSprites) {
        dropSprite.translateY(-2f * delta); // move the drop downward every frame
    }
}
```

这里有个问题：雨滴每次都只在左侧生成。当然可以修改位置，但那样没有变化，也没有随机性。我们需要让它出现在 0 到世界宽度之间的随机位置。

```java
private void createDroplet() {
    float dropWidth = 1;
    float dropHeight = 1;
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();
    
    Sprite dropSprite = new Sprite(dropTexture);
    dropSprite.setSize(dropWidth, dropHeight);
    dropSprite.setX(MathUtils.random(0f, worldWidth - dropWidth)); // Randomize the drop's x position
    dropSprite.setY(worldHeight);
    dropSprites.add(dropSprite);
}
```

再次减去 Sprite 的宽度，这样雨滴就不会出现在视图之外。成功！

不过这只有一个水滴。下雨时，应该随着时间产生多个水滴。将生成水滴的代码移到 logic 方法中。这样每帧都会重复生成水滴。先从 create 方法中剪切这一行：

![剪切水滴代码](/assets/images/dev/a-simple-game/13.png)

将它粘贴到 logic 方法中：

```java
private void logic() {
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();
    float bucketWidth = bucketSprite.getWidth();
    float bucketHeight = bucketSprite.getHeight();

    bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));

    float delta = Gdx.graphics.getDeltaTime();

    for (Sprite dropSprite : dropSprites) {
        dropSprite.translateY(-2f * delta);
    }

    // paste the line here
    createDroplet();
}
```

运行后会发现一场灾难！水滴太多了。

![水滴太多](/assets/images/dev/a-simple-game/14.png)

每次生成之间应有延迟。当需要某件事随时间重复执行并带有延迟时，可以创建计时器。声明一个新变量保存时间：

```java
public class Main implements ApplicationListener {
    ...
    float dropTimer;
```

`dropTimer` 用于记录每次生成之间经过了多少时间。修改 logic 方法中的代码：

```java
private void logic() {
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();
    float bucketWidth = bucketSprite.getWidth();
    float bucketHeight = bucketSprite.getHeight();

    bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));

    float delta = Gdx.graphics.getDeltaTime();

    for (Sprite dropSprite : dropSprites) {
        dropSprite.translateY(-2f * delta);
    }

    dropTimer += delta; // Adds the current delta to the timer
    if (dropTimer > 1f) { // Check if it has been more than a second
        dropTimer = 0; // Reset the timer
        createDroplet(); // Create the droplet
    }
}
```

`dropTimer` 会累积每帧之间经过的时间。如果超过一秒，就更新记录的时间并生成水滴。现在它已经按预期工作了。

![三个水滴](/assets/images/dev/a-simple-game/15.png)

这些水滴会落出屏幕，再也看不到。但 Java 不会忘记它们：水滴会永远留在内存中。如果对游戏进行[性能分析](https://visualvm.github.io/)，就会发现内存泄漏。

![内存分析](/assets/images/dev/a-simple-game/16.png)

如果玩家让游戏运行很长时间，游戏最终会崩溃。因此，水滴落出屏幕后应从列表中移除。我们需要大幅修改 logic 中的 for 循环。删除 logic 方法中的循环：

![删除代码行](/assets/images/dev/a-simple-game/17.png)

替换为下面的循环：

```java
private void logic() {
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();
    float bucketWidth = bucketSprite.getWidth();
    float bucketHeight = bucketSprite.getHeight();

    bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));

    float delta = Gdx.graphics.getDeltaTime();

    // Loop through the sprites backwards to prevent out of bounds errors
    for (int i = dropSprites.size - 1; i >= 0; i--) {
        Sprite dropSprite = dropSprites.get(i); // Get the sprite from the list
        float dropWidth = dropSprite.getWidth();
        float dropHeight = dropSprite.getHeight();

        dropSprite.translateY(-2f * delta);

        // if the top of the drop goes below the bottom of the view, remove it
        if (dropSprite.getY() < -dropHeight) dropSprites.removeIndex(i);
    }

    dropTimer += delta;
    if (dropTimer > 1f) {
        dropTimer = 0;
        createDroplet();
    }
}
```

遍历列表时删除其中的项目可能导致不可预料的错误。因此我们反向遍历列表，避免跳过索引。对于更复杂的项目，请务必了解其他可用的[集合](/wiki/utils/collections#specialized-lists)，例如 SnapshotArray 和 DelayedRemovalArray。

我们已经取得很大进展，但水滴还不会与水桶互动。现在加入基本的碰撞检测。可以使用 Rectangle 类实现。我们需要两个矩形进行比较：一个用于水桶，另一个供每个水滴重复使用。

```java
public class Main implements ApplicationListener {
    ...
    Rectangle bucketRectangle;
    Rectangle dropRectangle;
```

```java
@Override
public void create() {
    ...

    bucketRectangle = new Rectangle();
    dropRectangle = new Rectangle();
}
```

现在代码会将矩形设置为 Sprite 的位置和尺寸。

```java
private void logic() {
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();
    float bucketWidth = bucketSprite.getWidth();
    float bucketHeight = bucketSprite.getHeight();

    bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));

    float delta = Gdx.graphics.getDeltaTime();
    // Apply the bucket position and size to the bucketRectangle
    bucketRectangle.set(bucketSprite.getX(), bucketSprite.getY(), bucketWidth, bucketHeight);

    for (int i = dropSprites.size - 1; i >= 0; i--) {
        Sprite dropSprite = dropSprites.get(i);
        float dropWidth = dropSprite.getWidth();
        float dropHeight = dropSprite.getHeight();

        dropSprite.translateY(-2f * delta);
        // Apply the drop position and size to the dropRectangle
        dropRectangle.set(dropSprite.getX(), dropSprite.getY(), dropWidth, dropHeight);

        if (dropSprite.getY() < -dropHeight) dropSprites.removeIndex(i);
        else if (bucketRectangle.overlaps(dropRectangle)) { // Check if the bucket overlaps the drop
            dropSprites.removeIndex(i); // Remove the drop
        }
    }

    dropTimer += delta;
    if (dropTimer > 1f) {
        dropTimer = 0;
        createDroplet();
    }
}
```

`bucketRectangle.overlaps(dropRectangle)` 检查水桶是否与水滴重叠。如果重叠，就会从水滴 Sprite 列表中移除该 Sprite，也就不会再绘制或处理它。它相当于不再存在，看起来就像被水桶收集了一样。确认游戏按预期运行，你就快完成了！

## 声音和音乐
现在流程接近尾声，添加一行代码播放音效很容易。我们希望水桶与水滴碰撞时播放水滴声音（本教程开头加载的音效），而水滴落出关卡时不应播放。

```java
private void logic() {
    float worldWidth = viewport.getWorldWidth();
    float worldHeight = viewport.getWorldHeight();
    float bucketWidth = bucketSprite.getWidth();
    float bucketHeight = bucketSprite.getHeight();

    bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));

    float delta = Gdx.graphics.getDeltaTime();
    bucketRectangle.set(bucketSprite.getX(), bucketSprite.getY(), bucketWidth, bucketHeight);

    for (int i = dropSprites.size - 1; i >= 0; i--) {
        Sprite dropSprite = dropSprites.get(i);
        float dropWidth = dropSprite.getWidth();
        float dropHeight = dropSprite.getHeight();

        dropSprite.translateY(-2f * delta);
        dropRectangle.set(dropSprite.getX(), dropSprite.getY(), dropWidth, dropHeight);
        
        if (dropSprite.getY() < -dropHeight) dropSprites.removeIndex(i);
        else if (bucketRectangle.overlaps(dropRectangle)) {
            dropSprites.removeIndex(i);
            dropSound.play(); // Play the sound
        }
    }

    dropTimer += delta;
    if (dropTimer > 1f) {
        dropTimer = 0;
        createDroplet();
    }
}
```

音乐应在游戏开始时播放，并持续循环，直到玩家结束游戏。文件音量也有些大，因此应以一半音量播放。音量取值范围为 0f 到 1f，其中 1f 是文件的正常音量。

```java
@Override
public void create() {
    ...

    music.setLooping(true);
    music.setVolume(.5f);
    music.play();
}
```

确认扬声器已打开，然后试试看。

## 进一步学习
现在已经到了制作游戏的最后几步。应该测试游戏，并调整数值让游戏变得更简单或更困难。可以改变水桶移动速度以及水滴生成频率。

如果想让朋友和同事试玩游戏，就需要制作他们可以运行的分发包。没人愿意为了玩游戏而设置 IDE 并复制整个项目。请参阅[部署应用](/wiki/deployment/deploying-your-application)页面。

现在已经完成简单游戏，是时候[扩展简单游戏](/wiki/start/simple-game-extended)了。本项目为了保持简单，将所有代码放在一个类中，但这是一种很糟糕的代码组织方式。下一篇教程将介绍 Game 类，以及如何实现 Screen 来组织项目，还会讲解其他重要的游戏改进。例如，本教程跳过了 dispose() 方法，因为它与单页面项目无关。使用多个屏幕时，可能需要释放上一个屏幕的资源，为游戏中的新资源释放内存。

游戏设计是持续学习的旅程。[wiki](/wiki/) 对你在这里学到的所有主题都有更深入的介绍。可以进一步了解[集合](/wiki/utils/collections)、[TexturePacker](/wiki/tools/texture-packer)、[AssetManager](/wiki/managing-your-assets)、[音频](/wiki/audio/audio)、[内存管理](/wiki/articles/memory-management)和[用户输入](/wiki/input/input-handling)。

本教程完全聚焦于桌面开发。在探索 Android、iOS 和 HTML5 开发前，还必须考虑许多其他事项。例如，这里有一篇详细介绍 [HTML5 注意事项](/wiki/html5-backend-and-gwt-specifics)的文章。Java 并不真正做到“一次编写，到处运行”，但 libGDX 能让你非常接近这个目标。

## 完整示例代码
下面是本教程中介绍的游戏的完整示例代码。如果你在某一步遇到困难，可以参考它。不要通过复制全部代码来欺骗自己！学习编程主要是自己提出问题，并先尝试独立解决问题。

```java
package com.badlogic.drop;

import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.Gdx;
import com.badlogic.gdx.Input;
import com.badlogic.gdx.audio.Music;
import com.badlogic.gdx.audio.Sound;
import com.badlogic.gdx.graphics.Color;
import com.badlogic.gdx.graphics.Texture;
import com.badlogic.gdx.graphics.g2d.Sprite;
import com.badlogic.gdx.graphics.g2d.SpriteBatch;
import com.badlogic.gdx.math.MathUtils;
import com.badlogic.gdx.math.Rectangle;
import com.badlogic.gdx.math.Vector2;
import com.badlogic.gdx.utils.Array;
import com.badlogic.gdx.utils.ScreenUtils;
import com.badlogic.gdx.utils.viewport.FitViewport;

public class Main implements ApplicationListener {
    Texture backgroundTexture;
    Texture bucketTexture;
    Texture dropTexture;
    Sound dropSound;
    Music music;
    SpriteBatch spriteBatch;
    FitViewport viewport;
    Sprite bucketSprite;
    Vector2 touchPos;
    Array<Sprite> dropSprites;
    float dropTimer;
    Rectangle bucketRectangle;
    Rectangle dropRectangle;

    @Override
    public void create() {
        backgroundTexture = new Texture("background.png");
        bucketTexture = new Texture("bucket.png");
        dropTexture = new Texture("drop.png");
        dropSound = Gdx.audio.newSound(Gdx.files.internal("drop.mp3"));
        music = Gdx.audio.newMusic(Gdx.files.internal("music.mp3"));
        spriteBatch = new SpriteBatch();
        viewport = new FitViewport(8, 5);
        bucketSprite = new Sprite(bucketTexture);
        bucketSprite.setSize(1, 1);
        touchPos = new Vector2();
        dropSprites = new Array<>();
        bucketRectangle = new Rectangle();
        dropRectangle = new Rectangle();
        music.setLooping(true);
        music.setVolume(.5f);
        music.play();
    }

    @Override
    public void resize(int width, int height) {
        viewport.update(width, height, true);
    }

    @Override
    public void render() {
        input();
        logic();
        draw();
    }

    private void input() {
        float speed = 4f;
        float delta = Gdx.graphics.getDeltaTime();

        if (Gdx.input.isKeyPressed(Input.Keys.RIGHT)) {
            bucketSprite.translateX(speed * delta);
        } else if (Gdx.input.isKeyPressed(Input.Keys.LEFT)) {
            bucketSprite.translateX(-speed * delta);
        }

        if (Gdx.input.isTouched()) {
            touchPos.set(Gdx.input.getX(), Gdx.input.getY());
            viewport.unproject(touchPos);
            bucketSprite.setCenterX(touchPos.x);
        }
    }

    private void logic() {
        float worldWidth = viewport.getWorldWidth();
        float worldHeight = viewport.getWorldHeight();
        float bucketWidth = bucketSprite.getWidth();
        float bucketHeight = bucketSprite.getHeight();

        bucketSprite.setX(MathUtils.clamp(bucketSprite.getX(), 0, worldWidth - bucketWidth));

        float delta = Gdx.graphics.getDeltaTime();
        bucketRectangle.set(bucketSprite.getX(), bucketSprite.getY(), bucketWidth, bucketHeight);

        for (int i = dropSprites.size - 1; i >= 0; i--) {
            Sprite dropSprite = dropSprites.get(i);
            float dropWidth = dropSprite.getWidth();
            float dropHeight = dropSprite.getHeight();

            dropSprite.translateY(-2f * delta);
            dropRectangle.set(dropSprite.getX(), dropSprite.getY(), dropWidth, dropHeight);

            if (dropSprite.getY() < -dropHeight) dropSprites.removeIndex(i);
            else if (bucketRectangle.overlaps(dropRectangle)) {
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
        viewport.apply();
        spriteBatch.setProjectionMatrix(viewport.getCamera().combined);
        spriteBatch.begin();

        float worldWidth = viewport.getWorldWidth();
        float worldHeight = viewport.getWorldHeight();

        spriteBatch.draw(backgroundTexture, 0, 0, worldWidth, worldHeight);
        bucketSprite.draw(spriteBatch);

        for (Sprite dropSprite : dropSprites) {
            dropSprite.draw(spriteBatch);
        }

        spriteBatch.end();
    }

    private void createDroplet() {
        float dropWidth = 1;
        float dropHeight = 1;
        float worldWidth = viewport.getWorldWidth();
        float worldHeight = viewport.getWorldHeight();

        Sprite dropSprite = new Sprite(dropTexture);
        dropSprite.setSize(dropWidth, dropHeight);
        dropSprite.setX(MathUtils.random(0f, worldWidth - dropWidth));
        dropSprite.setY(worldHeight);
        dropSprites.add(dropSprite);
    }

    @Override
    public void pause() {
        
    }

    @Override
    public void resume() {
        
    }

    @Override
    public void dispose() {
        
    }
}
```
