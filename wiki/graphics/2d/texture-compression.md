---
title: 纹理压缩
---
如果需要纹理压缩、离线生成 mipmap 或立方体贴图，PNG 等默认纹理格式就不够用了。幸运的是，libGDX 提供了两种方案：ETC1 文件和 KTX/ZKTX 纹理。

注意，**GWT** 后端目前**不支持** ETC1 和 KTX/ZKTX。

在详细介绍之前，需要区分两种压缩：
- 用于将纹理存储在磁盘上的压缩（zip、png、jpg 等），有助于减小程序包大小；
- 用于将纹理存储在内存中的压缩（ETC1、ETC2、S3TC 等），可以提高游戏性能，并减小应用运行时的内存占用（从而降低 Android 恢复时重启应用的风险）。

在 Android 上，OpenGL ES 2.0 只有一种必需的纹理压缩格式：ETC1（iOS 不提供此格式）。它可以将任意 RGB8 图像的大小缩小 6 倍。主要缺点是它属于有损压缩，而且仅限于 RGB8。若要支持 alpha 通道，必须单独存储 alpha：
- 存储在另一张同样可以使用 ETC1 压缩的纹理中；
- 或存储在同一张纹理中，将图像的颜色部分放在上方、alpha 部分放在下方。

这样显存节省会从 6 倍降至 4 倍，但仍然值得。示例见 [KTXTest](https://github.com/libgdx/libgdx/blob/master/tests/gdx-tests/src/com/badlogic/gdx/tests/KTXTest.java)。

## ETC1 文件格式

ETC1 文件格式是 libGDX 专用的非常简单的格式（参见[这篇博客文章](https://web.archive.org/web/20200924172136/https://www.badlogicgames.com/wordpress/?p=2104)）。它提供了支持 ETC1 压缩 2D 纹理的直接方式。缺点是无法使用 mipmap 或立方体贴图。

### 压缩
压缩从文件加载的 Pixmap，并将其写入自定义 ETC1 文件格式非常简单：
```java
Pixmap pixmap = new Pixmap(Gdx.files.absolute("image.png"));
ETC1.encodeImagePKM(pixmap).write(Gdx.files.absolute("image.etc1"));
```    
也可以使用 gdx-tools 项目中的 ETC1Compressor 工具转换整个目录层级。

### 加载
将 ETC1 压缩图像保存到文件后，可以像加载其他图像文件一样轻松加载它：
```java
Texture texture = new Texture(Gdx.files.internal("image.etc1"));
```    

## KTX/ZKTX 格式

KTX 文件格式是专门用于存储 OpenGL 纹理的[标准](https://www.khronos.org/registry/KTX/specs/1.0/ktxspec_v1.html)。其主要优势是支持 OpenGL 纹理的大多数功能（所有压缩格式、带或不带 mipmap、立方体贴图、纹理数组等）。

ZKTX 格式只是经过 zip 压缩的 KTX，用于限制文件在磁盘上的大小。

### 准备文件
gdx-tools 项目中的 KTXProcessor 工具提供了准备纹理的简单方式：
```
usage : KTXProcessor input_file output_file [-etc1|-etc1a] [-mipmaps]
  input_file  is the texture file to include in the output KTX or ZKTX file.
              for cube map, just provide 6 input files corresponding to the faces in the following order : X+, X-, Y+, Y-, Z+, Z-
  output_file is the path to the output file, its type is based on the extension which must be either KTX or ZKTX

  options:
    -etc1    input file will be packed using ETC1 compression, dropping the alpha channel
    -etc1a   input file will be packed using ETC1 compression, doubling the height and placing the alpha channel in the bottom half
    -mipmaps input file will be processed to generate mipmaps

  examples:
    KTXProcessor in.png out.ktx                                        Create a KTX file with the provided 2D texture
    KTXProcessor in.png out.zktx                                       Create a Zipped KTX file with the provided 2D texture
    KTXProcessor in.png out.zktx -mipmaps                              Create a Zipped KTX file with the provided 2D texture, generating all mipmap levels
    KTXProcessor px.ktx nx.ktx py.ktx ny.ktx pz.ktx nz.ktx out.zktx    Create a Zipped KTX file with the provided cubemap textures
    KTXProcessor in.ktx out.zktx                                       Convert a KTX file to a Zipped KTX file
```

此外，还有许多用于准备 KTX 纹理文件的第三方工具：
- [OpenGL SDK](https://www.khronos.org/opengles/sdk/tools/KTX/) 提供创建 KTX 文件的工具；
- [Mali SDK](https://developer.arm.com/products/software-development-tools/graphics-development-tools/mali-texture-compression-tool) 提供创建 KTX 文件以及处理 alpha 通道的工具。

### 加载
将 KTX 或 ZKTX 压缩图像保存到文件后，可以像加载其他图像文件一样轻松加载它：

```java
Texture texture = new Texture(Gdx.files.internal("image.zktx"));
```
