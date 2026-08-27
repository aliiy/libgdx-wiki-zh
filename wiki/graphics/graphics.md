---
title: 图形
---
# 需要重写
此页面需要重写。

# 简介

[`Graphics`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Graphics.html) 模块提供当前设备显示屏和应用窗口的信息，以及当前 OpenGL 上下文的信息和访问方式。具体来说，屏幕尺寸、像素密度，以及帧缓冲区的颜色深度、深度/模板缓冲区和抗锯齿能力等属性，都可以在此类中获取。与其他公共模块一样，可以通过 [`Gdx` 类](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Gdx.html) 的静态字段访问它。

# OpenGL 上下文

此模块的一个用途是直接访问当前 OpenGL 上下文，以执行更底层的命令和查询。

下面的示例在 OpenGL ES2 应用中访问上下文，设置视口并清除帧缓冲区和深度缓冲区：

```java
Gdx.gl20.glViewport( 0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight() );
Gdx.gl20.glClearColor( 0, 0, 0, 1 );
Gdx.gl20.glClear( GL20.GL_COLOR_BUFFER_BIT | GL20.GL_DEPTH_BUFFER_BIT );
```

注意，设置视口时使用了 `getWidth()` / `getHeight()` 获取当前应用窗口尺寸，也使用了 `GL20` 类中的常量，这与普通 OpenGL 程序相同。libGDX 的一个重要优势是：当更高层的抽象无法满足需求时，仍然可以访问底层功能。

每个版本的 OpenGL ES 都可以通过各自的接口访问；此外还可以通过 GLCommon（**该接口并不存在，此文章需要重写！**）接口执行与版本无关的命令。请注意，使用 [GL20](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/GL20.html) 要求在启动时指示应用使用 OpenGL ES2。

此外还提供了对 OpenGL Utility 类（**该类并不存在，此文章需要重写！**）的访问，不过这项功能可能更适合通过 libGDX 自己的 [Orthographic](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/OrthographicCamera.java) 和 [Perspective](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/PerspectiveCamera.java) 相机类处理。`supportsExtension()` 还提供了一个简单方法，用于查询对指定名称扩展的支持情况。只需提供扩展名称，即可确定当前设备是否支持它。

# 帧时间

`Graphics` 类中一个特别有用的方法是 `getDeltaTime()`，它返回自上一帧渲染以来经过的时间。当不要求动画与帧率完全独立时，这对基于时间的动画很有用。例如，可以在应用的渲染方法中使用下面这样的调用，控制 [Stage](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/scenes/scene2d/Stage.java) 实例中的 [Actor](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/scenes/scene2d/Actor.java) 或 [UI](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/#gdx%2Fscenes%2Fscene2d%2Fui) 动画：

```java
stage.act( Math.min( Gdx.graphics.getDeltaTime(), 1/30 ) );
```

注意这里将最大时间步长限制为 1/30 秒，以避免动画出现过大的跳动。这说明 `getDeltaTime()` 虽然适合简单动画，但仍然依赖帧率；游戏逻辑或物理模拟等更敏感的操作，可能更适合使用[其他计时策略](https://gafferongames.com/post/fix_your_timestep/)。

另一个有用的方法是 `getFramesPerSecond()`，它返回当前帧率的滑动平均值，可用于简单诊断。但对于更严肃的性能分析，建议使用 [FPSLogger](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/FPSLogger.java)。

# 平台差异

在桌面平台上，`Graphics` 类还可以设置窗口图标和标题。显然，在不支持图标或标题的平台上，这些方法不会产生效果。

`setDisplayMode()` 和 `setVSync()` 方法分别用于将显示模式设置为全屏/窗口模式，以及启用/禁用垂直同步。请注意，这些方法只在部分平台上有效。
