---
title: 帧缓冲对象
---
帧缓冲允许将内容渲染到纹理，而不是屏幕（即 backbuffer）。这在许多场景下都很有用，例如执行后处理效果。

## 如何使用帧缓冲

先创建一个 `FrameBuffer`：

```java
FrameBuffer fbo = new FrameBuffer(Format.RGBA8888, 1024, 720, false);
```

要将内容渲染到帧缓冲，必须先绑定它（通过 `begin()` 和 `end()`）：

```java
fbo.begin();
Gdx.gl.glClearColor(1, 1, 1, 1);
Gdx.gl.glClear(GL20.GL_COLOR_BUFFER_BIT);

batch.begin();
batch.draw(anyCoolSprite, 0, 0);
batch.end();

fbo.end();
```

要获取渲染到帧缓冲的内容，需要调用 `getColorBufferTexture()`：

```java
Texture texture = fbo.getColorBufferTexture();
TextureRegion textureRegion = new TextureRegion(texture);
textureRegion.flip(false, true);
```

如上所示，通过 TextureRegion 翻转了纹理。这是因为帧缓冲纹理通常是上下颠倒的。

如果只想将帧缓冲的纹理绘制到屏幕上，也可以使用下面的方式翻转纹理：
```java
batch.draw(fbo.getColorTexture(), x, y, w, h, 0, 0, 1, 1)
```

## 常见问题
### 嵌套
请注意，libGDX 的默认帧缓冲不能嵌套（即不能相互嵌套使用）。这是因为 `FrameBuffer.end()` 总是绑定 back buffer，即使它不是之前绑定的缓冲区。问题的详细说明见[这里](https://github.com/crykn/libgdx-screenmanager/wiki/Custom-FrameBuffer-implementation#the-problem)。要绕过此问题，可以继承 FrameBuffer 并重写 `end()` 方法。如果不想自行实现，也有一些社区方案可供选择。

### Hdpi
如果使用 hdpi 显示屏，在帧缓冲中渲染 scene2d 内容会导致裁剪问题，例如对话框就会使用裁剪。要修复此问题，可以将帧缓冲大小设置为实际像素大小（而不是逻辑大小）：

```java
FrameBuffer fbo = new FrameBuffer(Format.RGBA8888, HdpiUtils.toBackBufferX(currentWidth), HdpiUtils.toBackBufferY(currentHeight), false);
```

或者临时切换 hdpi 模式：

```java
HdpiUtils.setMode(HdpiMode.Pixels);
fbo.begin();
stage.draw();
fbo.end();
HdpiUtils.setMode(HdpiMode.Logical);
```

## 延伸资源
- [关于帧缓冲的 LWJGL 教程（也包含所用代码的 libGDX 版本）](https://github.com/mattdesl/lwjgl-basics/wiki/FrameBufferObjects)
