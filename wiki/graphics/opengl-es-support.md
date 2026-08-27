---
title: OpenGL（ES）支持
---
# 什么是（Open）GL 和 GL ES？

libGDX 提到 GL20 或 GL30 时，实际上分别指 **OpenGL ES 2.0** 和 **OpenGL ES 3.0**。OpenGL ES 是用于渲染 2D 和 3D 计算机图形的 API。其他常见图形 API 还包括 Direct3D、Metal 和 Vulkan。OpenGL ES 有多个版本（1.0、1.1、2.0、3.0、3.1、3.2），各自提供不同功能。它可以看作 _OpenGL_（本身也是图形 API）的子集，专为嵌入式系统设计，因此名称中有 _ES_，尤其面向智能手机。

默认情况下，libGDX 使用 OpenGL ES 2.0，但也可以配置为使用 3.0。LWJGL 3 后端还支持 **GL ES 3.1 和 3.2**。若要使用指定的 OpenGL ES 版本，必须在应用配置中启用它。LWJGL 3 后端的配置方式如下：

```java
Lwjgl3ApplicationConfiguration cfg = new Lwjgl3ApplicationConfiguration();
// ...
cfg.setOpenGLEmulation(GLEmulation.GL30, 3, 2); // use GL 3.0 (emulated by OpenGL 3.2)
```

## 平台差异
### 桌面端（Windows、Mac、Linux）
在桌面端，libGDX 会将所有图形调用映射到 OpenGL。也就是说，虽然 GL20 对象提供的是 OpenGL ES 2.0 规范中的方法，但在桌面端这些 API 调用会交给 OpenGL。由于 OpenGL ES 源自 OpenGL 并且是其子集，两者的版本大致相互对应。

**GL ES 2.0** 大致基于 Open GL 2.0，但存在一些直到 Open GL 4.1 才解决的不兼容问题。为了模拟 GL ES 2.0，libGDX 不会请求特定的 OpenGL 版本，因此驱动程序的限制会更宽松。

**GL ES 3.0** 是 OpenGL ES 2.0 的后继版本。在桌面端，OpenGL 4.3 完全兼容 OpenGL ES 3.0。要在桌面端模拟 GL ES 3.0，可以指定要使用的确切 OpenGL 版本。请注意，macOS 仅为 OpenGL 3.2+ 提供[核心配置](https://www.khronos.org/opengl/wiki/OpenGL_Context#OpenGL_3.2_and_Profiles)，且[支持的最高版本为 4.1](https://support.apple.com/en-gb/101525)。

**GL ES 3.1 和 3.2** 做了大量工作，使 API 的功能显著接近桌面端对应版本。OpenGL 4.5 应该能够完全模拟 GL ES 3.1。

### Android
Android 可使用 OpenGL ES 2.0 和 3.0。为避免应用显示给不支持的设备，需要在 Android Manifest 中加入以下任意一行：
- OpenGL ES 2: `<uses-feature android:glEsVersion="0x00020000" android:required="true" />`
- OpenGL ES 3: `<uses-feature android:glEsVersion="0x00030000" android:required="true" />`

### iOS
请注意，iOS 对 OpenGL ES 3.0 的支持仍属实验性功能。

### Web
Web 平台的图形功能由 WebGL 处理。从 1.12.0 起，libGDX 支持 WebGL 2，它相当于 GL ES 3.0。可以通过 `GwtApplicationConfiguration#useGL30` 启用。

# GLSL（ES）又是什么？
GLSL（移动端和 Web 端则为 GLSL ES）是着色器使用的语言。它的版本号随着特定版本的 OpenGL API 演进，因此比较容易混淆：

<details>
  <summary><b><i>GLSL - 点击展开</i></b></summary>

<br/>
<div markdown="1">
| Open GL 版本 | GLSL 版本 |
| --- | --- |
| 2.0 | 110 |
| 2.1 | 120 |
| 3.0 | 130 |
| 3.1 | 140 |
| 3.2 | 150 |
| 3.3 | 330 |
| 4.0 | 400 |
| 4.1 | 410 |
| 4.2 | 420 |
| 4.3 | 430 |
| 4.4 | 440 |
| 4.5 | 450 |
| 4.6 | 460 |

如需了解将着色器从 120 移植到 330+ 的建议，请参阅[此处](https://github.com/mattdesl/lwjgl-basics/wiki/GLSL-Versions#version-330)。
</div>

</details>

<details>
  <summary><b><i>GLSL ES - 点击展开</i></b></summary>

<br/>
<div markdown="1">
| OpenGL ES 版本 | GLSL ES 版本 | 基于的 GLSL 版本（OpenGL） |
| --- | --- | --- |
| 2.0 | 100 | 120 (2.1) |
| 3.0 | 300 es | 330 (3.3) |

</div>

</details>

## 精度修饰符
GLSL ES 要求为属性、uniform 和局部变量指定精度修饰符，而桌面端使用的 GLSL 不支持这一点。需要在片段着色器中使用类似下面的代码片段进行兼容处理：

```java
#ifdef GL_ES
#define LOW lowp
#define MED mediump
#define HIGH highp
precision mediump float;
#else
#define MED
#define LOW
#define HIGH
#endif
```

这会将 `LOWP`、`MED` 和 `HIGH` 宏定义为对应的 OpenGL ES 精度修饰符，并将 float 的默认精度设为 medium。此操作只会在实际运行 OpenGL ES 的平台上生效；在桌面端，这些宏会被定义为空。

# OpenGL ES 2.0 文档
* [OpenGL ES 2.0 参考页](https://www.khronos.org/registry/OpenGL-Refpages/es2.0/)
* [OpenGL ES 2.0 参考卡](https://www.khronos.org/opengles/sdk/docs/reference_cards/OpenGL-ES-2_0-Reference-card.pdf)
* [OpenGL ES 2.0 规范](https://www.khronos.org/registry/OpenGL/index_es.php#specs2)
* [面向 iOS 的 OpenGL ES 编程指南](https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/Introduction/Introduction.html)：核心概念同样适用于其他平台
* [OpenGL ES 2.0 管线结构](https://en.wikibooks.org/wiki/OpenGL_Programming/OpenGL_ES_Overview#OpenGL_ES_2.0_Pipeline_Structure)
