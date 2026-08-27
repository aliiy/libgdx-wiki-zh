---
title: 视口
---
处理不同屏幕时，通常需要决定采用何种策略来处理不同的屏幕尺寸和宽高比。libGDX 的 [`Viewport`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/viewport/Viewport.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/viewport/Viewport.java)）正是为此设计的。Camera 和 Stage 支持不同的视口策略，例如通过 `Camera.project(vec, viewportX, viewportY, viewportWidth, viewportHeight)` 进行拾取时。

如果你以前从未使用过视口，**务必阅读这篇全面的介绍：**

{% include video id="8N2vw_3h9HU" provider="youtube" %}

视频文字稿也可以在[这里](https://github.com/raeleus/viewports-sample-project#libgdx-viewports)找到。如果难以为当前情况选择合适的视口，[这里](https://raeleus.github.io/viewports-sample-project/)和[这里](https://crykn.github.io/viewports-showcase/)的**交互式示例**一定会很有帮助。

### 用法
视口始终管理 Camera 的 viewportWidth 和 viewportHeight，因此构造函数需要传入一个相机。
```java
    private Viewport viewport;
    private Camera camera;

    public void create() {
        camera = new PerspectiveCamera();
        viewport = new FitViewport(800, 480, camera);
    }
```
每当发生调整大小事件时，都需要通知视口并更新它。这样会自动重新计算视口参数并更新相机：
```java
    public void resize(int width, int height) {
        viewport.update(width, height);
    }
```
此外，它会通过 glViewport 修改 OpenGL 视口；必要时可能添加黑边，此时黑边区域无法进行渲染。如果某种视口策略出现黑边，可以将 OpenGL 视口重置为标准大小，再通过 `Viewport.getLeftGutterWidth()` 等方法查询黑边尺寸。具体示例请参阅[此测试](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/ViewportTest2.java)。效果可能如下所示（当然也许应该使用更合适的边框图片……）。

![images/OVamVTh.png](/assets/wiki/images/OVamVTh.png)

如果需要进行拾取，Viewport 提供了方便的 `project/unproject/getPickRay` 方法，会使用当前视口执行正确的拾取。这些方法用于在屏幕坐标和世界坐标之间转换。

使用 Stage 时，发生调整大小事件后也需要更新 Stage 的视口。
```java
    private Stage stage;

    public void create() {
        stage = new Stage(new StretchViewport(width, height));
    }

    public void resize(int width, int height) {
        // use true here to center the camera
        // that's what you probably want in case of a UI
        stage.getViewport().update(width, height, true);
    }
```
### 多个视口

使用具有不同屏幕尺寸的多个视口时（或使用其他会设置 `glViewport` 的代码），需要在绘制前应用视口，以便为该视口设置 `glViewport`。
```java
    viewport1.apply();
    // draw
    viewport2.apply();
    // draw
```
使用多个 Stage 时：
```java
    stage1.getViewport().apply();
    stage1.draw();
    stage2.getViewport().apply();
    stage2.draw();
```

### 示例

**要查看视口的实际效果，请参考[这里](https://raeleus.github.io/viewports-sample-project/)和[这里](https://crykn.github.io/viewports-showcase/)的交互式示例。**此外还有一些视口相关测试：[ViewportTest1](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/ViewportTest1.java)、[ViewportTest2](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/ViewportTest2.java) 和 [ViewportTest3](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/ViewportTest3.java)。

### StretchViewport
[`StretchViewport`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/viewport/StretchViewport.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/viewport/StretchViewport.java)）支持使用虚拟屏幕尺寸，也就是说可以假设屏幕始终为 `virtualWidth x virtualHeight`。该虚拟视口随后会始终拉伸以适应屏幕。不会出现黑边，但缩放后宽高比可能发生变化。

![images/oheUy0y.png](/assets/wiki/images/oheUy0y.png)

### FitViewport
[`FitViewport`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/viewport/FitViewport.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/viewport/FitViewport.java)）同样支持虚拟屏幕尺寸。与 StretchViewport 的区别在于，它始终保持虚拟屏幕尺寸（虚拟视口）的宽高比，同时尽可能缩放以适应屏幕。这种策略的缺点是可能出现黑边。

![images/Kv2wB94.png](/assets/wiki/images/Kv2wB94.png)

### FillViewport
[`FillViewport`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/viewport/FillViewport.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/viewport/FillViewport.java)）也会保持虚拟屏幕尺寸的宽高比，但与 FitViewport 不同，它始终填满整个屏幕，可能导致视口的一部分被裁切。

### ScreenViewport
[`ScreenViewport`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/viewport/ScreenViewport.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/viewport/ScreenViewport.java)）没有固定的虚拟屏幕尺寸，而是始终匹配窗口大小，因此不会发生缩放，也不会出现黑边。缺点是游戏体验可能改变：屏幕更大的玩家可能比屏幕更小的玩家看到更多游戏内容。

![images/qtOytdq.png](/assets/wiki/images/qtOytdq.png)

### ExtendViewport
[`ExtendViewport`](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/utils/viewport/ExtendViewport.html)（[源代码](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/utils/viewport/ExtendViewport.java)）通过沿一个方向扩展世界，在不出现黑边的情况下保持世界宽高比。世界会先缩放到适合视口的大小，然后延长较短的尺寸以填满视口。

![images/HX6QS8r.png](/assets/wiki/images/HX6QS8r.png)

可以为 `ExtendViewport` 提供一组最大尺寸；当宽高比超出支持范围时，会添加黑边。

![images/vQeRKPY.png](/assets/wiki/images/vQeRKPY.png)

### CustomViewport
可以通过执行 `CustomViewport extends Viewport` 并重写 `update(width, height, centerCamera)` 实现不同策略。另一种方式是使用通用的 `ScalingViewport`，并传入其他视口尚未覆盖的 Scaling。例如传入 `Scaling.none`，即可得到完全“静态”的 StaticViewport，始终保持相同尺寸。示例如下：

![images/8F697TX.png](/assets/wiki/images/8F697TX.png)
