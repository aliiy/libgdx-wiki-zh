---
title: 音效
---
音效是较短的音频采样，通常不超过几秒，在角色跳跃或开枪等特定游戏事件中播放。

音效可以使用多种格式存储，包括 MP3、OGG 和 WAV。应使用哪种格式取决于具体需求，因为每种格式都有自己的优缺点。例如，WAV 文件相比其他格式很大，OGG 文件不能在 RoboVM（iOS）或 Safari（GWT）上工作，而 MP3 文件存在无缝循环问题。

**注意：**在 Android 上，Sound 实例不能超过 1MB（指未压缩的原始 PCM 大小，而不是文件大小）。如果文件更大，请改用 [Music](/wiki/audio/streaming-music)。
{: .notice--primary}

音效由 [Sound](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/audio/Sound.html) 接口表示。加载音效的方式如下：

```java
Sound sound = Gdx.audio.newSound(Gdx.files.internal("sounds/mysound.mp3"));
```

这会从内部目录 `sounds` 加载名为 `"mysound.mp3"` 的音频文件。

加载声音后即可播放：

```java
sound.play(1.0f);
```

这会以最大音量播放一次音效。单个 `Sound` 实例的 play 方法可以连续调用多次，例如播放游戏中的连续射击声，多个播放会相互叠加。

还可以进行更细粒度的控制。每次调用 `Sound.play()` 都会返回一个用于标识该声音实例的 long 值。使用这个句柄可以修改指定的播放实例：

```java
long id = sound.play(1.0f); // play new sound and keep handle for further manipulation
sound.stop(id);             // stops the sound instance immediately
sound.setPitch(id, 2);      // increases the pitch to 2x the original pitch

id = sound.play(1.0f);      // plays the sound a second time, this is treated as a different instance
sound.setPan(id, -1, 1);    // sets the pan of the sound to the left side at full volume
sound.setLooping(id, true); // keeps the sound looping
sound.stop(id);             // stops the looping sound 
```

***注意：***目前这些修改方法在 JavaScript/WebGL 后端中的功能有限。自 1.9.6 起，只有在支持 Flash 且启用 `GwtApplicationConfiguration.preferFlash = true` 时，`setPan()` 才能工作。

***注意：***`setPan()` 方法不能用于立体声。

不再需要 Sound 时，请务必将其释放：

```java
sound.dispose();
```

释放后继续访问该声音会导致未定义错误。

### 多个声音导致 Android 卡顿
如 [Audio](/wiki/audio/audio) 主题所述，Android 的音频整体存在许多问题。其中之一是等待声音 ID 可能需要很长时间。LibGDX 默认同步播放声音，因此一次播放大量声音时，主循环可能会冻结较长时间。这个问题在 Android 10 上尤其明显。

解决方法是改为异步播放。但这样将无法使用需要 ID 的声音方法。更多信息请参阅 [Audio#audio-on-android](/wiki/audio/audio#audio-on-android)。
