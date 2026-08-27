---
title: Pixmap
---
# 简介

一个 [Pixmap](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Pixmap.html) [(代码)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/Pixmap.java) 封装驻留在内存中的图像数据。它支持简单的文件加载和绘制操作，可用于基本的图像处理。最常见的用途是将其包装在
[Texture](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Texture.html)
[(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/Texture.java) 实例中，以准备将图像上传到 GPU。还可以通过
[PixmapIO](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/PixmapIO.html)
[(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/PixmapIO.java) 类保存和加载图像。PixmapIO 支持未压缩的 [PNG](https://en.wikipedia.org/wiki/Portable_Network_Graphics)，以及 libGDX 特有的压缩格式 _CIM_。CIM 适合快速访问存储，例如在应用失去和恢复焦点时保存或加载状态。

*由于 Pixmap 位于本地堆内存中，不再需要时必须调用 `dispose()` 释放，以防止内存泄漏。*

# 创建 Pixmap

Pixmap 可以通过包含 [JPEG](https://en.wikipedia.org/wiki/Jpeg)、[PNG](https://en.wikipedia.org/wiki/Portable_Network_Graphics) 或 [BMP](https://en.wikipedia.org/wiki/BMP_file_format) 编码图像数据的 _byte array_、
[FileHandle](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/files/FileHandle.html)
[(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/files/FileHandle.java)，或指定尺寸和格式来创建。创建后，可以先进一步处理，再上传到 OpenGL [Texture](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/graphics/Texture.html)
[(code)](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/graphics/Texture.java) 进行渲染，或保存供以后使用。

下面的示例创建一个 64x64 的 32 位 RGBA Pixmap，在其中绘制绿色实心圆，将其上传到 Texture，然后释放内存：

```java
Pixmap pixmap = new Pixmap( 64, 64, Format.RGBA8888 );
pixmap.setColor( 0, 1, 0, 0.75f );
pixmap.fillCircle( 32, 32, 32 );
Texture pixmaptex = new Texture( pixmap );
pixmap.dispose();
```

注意，Pixmap 被包装到 Texture 并上传到 GPU 后，其内存便不再需要，因此应将其释放。还要注意，由于该 Texture 不是从持久文件创建的，而是来自随后被丢弃的易失内存，所以它属于 _unmanaged_ 资源。

下面的示例展示典型 Android 应用的暂停/恢复生命周期：

```java

FileHandle dataFile = Gdx.files.external( dataFolderName + "current.cim" );

@Override
public void pause() {
  Pixmap pixmap;
  // do something with pixmap...
  PixmapIO.writeCIM( dataFile, pixmap );
}

@Override
public void resume() {

  if ( dataFile.exists() ) {
    Pixmap pixmap = PixmapIO.readCIM( dataFile );

    // do something with pixmap...
  }
}
```

在上例中，应用失去焦点时会使用简单的压缩方案将 _pixmap_ 写入外部位置；重新获得焦点时，如果指定位置仍存在该文件，就会重新加载它。

# 绘制

Pixmap 支持简单的绘制操作，例如绘制线条、实心或空心矩形和圆、设置单个像素，以及绘制其他 Pixmap。这些操作还会受到颜色、混合和过滤器的影响，分别由 `setColor()`、`setBlending()` 和 `setFilter()` 控制。
