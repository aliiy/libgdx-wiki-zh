---
title: 虚拟现实（VR）
---
libGDX 可以使用 LWJGL 的 OpenVR（HTC Vive）和 OVR（Oculus）模块，将内容渲染到虚拟现实头显。

### 所需依赖

可以通过 [LWJGL customize](https://www.lwjgl.org/customize) 页面查找 Maven 坐标。

### 示例代码

示例代码见 [https://github.com/badlogic/gdx-vr](https://github.com/badlogic/gdx-vr)。

此外，LWJGL 的以下演示程序可能有助于调试：
* [HelloOpenVR.java](https://github.com/LWJGL/lwjgl3/blob/master/modules/samples/src/test/java/org/lwjgl/demo/openvr/HelloOpenVR.java)
* [HelloLibOVR.java](https://github.com/LWJGL/lwjgl3/blob/master/modules/samples/src/test/java/org/lwjgl/demo/ovr/HelloLibOVR.java)

另请参阅 [https://github.com/Zomby2D/gdx-vr-extension](https://github.com/Zomby2D/gdx-vr-extension)。

### 使用离屏 GLFW 窗口的 OpenVR

使用离屏 GLFW 窗口可以将内容渲染到 VR，而无需在显示器屏幕上渲染或维护窗口。这样可以让 OpenVR 获得最佳性能。

libGDX 目前尚不支持此功能，因为还需要进行一些底层修改，但总体流程如下。

```java
Lwjgl3NativesLoader.load();
errorCallback = GLFWErrorCallback.createPrint(System.err);
GLFW.glfwSetErrorCallback(errorCallback);
if (!GLFW.glfwInit())
{
   throw new RuntimeException("Unable to initialize GLFW");
}
GLFW.glfwWindowHint(GLFW.GLFW_VISIBLE, GLFW.GLFW_FALSE);
windowHandle = GLFW.glfwCreateWindow(640, 480, "", MemoryUtil.NULL, MemoryUtil.NULL);
GLFW.glfwMakeContextCurrent(windowHandle);
GL.createCapabilities();

Gdx.gl30 = new Lwjgl3GL30();
Gdx.gl = Gdx.gl30;
Gdx.gl20 = Gdx.gl30;
Gdx.files = new Lwjgl3Files();
Gdx.graphics = <minimal implementation of Graphics interface>
Gdx.app = <minimal implementation of Application interface>

// setup a scene and model batch

while (running) // See https://github.com/ValveSoftware/openvr/wiki/IVRCompositor_Overview
{
   // OpenVR waitGetPoses();
   // OpenVR poll events
   // OpenVR Submit eyes
}
GLFW.glfwDestroyWindow(windowHandle);
errorCallback.free();
errorCallback = null;
GLFW.glfwTerminate();
```

### 路线图

通过使用 [OpenXR](https://www.khronos.org/openxr/)，VR 支持可能很快会变得更加简单。LWJGL 项目[计划在未来支持它](https://github.com/LWJGL/lwjgl3/issues/569#issuecomment-643830566)。这样就无需同时支持 OVR 和 OpenVR，而只需使用 OpenXR 即可支持所有硬件。
