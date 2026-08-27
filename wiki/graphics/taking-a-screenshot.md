---
title: 截取屏幕截图
---
在 libGDX 中截取屏幕截图很简单！

## 不进行后处理

截取屏幕截图的基本方式是调用 `Pixmap.createFromFrameBuffer`（此前为 `ScreenUtils#getFrameBufferPixmap`），然后将该 pixmap 写入磁盘：

```java
Pixmap pixmap = Pixmap.createFromFrameBuffer(0, 0, Gdx.graphics.getWidth(), Gdx.graphics.getHeight());
PixmapIO.writePNG(Gdx.files.external("mypixmap.png"), pixmap, Deflater.DEFAULT_COMPRESSION, true);
pixmap.dispose();
```

## 通过后处理确保清晰度

但是，如果画面包含多层透明效果，就需要对屏幕截图进行后处理以移除透明度，否则截图看起来可能与用户看到的画面不一致：

```java
Pixmap pixmap = Pixmap.createFromFrameBuffer(0, 0, Gdx.graphics.getBackBufferWidth(), Gdx.graphics.getBackBufferHeight());
ByteBuffer pixels = pixmap.getPixels();

// This loop makes sure the whole screenshot is opaque and looks exactly like what the user is seeing
int size = Gdx.graphics.getBackBufferWidth() * Gdx.graphics.getBackBufferHeight() * 4;
for (int i = 3; i < size; i += 4) {
	pixels.put(i, (byte) 255);
}

PixmapIO.writePNG(Gdx.files.external("mypixmap.png"), pixmap, Deflater.DEFAULT_COMPRESSION, true);
pixmap.dispose();
```

在这方面，**GWT 后端存在一些限制**，需要执行[这里](https://github.com/libgdx/libgdx.github.io/pull/108#issuecomment-1175176650)所述的额外步骤。
