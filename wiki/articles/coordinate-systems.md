---
title: 坐标系
---
使用 libGDX（或任何其他基于 OpenGL 的系统）时，需要处理各种[坐标系](https://en.wikipedia.org/wiki/Coordinate_system)。这是因为 OpenGL 抽象了设备相关的单位，使程序更容易适配多种设备，并专注于游戏逻辑。有时需要在坐标系之间转换，libGDX 为此提供了多种方法。

**理解当前使用的坐标系至关重要，否则很容易混淆并作出错误假设。**
{: .notice--info}

本页列出了各种坐标系。强烈建议先熟悉[笛卡尔坐标系](https://en.wikipedia.org/wiki/Cartesian_coordinate_system)的概念，这是最广泛使用的坐标系。

  * [触摸坐标](#touch-coordinates)
  * [屏幕或图像坐标](#screen-or-image-coordinates)
   * [Pixmap 和纹理坐标](#pixmap-and-texture-coordinates)
  * [归一化渲染坐标](#normalized-render-coordinates)
  * [归一化纹理（UV）坐标](#normalized-texture-UV-coordinates)
  * [世界坐标](#world-coordinates)
   * [GUI/HUD 坐标](#guihud-coordinates)
   * [游戏坐标](#game-coordinates)

## 触摸坐标

<table>
  <tr>
    <td>单位</td>
    <td>像素</td>
  </tr>
  <tr>
    <td>系统</td>
    <td>y 轴向下</td>
  </tr>
  <tr>
    <td>类型</td>
    <td>整数（不能是小数）</td>
  </tr>
  <tr>
    <td>范围</td>
    <td>(`0`, `0`)（左上角）到（`Gdx.graphics.getWidth()-1`, `Gdx.graphics.getHeight()-1`）（右下角）</td>
  </tr>
  <tr>
    <td>用途</td>
    <td>触摸/鼠标坐标</td>
  </tr>
  <tr>
    <td>依赖</td>
    <td>特定于设备</td>
  </tr>
</table>

它从物理屏幕（应用部分）的左上角*像素*开始，宽度和高度等于物理屏幕（应用部分）的像素尺寸。

![images/screenpixels.png](/assets/wiki/images/screenpixels.png)

每个坐标都是该网格二维数组的索引，表示屏幕上的一个物理像素。因此坐标始终表示为整数，不能是小数。

此坐标系基于显示器的经典表示方式，通常也最接近设备或操作系统的具体实现。如果你熟悉画布图形或基础图像编辑器，那么可能已经熟悉这些坐标。你甚至可能倾向于把它们作为默认或首选坐标，但不应这样做。

处理[鼠标或触摸](/wiki/input/mouse-touch-and-keyboard)坐标时使用的就是这个坐标系。通常应尽快将这些坐标转换到更方便的坐标系，例如使用 `camera.unproject` 或 `viewport.unproject` 方法将其转换为世界坐标（见下文）。

## 屏幕或图像坐标

<table>
  <tr>
    <td>单位</td>
    <td>像素</td>
  </tr>
  <tr>
    <td>系统</td>
    <td>y 轴向上</td>
  </tr>
  <tr>
    <td>类型</td>
    <td>整数（不能是小数）</td>
  </tr>
  <tr>
    <td>范围</td>
    <td>(`0`, `0`)（左下角）到（`Gdx.graphics.getWidth()-1`, `Gdx.graphics.getHeight()-1`）（右上角）</td>
  </tr>
  <tr>
    <td>用途</td>
    <td>viewport、scissors 和 pixmap</td>
  </tr>
  <tr>
    <td>依赖</td>
    <td>取决于设备、资源和 asset</td>
  </tr>
</table>

这是 OpenGL 中与触摸坐标对应的坐标系，用于指定（索引）物理屏幕（部分区域）中的像素，也用于索引内存中的图像。同样，这些坐标是整数，不能是小数。

触摸坐标与屏幕坐标的唯一区别是：触摸坐标的 y 轴向下，而屏幕坐标的 y 轴向上。因此，两者之间的转换很简单：

```java
y = Gdx.graphics.getHeight() - 1 - y;
```

通常使用这些坐标指定要渲染到屏幕的区域，例如调用 [`glViewport`](https://www.khronos.org/opengles/sdk/1.1/docs/man/glViewport.xml)、[`glScissor`](https://www.khronos.org/opengles/sdk/1.1/docs/man/glScissor.xml) 或操作 Pixmap（见下文）时。在大多数情况下，你几乎不需要使用此坐标系；它应与游戏逻辑及其坐标系隔离。可以使用 `camera.project` 和 `viewport.project` 方法将世界单位转换为屏幕坐标。

### Pixmap 和纹理坐标

Pixmap 坐标是一个例外。Pixmap 通常用于上传纹理数据。例如，将 PNG 图像文件加载为纹理时，首先会将其解码（解压缩）为 Pixmap，即图像的原始像素数据，然后复制到 GPU 作为纹理使用。之后可以使用该纹理渲染到屏幕，也可以通过代码修改或创建 Pixmap，例如在上传纹理数据之前。

这里的“问题”是，OpenGL 期望纹理数据使用图像坐标（y 轴向上），而大多数图像格式存储的图像数据类似于触摸坐标（y 轴向下）。libGDX 不会在两者之间转换图像数据（这需要逐行复制图像），而是直接原样复制。因此，从 Pixmap 加载的 Texture 实际上会上下颠倒。

为了补偿这种上下颠倒的纹理，`SpriteBatch` 在渲染时会沿 y 轴翻转纹理（UV）坐标（见下文）。同样，fbx-conv 也提供沿 y 轴翻转纹理坐标的选项。不过，如果使用的纹理不是从 pixmap 加载的，例如 Framebuffer，就可能导致该纹理显示为上下颠倒。

## 归一化渲染坐标

<table>
  <tr>
    <td>单位</td>
    <td>一</td>
  </tr>
  <tr>
    <td>系统</td>
    <td>y 轴向上</td>
  </tr>
  <tr>
    <td>类型</td>
    <td>浮点数</td>
  </tr>
  <tr>
    <td>范围</td>
    <td>(`-1`, `-1`)（左下角）到（`+1`, `+1`）（右上角）</td>
  </tr>
  <tr>
    <td>用途</td>
    <td>着色器</td>
  </tr>
  <tr>
    <td>依赖</td>
    <td>无</td>
  </tr>
</table>

上述坐标系有一个共同的大问题：它们都与设备相关。为了解决这一问题，OpenGL 允许使用与设备无关的坐标系，渲染时会自动将其映射到屏幕坐标。该坐标系的范围归一化为 [-1,-1] 到 [+1,+1]，其中 (0,0) 正好位于屏幕或 framebuffer（渲染目标）的中心。

![images/normalizedcoordinates.png](/assets/wiki/images/normalizedcoordinates.png)

*顶点着色器*在此坐标系中输出其坐标（`gl_Position`）。除此之外，在实际使用中通常不需要接触此坐标系。不过，教程有时会用它来演示基础概念。

需要注意的是，归一化不会考虑宽高比。也就是说，X 方向的缩放比例不必与 Y 方向相同；无论宽高比如何，两者都处于 `-1` 到 `+1` 的范围内。如何处理不同的宽高比由应用决定（见下文的世界单位）。

这些坐标是浮点数，不再用于索引。设备（GPU）会使用[光栅化](https://en.wikipedia.org/wiki/Rasterisation)将这些坐标映射到实际屏幕像素。关于这一过程的更多信息可参阅[这篇文章](https://msdn.microsoft.com/en-us/library/windows/desktop/cc627092(v=vs.85).aspx)；虽然文章面向 DirectX，但同样适用于 OpenGL。

## 归一化纹理（UV）坐标

<table>
  <tr>
    <td>单位</td>
    <td>一</td>
  </tr>
  <tr>
    <td>系统</td>
    <td>y 轴向上</td>
  </tr>
  <tr>
    <td>类型</td>
    <td>浮点数</td>
  </tr>
  <tr>
    <td>范围</td>
    <td>(`0`, `0`)（左下角）到（`1`, `1`）（右上角）</td>
  </tr>
  <tr>
    <td>用途</td>
    <td>着色器、网格、纹理区域、精灵</td>
  </tr>
  <tr>
    <td>依赖</td>
    <td>无</td>
  </tr>
</table>

与归一化渲染坐标类似，OpenGL 也使用归一化纹理坐标。区别在于其范围是 [0,0] 到 [1,1]。根据指定的环绕函数，超出该范围的值会被映射回范围内。

![images/texturecoordinates.png](/assets/wiki/images/texturecoordinates.png)

这些坐标也称为 **UV 坐标**。在许多情况下不需要直接处理它们，通常这些值存储在网格或 `TextureRegion` 中。

使用归一化纹理坐标非常重要，因为它使坐标与资源大小无关。换句话说，你可以将资源替换为缩小或放大的版本，而不必修改 UV 坐标。[mipmap](https://en.wikipedia.org/wiki/Mipmap) 就是一个应用示例。

渲染时，GPU 会将 UV 坐标转换为 [texel](https://en.wikipedia.org/wiki/Texel_(graphics))（纹理像素）。这个过程称为“纹理采样”，并基于[纹理过滤](https://en.wikipedia.org/wiki/Texture_filtering)进行。

## 世界坐标

<table>
  <tr>
    <td>单位</td>
    <td>取决于应用，例如 [SI Units](https://en.wikipedia.org/wiki/International_System_of_Units)</td>
  </tr>
  <tr>
    <td>系统</td>
    <td>取决于应用，但通常为 y-up</td>
  </tr>
  <tr>
    <td>类型</td>
    <td>通常为浮点数</td>
  </tr>
  <tr>
    <td>范围</td>
    <td>取决于应用</td>
  </tr>
  <tr>
    <td>用途</td>
    <td>游戏逻辑</td>
  </tr>
  <tr>
    <td>依赖</td>
    <td>游戏/应用</td>
  </tr>
</table>

通常，游戏逻辑应使用最适合自身的坐标系，不应依赖设备或资源大小。例如，常用的单位是米。

世界坐标会在顶点着色器中转换为归一化渲染坐标。[Camera](https://web.archive.org/web/20200427232345/https://www.badlogicgames.com/wordpress/?p=1550) 或 [Viewport](/wiki/graphics/viewports) 用于定义转换策略。例如，为保持宽高比，可以添加黑边。Camera 用于计算视图矩阵，该矩阵会考虑 Camera 的位置和旋转，将世界坐标转换为相对于 Camera 的坐标。它还会计算投影矩阵，将世界坐标转换为范围从 [-1,-1] 到 [+1,+1] 的归一化渲染坐标。在 2D 游戏中，通常无需区分这两个矩阵，只需使用组合变换矩阵即可。例如，可以调用 `spriteBatch.setProjectionMatrix(camera.combined);` 将该矩阵传递给着色器。

![images/projection.png](/assets/wiki/images/projection.png)

你可以拥有多个 Camera 或 Viewport，同样也可以拥有多个世界坐标系。典型游戏至少有两个世界坐标系，即：

### GUI/HUD 坐标
这些是固定不动且始终显示在屏幕上的按钮、标签等元素，通常还包括文本渲染。例如在 Super Mario 中，时钟始终显示在屏幕右上角，不会随着 Mario 在游戏世界中的移动而移动。

HUD 最常使用 [scene2d](/wiki/graphics/2d/scene2d/scene2d) 实现，这意味着使用 [Viewport](/wiki/graphics/viewports) 定义坐标系。为在渲染字体时获得最佳效果，此坐标系的范围通常接近设备分辨率。这些坐标称为 [banana units](https://xoppa.github.io/blog/pixels/)。此 Camera 几乎不会移动或旋转，而是固定在某个位置，使世界坐标 (0, 0) 位于屏幕左下角。

### 游戏坐标
这是最适合你的游戏、用于实现游戏逻辑的坐标系。为了获得最佳浮点精度，通常建议让数值保持在 1 附近。例如，主角身高 1.8 米，树高 10 米等。如果制作的是单位和距离都非常大的星际游戏，也可以改用千米等单位。

Camera 用于观察游戏世界，就像现实中使用摄像机一样。Camera 可以移动、旋转和缩放，以在屏幕上显示世界的其他区域。
