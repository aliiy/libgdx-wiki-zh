---
title: 在 libGDX 中使用 Google Play Games Services
---
[Google Play Games Services](https://developers.google.com/games/services/) 提供社交排行榜、成就以及更多功能（实时多人游戏、云存档、反盗版等）。

跨平台功能已弃用，新项目建议仅在 Android 上使用。

## 使用开源 libGDX 扩展
[gdx-gamesvcs libGDX 扩展](https://github.com/MrStahlfelge/gdx-gamesvcs) 为 Android 和桌面端的 libGDX 游戏提供 Google Play Games 支持。该扩展还实现了其他游戏服务（Apple Game Center、GameJolt 等）。

请按照 README 和项目 wiki 的说明，将 GPGS 及其他游戏服务集成到项目中。

## 手动集成到项目

下面介绍不使用该库时如何手动集成到项目。

这是一个基于 [Super Jumper](https://github.com/libgdx/libgdx-demo-superjumper) 的示例，使用了排行榜和成就功能。

该项目可以从 [GitHub](https://github.com/TheInvader360/libgdx-gameservices-tutorial) 免费获取，配套教程见[这里](https://theinvader360.blogspot.co.uk/2013/10/google-play-game-services-tutorial-example.html)。

另一个介绍如何添加 Google Play Game Services 的深入 libGDX 教程见[这里](https://fortheloss.org/tutorial-set-up-google-services-with-libgdx/)。

使用 Android Studio 的最新教程见[这里](https://chandruscm.wordpress.com/2015/12/30/how-to-setup-google-play-game-services-in-libgdx-using-android-studio/)。

### IntelliJ IDEA 和 Android Studio 设置

1. 使用 Android SDK 安装 Google Play Service 和 Google Play Repository。
   在 Android Studio 中，打开 SDK Manager（点击顶部工具栏中 AVD manager 旁边的按钮），再点击 Launch Standalone SDK Manager。
   向下滚动到 Extras 部分，确保以下两个软件包已安装并更新到最新版本：
   * Google Play services
   * Google Repository
2. 从[这里](https://github.com/playgameservices/android-basic-samples)下载 BaseGameUtils 示例项目，将 `BasicSamples` 文件夹中的 `BaseGameUtils` 复制到项目根目录。
3. 编辑 `settings.gradle`
   ```gradle
   include 'desktop', 'android', 'ios', 'html', 'core', "BaseGameUtils"
   ```
4. 编辑根目录的 `build.gradle`，将以下内容作为 Android 依赖添加：
   ```gradle
   compile project(":BaseGameUtils")
   ```
5. 在 `AndroidManifest.xml` 文件中：
    * 添加两个权限：
      ```xml
      <uses-permission android:name="android.permission.INTERNET" />
      <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
      ```
    * 添加到 application 标签中：
      ```xml
      <meta-data android:name="com.google.android.gms.games.APP_ID" android:value="@string/app_id" />
      ```
6. 在 Android 项目的 `res`->`values` 下，在 `strings.xml` 中按如下方式添加 app_id，其中 123456789 是你在 Google Play Developer Console 中声明的应用 ID：
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
     <resources>
     <string name="app_name">sample_ios_google_signin</string>
     <string name="app_id">123456789</string>
   </resources>
   ```

7. Android 项目中的 `build.gradle`

与 Gradle 同步后，你会看到以下消息：
   ```
   Error:Execution failed for task ':android:processDebugManifest'.
   > Manifest merger failed : uses-sdk:minSdkVersion 9 cannot be smaller than version 15 declared in library [libgdx-GPGS:BaseGameUtils:1.0]
   ```

将 `minSdkVersion` 修改为上面消息中的版本号（本例为 '15'）。

## iOS 集成

Google Play Game Services 已不再支持 iOS。你应改用 [gdx-gamesvcs](https://github.com/MrStahlfelge/gdx-gamesvcs) 或 [Firebase](/wiki/third-party/firebase-in-libgdx) 等方案。
{: .notice--warning}
