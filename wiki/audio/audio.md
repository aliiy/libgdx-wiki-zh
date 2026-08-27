---
title: 音频
---
# 简介

libGDX 提供播放短音效以及直接从磁盘流式播放较长音乐的方法，也提供了便捷的音频硬件读写访问能力。

所有音频功能都通过[audio 模块](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/Audio.html)访问，其引用方式如下：

```java
Audio audio = Gdx.audio;
```

当应用暂停和恢复时，libGDX 会自动暂停和恢复所有音频播放。


# Android 上的音频

libGDX Android 后端使用 `SoundPool` API 播放 `Sound`，使用 `MediaPlayer` 播放 `Music`。这些 API 在某些场景下存在一些限制和已知问题：
- 延迟表现不佳，因此不建议在节奏游戏等对延迟敏感的应用中使用默认实现。
- 同时播放多个声音可能会在某些设备上造成性能问题。一种简单的解决方法是使用替代实现 `AsynchronousAndroidAudio`（但部分方法不受支持），在 `AndroidLauncher` 中这样实现 `createAudio()`：

```java
@Override
public AndroidAudio createAudio(Context context, AndroidApplicationConfiguration config) {
	return new AsynchronousAndroidAudio(context, config);
}
```

总的来说，Android 上的音频存在不少问题，也可能有其他场景或特定设备的问题。

## 替代方案

为解决其中一些问题，Google 创建了 [Oboe](https://github.com/google/oboe)，借助 [libGDX Oboe](https://github.com/barsoosayque/libgdx-oboe) 即可用于 libGDX 项目。

另一种方案是通过 [gdx-miniaudio](https://github.com/rednblackgames/gdx-miniaudio) 使用 [MiniAudio](https://miniaud.io/)。这是一个持续维护的跨平台音频引擎，已经被一些 libGDX 游戏用于生产环境。

libGDX 设置工具 gdx-liftoff 提供加载 libGDX-Oboe 和 gdx-miniaudio 的选项，可在 gdx-liftoff 的 Third-Party 部分找到。
