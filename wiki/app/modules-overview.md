---
title: 模块概览
---
## 简介

libGDX 包含多个模块，为典型游戏架构的各个步骤提供服务。

 * *[Input](/wiki/input/input-handling)* - 为所有平台提供统一的输入模型和处理器。在可用的平台上支持键盘、触摸屏、加速度计和鼠标。
 * *[Graphics](/wiki/graphics/graphics)* - 使用硬件提供的 OpenGL ES 实现将图像绘制到屏幕上。
 * *[Files](/wiki/file-handling)* - 抽象所有平台上的文件访问，无论介质类型如何，都提供便捷的读写操作方法。
 * *[Audio](/wiki/audio/audio)* - 让所有平台上的声音录制和播放变得更加容易。
 * *[Networking](/wiki/networking)* - 提供执行网络操作的方法，例如简单的 HTTP GET 和 POST 请求，以及 TCP 服务端/客户端套接字通信。

下图展示了简单游戏架构中的各个模块：

![images/modules-overview.png](/assets/wiki/images/modules-overview.png)

## 模块

下面简要介绍各个模块及其最常见的用例。有关更深入的信息，请查看相应模块的 Wiki 专区！
{: .notice--primary}

### 输入
_Input_ 模块支持在所有平台上轮询不同的输入状态。
它可以轮询每个按键、触摸屏和加速度计的状态。在桌面端，触摸屏由鼠标代替，而加速度计不可用。

它还支持注册输入处理器，以使用基于事件的输入模型。

以下代码片段会在触摸事件（或桌面端鼠标按下事件）进行时获取当前触摸坐标：
```java
if (Gdx.input.isTouched()) {
  System.out.println("Input occurred at x=" + Gdx.input.getX() + ", y=" + Gdx.input.getY());
}
```
其他受支持的输入方式也可以用类似方式轮询和处理。

### 图形
_Graphics_ 模块抽象了与 GPU 的通信，并提供获取 OpenGL ES 包装器实例的便捷方法。它负责获取 OpenGL 实例所需的所有样板代码，并处理制造商提供的各种实现。

包装器是否可用取决于底层硬件。

Graphics 模块还提供生成 Pixmap 和 Texture 的方法。

例如，要获取 OpenGL API 2.0 实例，可以使用以下代码：
```java
GL20 gl = Gdx.graphics.getGL20();
```
该方法会返回一个可用于绘制屏幕的实例。如果硬件配置不支持 OpenGL ES v2.0，则返回 null。

以下代码片段会清屏并将屏幕绘制为红色。
```java
gl.glClearColor(1f, 0.0f, 0.0f, 1);
gl.glClear(GL20.GL_COLOR_BUFFER_BIT);
```
它始终返回 API 的具体实现（lwjgl、jogl 或 android），因此主应用程序无需了解实现细节，在受支持的平台范围内都可以运行。

支持以下 API 版本：

| *GL 版本* |    *访问方法*     |
|:------------:|:-------------------------:|
|     2.0      | `Gdx.graphics.getGL20();` |
|     3.0      | `Gdx.graphics.getGL30();` |


如需进一步了解 Graphics 模块，请查看其[文档](/wiki/graphics/graphics)。

### 文件
_Files_ 模块提供了不受平台影响的通用文件访问方式。
它让文件读写变得简单。文件写入存在一些限制，这些限制源于平台的安全机制。

Files 模块最常见的用途，是在所有平台上从应用程序的同一子目录加载游戏资源（纹理、声音文件）。
它也非常适合将最高分或游戏状态写入文件。

以下示例从 `$APP_DIR/assets/textures` 目录中的文件创建 Texture。
```java
Texture myTexture = new Texture(Gdx.files.internal("assets/textures/brick.png"));
```
这是一个非常强大的抽象层，因为它同时适用于 Android 和桌面端。

### 音频
_Audio_ 模块让音频文件的创建和播放变得非常简单，也提供对声音硬件的直接访问。

它处理两种声音文件：*Music* 和 *Sound*。这两种类型都支持 WAV、MP3 和 OGG 格式。

Sound 实例会加载到内存中，可以随时播放。它非常适合爆炸声、枪声等需要重复使用的游戏内音效。

另一方面，Music 实例是磁盘（或 SD 卡）文件的流。每次播放文件时，都会将其从文件流式传输到音频设备。

以下代码片段会从磁盘反复播放声音文件 _myMusicFile.mp3_，音量设置为一半：
```java
Music music = Gdx.audio.newMusic(Gdx.files.getFileHandle("myMusicFile.mp3", FileType.Internal));
music.setVolume(0.5f);
music.play();
music.setLooping(true);
```

### 网络
_Networking_ 模块提供对游戏网络功能有用的方法，可用于添加多人游戏、将玩家引导至网站，或执行其他网络任务。这些功能在多个平台上可用，但某些平台可能需要额外处理，或缺少某些功能。

Networking 模块包含可配置的 TCP 客户端和服务端套接字，其设置针对低延迟进行了优化。

模块还提供发起 HTTP 请求的方法和工具。其中一个工具是 Request Builder，它使用方法链来轻松创建 HTTP 请求。

可以使用以下代码片段，通过 Request Builder 创建 HTTP 请求：
```java
HttpRequestBuilder requestBuilder = new HttpRequestBuilder();
HttpRequest httpRequest = requestBuilder.newRequest()
   .method(HttpMethods.GET)
   .url("http://www.google.de")
   .build();
Gdx.net.sendHttpRequest(httpRequest, httpResponseListener);
```

也可以使用以下代码片段，通过它创建带参数的 HTTP 请求：
```java
HttpRequestBuilder requestBuilder = new HttpRequestBuilder();
HttpRequest httpRequest = requestBuilder.newRequest()
   .method(HttpMethods.GET)
   .url("http://www.google.de")
   .content("q=libgdx&example=example")
   .build();
Gdx.net.sendHttpRequest(httpRequest, httpResponseListener);
```
