---
title: ANGLE
---

# 什么是 ANGLE？

ANGLE（Almost Native Graphics Layer Engine，几乎原生图形层引擎）是 Google 开发的开源、跨平台图形引擎抽象层。ANGLE 将 OpenGL ES 2/3 调用转换为 Direct3D9、11、OpenGL、Vulkan 或 Metal API 调用。[^1]

**优点**：
* 在 Windows 上使用 Direct3D、在 macOS 上使用 Metal，从而在不支持 OpenGL 2 的系统上获得更好的兼容性。
* 性能最多可提升 15-20%
* 或能修复一些 OpenGL 驱动问题。

**缺点**：
* 仅支持 OpenGL ES 2.0
* 目前包含无法工作的 32 位 Windows 原生库（见 [#6806](https://github.com/libgdx/libgdx/issues/6806)）。
* 在 macOS/Linux 上不支持窗口透明。
* 还有其他一些[缺陷](https://github.com/libgdx/libgdx/issues?q=is%3Aissue+is%3Aopen+label%3Aangle)有待解决。

# 用法

将 `gdx-lwjgl3-angle` 添加为 LWJGL3 桌面项目的依赖：

```gradle
implementation "com.badlogicgames.gdx:gdx-lwjgl3-angle:$gdxVersion"
```

然后在 `Lwjgl3ApplicationConfiguration` 中使用 `GLEmulation.ANGLE_GLES20`：

```java
config.setOpenGLEmulation(GLEmulation.ANGLE_GLES20, 0, 0);
```

## 验证

如果你打印 OpenGL 渲染器与供应商信息：

```java
public void create () {
    System.out.println("OpenGL renderer: " + Gdx.graphics.getGLVersion().getRendererString());
    System.out.println("OpenGL vendor: " + Gdx.graphics.getGLVersion().getVendorString());
    ...
}
```

则会看到类似下面的输出：

```
OpenGL renderer: ANGLE (AMD, AMD Radeon(TM) 860M Graphics (0x00001114) Direct3D11 vs_5_0 ps_5_0, D3D11-32.0.22024.17002)
OpenGL vendor: Google Inc. (AMD)
```

[^1]: <https://en.wikipedia.org/wiki/ANGLE_(software)>
