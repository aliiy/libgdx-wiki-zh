---
title: 应用程序框架
---
## 模块
libGDX 的核心由六个[模块](/wiki/app/modules-overview)组成，它们以接口的形式提供与操作系统交互的能力。每个后端都会实现这些接口。

  * *[Application](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/Application.java)*：运行应用程序，并将窗口调整大小等应用程序级事件通知 API 使用者。提供日志功能和查询方法，例如查询内存占用。
  * *[Files](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/Files.java)*：公开平台底层文件系统，基于自定义文件句柄系统抽象不同类型的文件位置（该系统不与 Java 的 File 类互操作）。
  * *[Input](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/Input.java)*：向 API 使用者提供鼠标、键盘、触摸或加速度计事件等用户输入。支持轮询和事件驱动处理。
  * *[Net](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/Net.java)*：提供跨平台访问 HTTP/HTTPS 资源，以及创建 TCP 服务端和客户端套接字的方式。
  * *[Audio](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/Audio.java)*：提供播放音效和流式音乐，以及直接访问音频设备进行 PCM 音频输入/输出的方式。
  * *[Graphics](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/Graphics.java)*：公开 OpenGL ES 2.0（如果可用），并允许查询/设置视频模式及类似属性。

## 启动类
需要编写的唯一平台特定代码是所谓的[启动类](/wiki/app/starter-classes-and-configuration)。对于每个目标平台，都需要一段代码实例化该平台后端提供的 Application 接口具体实现。以 LWJGL 3 后端为例，桌面端代码可能如下：

```java
public class DesktopLauncher {
   public static void main(String[] args) {
      Lwjgl3ApplicationConfiguration config = new Lwjgl3ApplicationConfiguration();
      new Lwjgl3Application(new MyGdxGame(), config);
   }
}
```

Android 对应的启动类可能如下：

```java
public class AndroidStarter extends AndroidApplication {
   public void onCreate(Bundle bundle) {
      super.onCreate(bundle);
      AndroidApplicationConfiguration config = new AndroidApplicationConfiguration();
      initialize(new MyGame(), config);
   }
}
```

这两个类通常位于不同的项目中，例如桌面项目和 Android 项目。[项目生成](/wiki/start/project-generation)页面介绍了这些项目的布局。

应用程序的实际代码位于实现 [ApplicationListener](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/ApplicationListener.java) 接口的类中（上例中的 MyGame）。该类的实例会传递给各后端 Application 实现相应的初始化方法（见上文）。应用程序随后会在适当的时机调用 ApplicationListener 的方法（见[生命周期](/wiki/app/the-life-cycle)）。

有关启动类的详细信息，请参阅[启动类与配置](/wiki/app/starter-classes-and-configuration)。

## 访问模块
前面介绍的模块可以通过 [Gdx 类](https://github.com/libgdx/libgdx/tree/master/gdx/src/com/badlogic/gdx/Gdx.java)的静态字段访问。它本质上是一组全局变量，可以方便地访问 libGDX 的任意模块。虽然这通常被视为不良编码实践，但我们采用这种机制，以免在代码各处频繁传递常用对象的引用。

例如，要访问音频模块，只需编写如下代码：

```java
// creates a new AudioDevice to which 16-bit PCM samples can be written
AudioDevice audioDevice = Gdx.audio.newAudioDevice(44100, false);
```

`Gdx.audio` 是应用程序启动时由 Application 实例化的后端实现的引用。其他模块也以相同方式访问，例如使用 `Gdx.app` 获取 Application，使用 `Gdx.files` 访问 Files 实现，依此类推。
