---
title: 性能分析
---
本文介绍一些实用的辅助类和工具，以便在遇到性能问题、需要开始分析游戏性能时使用。

# FPSLogger

[`FPSLogger`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/FPSLogger.html) 是一个用于记录帧率的简单辅助类。在渲染方法中调用 `log()` 方法即可，每秒会记录一次输出。

# PerformanceCounter

[`PerformanceCounter`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/PerformanceCounter.html) 会记录特定任务所需的时间和负载（占总时间的百分比）。在任务开始前调用 `start()`，结束后立即调用 `stop()`。如有需要，可以重复执行。每次渲染或更新时调用 `tick()` 更新数值。`time` FloatCounter 提供任务最小、最大、平均、总计和当前耗时；`load` 值同理，它表示占总时间的百分比。

# OpenGL
## 性能分析
分析游戏运行期间实际发生的 OpenGL 调用通常并不容易，因为 libGDX 会将这些底层细节抽象掉。要收集这些信息，可以使用 [`GLProfiler`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/profiling/GLProfiler.html)。

要启用它，需要实例化 GLProfiler 对象，然后调用 `glProfiler.enable()` 方法。在后台，这会用 profiler 替换原来的 `GL20` 和 `GL30` 实例（`Gdx.gl` 等）。

现在 profiler 会生效并开始监控实际 GL 调用（以及 GL 错误，见下文）。你可能会关心纹理绑定次数，因为纹理绑定开销较大，可能拖慢游戏。可以使用 `TextureAtlas` 进行优化，并调用 `glProfiler.getTextureBindings()` 通过实际数字确认纹理绑定次数减少。

还可以实现视锥体剔除，只渲染屏幕上可见的内容。`glProfiler.getDrawCalls()` 方法会返回执行的绘制调用总数。

profiler 提供以下信息：
- OpenGL 调用总数
- 绘制调用数
- 纹理绑定数
- 着色器切换数
- 使用的顶点数

`glProfiler.getVertexCount()` 返回一个 [`FloatCounter`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/math/FloatCounter.html)。通过 FloatCounter 可以访问提供更多信息的字段（count、total、min、max、average、latest 和 value）。

读取并显示这些数字后（可能每帧一次），需要调用 `glProfiler.reset()` 方法将其全部重置。要完全禁用性能分析并将 profiler 替换回原来的 `GL20` 和 `GL30` 实例，请使用 `glProfiler.disable()`。

*注意，如果使用 `Gdx.graphics.getGL20()` 或 `Gdx.graphics.getGL30()`，就会绕过 profiler，因此应直接使用 `Gdx.gl20` 或 `Gdx.gl30`。*

有关用法请参阅 [Benchmark3DTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/g3d/Benchmark3DTest.java)。

## 错误检查（自 1.6.5 起）
`GLProfiler` 还有一个实用功能，即错误检查。

几乎所有 GL 调用在某些情况下都可能产生错误。这些错误不像 Java 错误那样抛出或记录，而是必须显式检查（`Gdx.gl.getError()`），因此很难发现。启用 `GLProfiler`（启用方法见上文）后，它会在每次 GL 调用后自动检查并报告 GL 错误，无需手动检查。

默认情况下，遇到的错误会通过 `Gdx.app.error` 输出到控制台。不过，也可以通过 [`glProfiler.setListener()`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/profiling/GLProfiler.html#setListener-com.badlogic.gdx.graphics.profiling.GLErrorListener-) 设置其他错误监听器进行自定义，例如接入自己的日志或崩溃报告系统。

如果想准确了解错误在代码中的位置，可以使用 [`GLErrorListener.THROWING_LISTENER`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/profiling/GLErrorListener.html#THROWING_LISTENER)，它会在出现任何 GL 错误时抛出异常。错误监听器回调在 GL 调用内部执行，因此堆栈跟踪会显示具体出错位置。_（GL 错误抛出异常很可能导致应用崩溃，因此默认不使用。）_

有关使用和测试示例，请参阅 [GLProfilerErrorTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/GLProfilerErrorTest.java)。

# apitrace

[apitrace](https://github.com/apitrace/apitrace) 是一个用于 OpenGL 的开源跨平台调试器和 profiler。运行 tracer 可以记录状态及每次调用（包括缓冲区内容），再运行查看工具读取跟踪文件，并回放任意时间点的状态。它会细分 CPU/GPU 时间和每一次 OpenGL 调用；你可以查看任意时刻帧缓冲的内容以及绑定的每个纹理。

运行方式：
在 Linux 上执行：
```apitrace trace java -cp /home/me/my-app/desktop/build/libs/*.jar  -Dorg.lwjgl.opengl.libname=/usr/lib/apitrace/wrappers/glxtrace.so com.my.app.desktop.DesktopLauncher```
 
然后退出应用（如果需要），运行 ```qapitrace``` 并打开跟踪文件。
