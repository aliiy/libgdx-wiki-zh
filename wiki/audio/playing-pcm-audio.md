---
title: 播放 PCM 音频
---
音频模块可以让你直接访问音频硬件，向其写入 [PCM 采样](https://en.wikipedia.org/wiki/Pulse-code_modulation)。

音频硬件通过 [AudioDevice](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/audio/AudioDevice.html) [(源代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/audio/AudioDevice.java) 接口进行抽象。

创建新的 `AudioDevice` 实例的方式如下：

```java
AudioDevice device = Gdx.audio.newAudioDevice(44100, true);
```

这会创建一个采样频率为 44.1 kHz、输出为单声道的 `AudioDevice`。如果无法创建设备，则会抛出 `GdxRuntimeException`。

我们可以向设备写入 16 位有符号 PCM 或 32 位浮点 PCM 数据：

```java
float[] floatPCM = ... generated from a sine for example ...
device.writeSamples(floatPCM, 0, floatPCM.length);

short[] shortPCM = ... generated from a decoder ...
device.writeSamples(shortPCM, 0, shortPCM.length);
```

如果使用立体声，左右声道采样按通常方式交错排列（第一个 float/short -> 左声道，第二个 float/short -> 右声道）。

可以这样查询毫秒级延迟：

```java
int latencyInSamples = device.getLatency();
```

这会返回音频缓冲区的采样数大小，从而很好地反映延迟。返回值越大，写入后音频到达接收端所需的时间越长。

请注意，几乎所有 Android 手机的延迟都高得离谱。实时音频应用很难达到实用的 10～30 ms 范围，通常只能达到 100 ms 延迟，许多手机甚至会达到 400 ms。这是驱动程序/操作系统相关的问题，很遗憾无法绕过。

`AudioDevice` 是一种本机资源，不再使用时必须释放：

```java
device.dispose();
```

JavaScript/WebGL 后端不支持直接 PCM 输出。
