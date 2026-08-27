---
title: 启动类与配置
---
* [Desktop (LWJGL3)](#desktop-lwjgl3)
* [Android](#android)
  - [游戏 Activity](#game-activity)
  - [游戏 Fragment](#game-fragment)
  - [Manifest 配置](#manifest-configuration)
  - [动态壁纸](#live-wallpapers)
  - [屏幕保护程序（又称 Daydream）](#screen-savers-aka-daydreams)
* [iOS/Robovm](#iosrobovm)
* [HTML5/GWT](#html5gwt)


需要为每个目标平台编写一个启动类。该类会实例化特定后端的 `Application` 实现，以及实现应用程序逻辑的 `ApplicationListener`。启动类依赖平台，下面来看看如何为各后端实例化和配置它们。

本文假设你已按照[项目设置](/wiki/start/project-generation)和[导入并运行项目](/wiki/start/import-and-running)中的说明操作，并已在 IDE 中设置好项目。
{: .notice--info}

# 桌面端（LWJGL3）

从 libGDX 1.10.1 起，LWJGL3 一直是默认桌面后端。更多信息请参阅[此处](/news/2021/07/devlog-7-lwjgl3)。
{: .notice--info}

打开 `my-gdx-game` 中的 `Lwjgl3Launcher.java` 类，可以看到如下内容：

```java
package com.me.mygdxgame;

import com.badlogic.gdx.backends.lwjgl3.Lwjgl3Application;
import com.badlogic.gdx.backends.lwjgl3.Lwjgl3ApplicationConfiguration;
import com.me.mygdxgame.MyGdxGame;

public class Lwjgl3Launcher {
    public static void main(String[] args) {
        if (StartupHelper.startNewJvmIfRequired()) return;
        createApplication();
    }

    private static Lwjgl3Application createApplication() {
        return new Lwjgl3Application(new MyGdxGame(), getDefaultConfiguration());
    }

    private static Lwjgl3ApplicationConfiguration getDefaultConfiguration() {
        Lwjgl3ApplicationConfiguration configuration = new Lwjgl3ApplicationConfiguration();
        configuration.setTitle("my-gdx-game");
        configuration.useVsync(true);
        configuration.setForegroundFPS(Lwjgl3ApplicationConfiguration.getDisplayMode().refreshRate);
        configuration.setWindowedMode(640, 480);
        configuration.setWindowIcon("libgdx128.png", "libgdx64.png", "libgdx32.png", "libgdx16.png");
        return configuration;
    }
}
```

首先实例化 [Lwjgl3ApplicationConfiguration](https://github.com/libgdx/libgdx/blob/master/backends/gdx-backend-lwjgl3/src/com/badlogic/gdx/backends/lwjgl3/Lwjgl3ApplicationConfiguration.java)。该类可以指定各种配置设置，例如初始屏幕分辨率、使用 OpenGL ES 2.0 还是 3.0 等。更多信息请参阅该类的 Javadocs。

设置好配置对象后，会实例化 `Lwjgl3Application`。`MyGdxGame()` 类是实现游戏逻辑的 ApplicationListener。

之后会创建窗口，并按照[生命周期](/wiki/app/the-life-cycle)中的说明调用 ApplicationListener。

# Android

## 游戏 Activity

Android 应用程序不使用 `main()` 方法作为入口点，而是需要一个 Activity。打开 `my-gdx-game-android` 项目中的 `AndroidLauncher.java` 类：

```java
package com.me.mygdxgame;

import android.os.Bundle;

import com.badlogic.gdx.backends.android.AndroidApplication;
import com.badlogic.gdx.backends.android.AndroidApplicationConfiguration;
import com.me.mygdxgame.MyGdxGame;

public class AndroidLauncher extends AndroidApplication {
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        AndroidApplicationConfiguration configuration = new AndroidApplicationConfiguration();
        configuration.useImmersiveMode = true;
        initialize(new MyGdxGame(), configuration);
    }
}
```

主要入口方法是 Activity 的 `onCreate()` 方法。请注意，`AndroidLauncher` 继承自 `AndroidApplication`，而后者继承自 `Activity`。与桌面启动类一样，会创建配置实例（[AndroidApplicationConfiguration](https://github.com/libgdx/libgdx/tree/master/backends/gdx-backend-android/src/com/badlogic/gdx/backends/android/AndroidApplicationConfiguration.java)）。配置完成后，调用 `AndroidApplication.initialize()` 方法，同时传入 `ApplicationListener`（`MyGdxGame`）和配置。可参阅 [AndroidApplicationConfiguration Javadocs](https://javadoc.io/doc/com.badlogicgames.gdx/gdx/latest/com/badlogic/gdx/backends/android/AndroidApplicationConfiguration.html) 了解可用配置设置。

Android 应用程序可以有多个 activity。libGDX 游戏通常应只包含一个 activity。游戏的不同屏幕应在 libGDX 内实现，而不是使用独立 activity。原因是创建新的 `Activity` 也意味着创建新的 OpenGL 上下文，这会耗费时间，并且意味着必须重新加载所有图形资源。

## 游戏 Fragment

libGDX 游戏可以托管在 Android [Fragment](https://developer.android.com/guide/fragments) 中，而不必使用完整的 Activity。这样可以让游戏只占据 Activity 的一部分屏幕，或在不同布局之间移动。要创建 libGDX fragment，请继承 `AndroidFragmentApplication`，并在 `onCreateView()` 中使用以下初始化代码：
```java
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return initializeForView(new MyGdxGame());
    }
```

该代码还需要对 -android 项目进行以下修改：
1. 如果尚未添加，请将 [AndroidX Fragment Library](https://developer.android.com/jetpack/androidx/releases/fragment) 添加到 -android 项目及其构建路径中，之后才能继承 FragmentActivity。
2. 将 AndroidLauncher Activity 改为继承 FragmentActivity，而不是 AndroidApplication。
3. 在 AndroidLauncher Activity 中实现 AndroidFragmentApplication.Callbacks。
4. 创建一个继承 AndroidFragmentApplication 的类，作为 libGDX 的 Fragment 实现。
5. 在 Fragment 的 `onCreateView` 方法中添加 `initializeForView()` 代码。
6. 最后，将 AndroidLauncher activity 的内容替换为 libGDX Fragment。

例如：
```java
// 2. Change AndroidLauncher activity to extend FragmentActivity, not AndroidApplication
// 3. Implement AndroidFragmentApplication.Callbacks on the AndroidLauncher activity
public class AndroidLauncher extends FragmentActivity implements AndroidFragmentApplication.Callbacks
{
   @Override
   protected void onCreate (Bundle savedInstanceState)
   {
      super.onCreate(savedInstanceState);

      // 6. Finally, replace the AndroidLauncher activity content with the libGDX Fragment.
      GameFragment fragment = new GameFragment();
      FragmentTransaction trans = getSupportFragmentManager().beginTransaction();
      trans.replace(android.R.id.content, fragment);
      trans.commit();
   }

   // 4. Create a Class that extends AndroidFragmentApplication which is the Fragment implementation for libGDX.
   public static class GameFragment extends AndroidFragmentApplication
   {
      // 5. Add the initializeForView() code in the Fragment's onCreateView method.
      @Override
      public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
      {  return initializeForView(new MyGdxGame());   }
   }

   @Override
   public void exit() {}
}
```

## Manifest 配置
除了 `AndroidApplicationConfiguration` 外，Android 应用程序还通过 Android 项目根目录中的 `AndroidManifest.xml` 文件进行配置。该文件可能如下所示：

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
  <uses-feature android:glEsVersion="0x00020000" android:required="true"/>
  <application
      android:allowBackup="true"
      android:fullBackupContent="true"
      android:icon="@drawable/ic_launcher"
      android:isGame="true"
      android:appCategory="game"
      android:label="@string/app_name"
      tools:ignore="UnusedAttribute"
      android:theme="@style/GdxTheme">
    <activity
        android:name="com.me.mygdxgame.android.AndroidLauncher"
        android:label="@string/app_name"
        android:screenOrientation="landscape"
        android:configChanges="keyboard|keyboardHidden|navigation|orientation|screenSize|screenLayout"
        android:exported="true">
        <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
      </intent-filter>
    </activity>
  </application>

</manifest>
```

#### 屏幕方向与配置变化
除了 targetSdkVersion 外，还应始终设置 activity 元素的 `screenOrientation` 和 `configChanges` 属性。

`screenOrientation` 属性指定应用程序的固定方向。如果应用程序同时支持横屏和竖屏，可以省略此属性。

`configChanges` 属性*非常重要*，应始终使用上面显示的值。省略此属性意味着每次滑出/收回实体键盘或设备方向发生变化时，应用程序都会重启。如果省略 `screenOrientation` 属性，libGDX 应用程序会收到 `ApplicationListener.resize()` 调用，以表示方向发生变化。API 使用者随后可以据此重新布局应用程序。

#### 权限
如果应用程序需要写入设备的外部存储（例如 SD 卡）、访问互联网、使用振动器或录制音频，则需要将以下权限添加到 `AndroidManifest.xml` 文件中：

```xml
	<uses-permission android:name="android.permission.RECORD_AUDIO"/>
	<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
	<uses-permission android:name="android.permission.VIBRATE"/>
```

用户通常会对申请大量权限的应用程序保持警惕，因此请谨慎选择权限。

要使唤醒锁生效，需要将 `AndroidApplicationConfiguration.useWakeLock` 设置为 true。

如果游戏不需要访问加速度计或指南针，建议将 `AndroidApplicationConfiguration` 的
`useAccelerometer` 和 `useCompass` 字段设置为 false。

如果游戏需要陀螺仪传感器，必须在 `AndroidApplicationConfiguration` 中将 `useGyroscope` 设置为 true（默认禁用以节省电量）。

有关如何设置应用程序图标等其他属性的更多信息，请参阅 [Android Developer's Guide](https://developer.android.com/guide)。

## 动态壁纸
libGDX 核心应用程序也可以用作 Android [动态壁纸](https://android-developers.googleblog.com/2010/02/live-wallpapers.html)。
项目设置与 Android 游戏非常相似，但使用 `AndroidLiveWallpaperService` 代替
`AndroidApplication`。动态壁纸是 Android [服务](https://developer.android.com/guide/components/services)，
而不是 Activity。

**注意：由于同步问题，不能在同一个应用中同时使用游戏和动态壁纸。不过，动态壁纸和屏幕保护程序可以在同一个应用中安全共存。**

首先，继承 `AndroidLiveWallpaperService` 并重写 `onCreateApplication()`（而不是像游戏
`Activity` 那样重写 `onCreate()`）：

```java
public class MyLiveWallpaper extends AndroidLiveWallpaperService {
    @Override
    public void onCreateApplication() {
        AndroidApplicationConfiguration cfg = new AndroidApplicationConfiguration();

        initialize(new MyGdxGame(), cfg);
    }
}
```

你可以让 `ApplicationListener` 类实现 `AndroidWallpaperListener`，以选择性地订阅动态壁纸专属事件。
`AndroidWallpaperListener` 不在 `core` 模块中提供，因此可以采用[与平台特定代码交互](/wiki/app/interfacing-with-platform-specific-code)中介绍的策略，
也可以仅在 `android` 模块中继承自己的 `ApplicationListener`，如下所示：

```java
public class MyLiveWallpaper extends AndroidLiveWallpaperService {

    static class MyLiveWallpaperListener extends MyGdxGame implements AndroidWallpaperListener {
        @Override
        public void offsetChange (float xOffset, float yOffset, float xOffsetStep,
                                  float yOffsetStep, int xPixelOffset, int yPixelOffset) {
            // Called when the home screen is scrolled. Not all launchers support this.
        }

        @Override
        public void previewStateChange (boolean isPreview) {
            // Called when switched between being previewed and running as the wallpaper.
        }

        @Override
        public void iconDropped (int x, int y) {
            // Called when an icon is dropped on the home screen.
        }
    }

    @Override
    public void onCreateApplication() {
        AndroidApplicationConfiguration cfg = new AndroidApplicationConfiguration();

        initialize(new MyLiveWallpaperListener(), cfg);
    }
}
```

从 libGDX 1.9.12 起，还可以向操作系统报告壁纸的主色。Android 8.1 起，部分 Android 启动器和锁屏会使用这些颜色进行样式设置，例如更改时钟的文字颜色。可以创建如下方法来报告颜色，并按照[与平台特定代码交互](/wiki/app/interfacing-with-platform-specific-code)中的策略从 core 模块访问它：

```java
public void notifyColorsChanged (Color primaryColor, Color secondaryColor, Color tertiaryColor) {
    Application app = Gdx.app;
    if (Build.VERSION.SDK_INT >= 27 && app instanceof AndroidLiveWallpaper) {
        ((AndroidLiveWallpaper) app).notifyColorsChanged(primaryColor, secondaryColor, tertiaryColor);
    }
}
```

除了服务类，还必须在 Android `res/xml` 目录中创建一个 `xml` 文件，用于定义动态壁纸的部分属性：壁纸选择器中显示的缩略图和描述，以及可选的设置 Activity。这里将该文件命名为 `livewallpaper.xml`。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<wallpaper
    xmlns:android="http://schemas.android.com/apk/res/android"  
    android:thumbnail="@drawable/ic_launcher"
    android:description="@string/description"
    android:settingsActivity="com.mypackage.MyLiveWallpaperSettingsActivity"/>
```

最后，还需要向 `AndroidManifest.xml` 文件中添加内容。下面是带有简单设置 Activity 的动态壁纸示例。这里的关键元素是 `uses-feature` 和 `service` 块。服务上设置的标签和图标会显示在 Android 应用设置中。设置 Activity 和动态壁纸服务都必须将 `exported` 设置为 true，才能由动态壁纸选择器访问。

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.mypackage">
    <uses-feature android:name="android.software.live_wallpaper" />
    <application android:icon="@drawable/icon" android:label="@string/app_name">
        <activity android:name=".MyLiveWallpaperSettingsActivity"
            android:label="@string/app_name"
            android:exported="true" />
        <service android:name=".LiveWallpaper"
            android:label="@string/app_name"
            android:icon="@drawable/icon"
            android:exported="true"
            android:permission="android.permission.BIND_WALLPAPER">
            <intent-filter>
                <action android:name="android.service.wallpaper.WallpaperService" />
            </intent-filter>
            <meta-data android:name="android.service.wallpaper"
                android:resource="@xml/livewallpaper" />
        </service>				  	
    </application>
</manifest>
```

动态壁纸的触摸输入存在一些限制。通常只会报告一个指针。如果需要完整的多点触控事件，可以将 `AndroidApplicationConfiguration.getTouchEventsForLiveWallpaper` 字段设置为 true。

## 屏幕保护程序（又称 Daydream）
libGDX 核心应用程序也可以用作 Android [屏幕保护程序](https://developer.android.com/about/versions/android-4.2#Daydream)。屏幕保护程序曾被称为 Daydream，因此许多相关类的名称中都包含“Daydream”一词。屏幕保护程序与 Google 的 Daydream VR 平台无关。

项目设置与 Android 游戏非常相似，但使用 `AndroidDaydream` 代替 `AndroidApplication`。屏幕保护程序是 Android [服务](https://developer.android.com/guide/components/services)，而不是 Activity。

首先，继承 `AndroidDaydream` 并重写 `onAttachedToWindow()`（而不是像游戏 `Activity` 那样重写 `onCreate()`）。该方法必须调用 `super`。还可以在此方法中调用 `setInteractive()` 来启用或禁用触摸。非交互式屏幕保护程序在屏幕被触摸时会立即关闭。

```java
public class MyScreenSaver extends AndroidDaydream {
    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        setInteractive(true);

        AndroidApplicationConfiguration cfg = new AndroidApplicationConfiguration();
        initialize(new MyGdxGame(), cfg);
    }
}
```

除了服务类，还必须在 Android `res/xml` 目录中创建一个 `xml` 文件，用于定义屏幕保护程序唯一的设置：可选的设置 Activity。这里将该文件命名为 `screensaver.xml`。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<dream xmlns:android="http://schemas.android.com/apk/res/android"
    android:settingsActivity="com.badlogic.gdx.tests.android/.MyScreenSaverSettingsActivity" />
```

最后，还需要向 `AndroidManifest.xml` 文件中添加内容。下面是带有简单设置 Activity 的屏幕保护程序示例。注意，设置 Activity 是可选的。关键元素是 `service` 块。设置 Activity 和屏幕保护程序服务都必须将 `exported` 设置为 true，才能由屏幕保护程序选择器访问。

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.mypackage">
    <application android:icon="@drawable/icon" android:label="@string/app_name">
        <activity android:name=".MyScreenSaverSettingsActivity"
            android:label="@string/app_name"
            android:exported="true" />
        <service android:name=".MyScreenSaver"
            android:label="@string/app_name"
            android:icon="@drawable/icon"
            android:exported="true" >
            <intent-filter>
                <action android:name="android.service.dreams.DreamService" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
            <meta-data android:name="android.service.dream"
                android:resource="@xml/screensaver" />
        </service>			  	
    </application>
</manifest>
```

# iOS/Robovm

打开 `my-gdx-game` 中的 `IOSLauncher.java` 类，可以看到如下内容：

```java
package com.me.mygdxgame.ios;

import org.robovm.apple.foundation.NSAutoreleasePool;
import org.robovm.apple.uikit.UIApplication;

import com.badlogic.gdx.backends.iosrobovm.IOSApplication;
import com.badlogic.gdx.backends.iosrobovm.IOSApplicationConfiguration;
import com.me.mygdxgame.MyGdxGame;

public class IOSLauncher extends IOSApplication.Delegate {
    @Override
    protected IOSApplication createApplication() {
        IOSApplicationConfiguration configuration = new IOSApplicationConfiguration();
        return new IOSApplication(new MyGdxGame(), configuration);
    }

    public static void main(String[] argv) {
        NSAutoreleasePool pool = new NSAutoreleasePool();
        UIApplication.main(argv, null, IOSLauncher.class);
        pool.close();
    }
}
```

有关部署到 iOS 设备的更多细节，请参阅[这篇 Medium 文章](https://medium.com/@bschulte19e/deploying-your-libgdx-game-to-ios-in-2020-4ddce8fff26c)。

# HTML5/GWT
HTML5/GWT 应用程序的主要入口点是 `GwtApplication`。打开 my-gdx-game-html5 项目中的 `GwtLauncher.java`：

```java
package com.me.mygdxgame.gwt;

import com.badlogic.gdx.ApplicationListener;
import com.badlogic.gdx.backends.gwt.GwtApplication;
import com.badlogic.gdx.backends.gwt.GwtApplicationConfiguration;
import com.me.mygdxgame.MyGdxGame;

public class GwtLauncher extends GwtApplication {
    @Override
    public GwtApplicationConfiguration getConfig () {
        GwtApplicationConfiguration cfg = new GwtApplicationConfiguration(true);
        cfg.padVertical = 0;
        cfg.padHorizontal = 0;
        return cfg;
    }

    @Override
    public ApplicationListener createApplicationListener () {
        return new MyGdxGame();
    }
}
```

主要入口由两个方法组成：`GwtApplication.getConfig()` 和 `GwtApplication.createApplicationListener()`。前者必须返回 [GwtApplicationConfiguration](https://github.com/libgdx/libgdx/tree/master/backends/gdx-backends-gwt/src/com/badlogic/gdx/backends/gwt/GwtApplicationConfiguration.java) 实例，用于指定 HTML5 应用程序的各种配置。`GwtApplication.createApplicatonListener()` 方法返回要运行的 `ApplicationListener`。

### 模块文件
GWT 需要每个被引用 jar/项目的实际 Java 代码。此外，每个此类 jar/项目都需要一个模块定义文件，文件后缀为 gwt.xml。

在示例项目设置中，html5 项目的模块文件如下所示：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE module PUBLIC "-//Google Inc.//DTD Google Web Toolkit 2.11.0//EN" "https://www.gwtproject.org/doctype/2.11.0/gwt-module.dtd">
<module rename-to="html">
  <source path="" />

  <inherits name="com.badlogic.gdx.backends.gdx_backends_gwt" />
  <inherits name="com.me.mygdxgame.MyGdxGame" />

  <entry-point class="com.me.mygdxgame.gwt.GwtLauncher" />

  <set-configuration-property name="gdx.assetpath" value="../assets" />
  <set-configuration-property name="xsiframe.failIfScriptTag" value="FALSE"/>
  <set-property name="user.agent" value="gecko1_8, safari"/>
  <collapse-property name="user.agent" values="*" />
</module>
```

该文件指定了要继承的两个其他模块（gdx-backends-gwt 和 core 项目）、入口类（上面的 `GwtLauncher`），以及一个相对于 html5 项目根目录、指向 assets 目录的路径。

gdx-backend-gwt jar 和 core 项目也有类似的模块文件，用于指定其他依赖。*不能使用不包含模块文件和源代码的 jar/项目！*

有关模块和依赖的更多信息，请参阅 [GWT Developer Guide](https://developers.google.com/web-toolkit/doc/1.6/DevGuide)。

### GWT 特性

HTML 后端存在一些注意事项。请务必查看完整的 [HTML Backend Guide](/wiki/html5-backend-and-gwt-specifics#differences-between-gwt-and-desktop-java)！
{: .notice--warning}

由于各种原因，GWT 不支持 Java **反射**。libGDX 内部有一个仿真层，会为少数内部类生成反射信息。这意味着如果使用 libGDX 的 [Json 序列化](/wiki/utils/reading-and-writing-json)功能，就会遇到问题。可以指定应为哪些包和类生成反射信息来解决。具体请查看[反射指南](/wiki/utils/reflection#gwt)。

libGDX HTML5 应用程序会预加载 `gdx.assetpath` 中的所有资源。加载过程中会显示一个通过 GWT widget 实现的**加载屏幕**。如果要自定义该加载屏幕，只需重写 `GwtApplication.getPreloaderCallback()` 方法（在上例的 `GwtLauncher` 中）。示例请参阅[此处](/wiki/html5-backend-and-gwt-specifics#changing-the-load-screen-progress-bar)。
