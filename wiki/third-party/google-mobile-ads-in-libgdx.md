---
title: 在 libGDX 中使用 Google Mobile Ads（替代已弃用的 AdMob）
---
目前 Android 和 libGDX 开发者使用最多的广告服务是 Google AdMob。

如果你的应用最近没有更新，应尽快考虑更新。Google 表示：

> Android（6.4.1 及更早版本的 SDK）
> 已弃用。自 2014 年 8 月 1 日起，Google Play 将不再接受使用旧版独立 Google Mobile Ads SDK v6.4.1 或更低版本的新应用或更新应用。届时必须升级到 Google Play 版本的 Mobile Ads SDK。

因此，我们需要迁移到新的 Google Play Services 方式，本 wiki 将带你完成这一过程。

***

**最简示例应用**

我使用 gdx-setup-ui.jar 创建了一个新的 libGDX 项目，添加 `.gitignore` 文件并完成了初始提交。


**Eclipse 设置**

在 Eclipse 中导入最简示例应用（file > import > existing projects into workspace），此时 Package Explorer 中至少应有三个项目（core、android 和 desktop）。

打开 Android SDK Manager，下载最新的 SDK Platform 和 Google APIs（本文撰写时为 4.4.2/API19）、2.3.1/API9 SDK Platform，以及 Extras 中的 Google Play Services。

在机器上找到 <android-sdk>/extras/google/google_play_services/libproject/google-play-services_lib/ 目录（例如 Windows 机器上的 C:\Program Files (x86)\Android\android-sdk\extras\google\google_play_services\libproject\google-play-services_lib），并将其复制到现有 libGDX 项目旁的工作目录中。

依次选择 File > Import > Android > Existing Android Code，点击 Next 和 Browse，导航到工作目录中的 google-play-services_lib 本地副本，然后点击 Ok 和 Finish。

右键点击 android 项目，选择 Properties > Android，向下滚动并点击 Add，选择 google-play-services_lib 项目，然后点击 Ok。

此时在 Eclipse 中刷新并清理一次通常不会有坏处，可以直接执行。


**AndroidManifest.xml**

确保 android 项目的 project.properties 文件中的 target 至少为 13，并且 AndroidManifest.xml 中的 android:minSdkVersion 至少为 9。遗憾的是，这意味着运行旧版 Android 的用户将无法使用，但我们对此无能为力。仍运行 2.3/API9 以下版本的设备已经非常非常少，因此不会排除太多用户……

将以下两行作为 application 元素的子元素添加：

`<meta-data android:name="com.google.android.gms.version" android:value="@integer/google_play_services_version"/>`   
`<activity android:name="com.google.android.gms.ads.AdActivity" android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize"/>`

将以下两个权限作为 manifest 元素的子元素添加：

`<uses-permission android:name="android.permission.INTERNET"/>`   
`<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>`

保存修改，然后在 Eclipse 中刷新并清理一次，以确保顺利运行。


**横幅广告**

[请参阅此版本的 android 项目 MainActivity 类](https://github.com/TheInvader360/tutorial-libgdx-google-ads/blob/9a4c9342d98c02e3c44e0b62fcfaa153d257130a/tutorial-libgdx-google-ads-android/src/com/theinvader360/tutorial/libgdx/google/ads/MainActivity.java)，其中提供了较为直接的横幅广告实现。


**插屏广告**

[这个 diff 展示了插屏广告的实现](https://github.com/TheInvader360/tutorial-libgdx-google-ads/commit/0a5ea376d4eb92b8e87c13a03245adb40b53e811)（ActionResolver 接口让我们可以从 core 项目触发插屏操作，同时保留 libGDX 非常重要的跨平台能力）。

***

全部步骤就是这些！

最后，如果从 [https://github.com/TheInvader360/tutorial-libgdx-google-ads](https://github.com/TheInvader360/tutorial-libgdx-google-ads) 克隆项目，请注意 Eclipse 中的 Problems 视图！你需要在 google-play-services_lib 和 tutorial-libgdx-google-ads-android 项目中分别创建空的 `gen` 目录，并确保安装了所需的 Android SDK。和 Eclipse 中的许多情况一样，多刷新和清理几次不会有坏处……
