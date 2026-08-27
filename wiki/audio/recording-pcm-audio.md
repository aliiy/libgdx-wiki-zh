---
title: 录制 PCM 音频
---
你可以通过 [AudioRecorder](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/audio/AudioRecorder.html) [(代码)](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/audio/AudioRecorder.java) 接口，从 PC 或 Android 手机的麦克风访问 PCM 数据。使用以下代码创建该接口的实例：

```java
AudioRecorder recorder = Gdx.audio.newAudioRecorder(22050, true);
```

这会创建一个采样率为 22.05 kHz 的单声道 `AudioRecorder`。如果无法创建录音器，则会抛出 `GdxRuntimeException`。

采样数据可以按 16 位有符号 PCM 读取：

```java
short[] shortPCM = new short[1024]; // 1024 samples
recorder.readSamples(shortPCM, 0, shortPCM.length);
```

立体声采样按通常方式交错排列（第一个采样 -> 左声道，第二个采样 -> 右声道）。

`AudioRecorder` 是一种本机资源，不再使用时必须释放：

```java
recorder.dispose();
```

JavaScript/WebGL 后端不支持录音。
