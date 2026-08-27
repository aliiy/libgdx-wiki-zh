---
title: 流式音乐
---
对于超过几秒的声音，最好从磁盘流式读取，而不是完整加载到 RAM 中。libGDX 提供了实现这一点的 Music 接口。

加载 Music 实例的方式如下：

```java
Music music = Gdx.audio.newMusic(Gdx.files.internal("music/mymusic.mp3"));
```

这会从内部目录 `music` 加载名为 `"mymusic.mp3"` 的 MP3 文件。

播放音乐实例的方式如下：

```java
music.play();
```

当然，你可以设置 `Music` 实例的各种播放属性：

```java
music.setVolume(0.5f);                 // sets the volume to half the maximum volume
music.setLooping(true);                // will repeat playback until music.stop() is called
music.stop();                          // stops the playback
music.pause();                         // pauses the playback
music.play();                          // resumes the playback
boolean isPlaying = music.isPlaying(); // obvious :)
boolean isLooping = music.isLooping(); // obvious as well :)
float position = music.getPosition();  // returns the playback position in seconds
```

在某些后端（例如 Android）上，`Music` 实例开销较大，通常不应同时加载超过约 10 个，或同时播放超过 1～2 个。

不再需要 `Music` 实例时必须将其释放，以回收资源。

```java
music.dispose();
```

## 无缝音乐

如果音乐需要无缝循环，请注意 MP3 格式虽然跨平台兼容，但存在阻止完全无缝播放的技术限制（参见 [LAME 技术 FAQ](https://lame.sourceforge.io/tech-FAQ.txt) 中的“为什么 MP3 文件无法无缝拼接？”）。解决方案取决于目标平台：

- 对于仅面向**桌面和 Web** 的项目，Ogg 格式可能更合适，因为它能避免 MP3 的间隙问题，而且在相同比特率下保真度更高。iOS 不支持该格式；在 Android 上，由于 LibGDX Audio 模块当前的限制，仍会存在一些间隙。
- 如果目标平台是 **iOS 和 Android**，可以考虑使用第三方跨平台音频后端[替代方案](https://libgdx.com/wiki/audio/audio#alternatives)，尤其是 [gdx-miniaudio](https://github.com/rednblackgames/gdx-miniaudio)。
- 对于仅面向 **Web** 的项目，还可以考虑直接从服务器流式播放预先循环的音乐。将音乐排除在预加载过滤器之外，并且不要使用 AssetManager，即可做到这一点。这样可以按需长时间循环音乐，同时不会增加游戏加载时间。
