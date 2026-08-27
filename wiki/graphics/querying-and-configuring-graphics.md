---
title: 查询和配置图形（显示器、显示模式、vsync、屏幕缺口）
---
# 配置与查询
libGDX 提供了完善的 API，可用于查询显示器和显示模式，以及切换垂直同步（vsync）。这些操作既可以在配置应用时完成，也可以在运行时完成。**注意：Android、iOS 和 HTML5 不支持更改显示模式。**

## 在配置时查询和设置显示器与显示模式
在配置时查询显示器和显示模式与平台有关。下面的小节介绍各个平台可执行的相关操作。

### 桌面端 LWJGL 3 后端
与旧版 LWJGL 2 后端不同，LWJGL 3 支持多显示器配置。

在配置时查询所有可用显示器的方式如下：
```java
Monitor[] monitors = Lwjgl3ApplicationConfiguration.getMonitors();
```

要获取主显示器，请调用：
```java
Monitor primary = Lwjgl3ApplicationConfiguration.getPrimaryMonitor();
```

要获取显示器支持的所有显示模式，请调用：
```java
DisplayMode[] displayModes = Lwjgl3ApplicationConfiguration.getDisplayModes(monitor);
```

要获取显示器当前的显示模式，请调用：
```java
DisplayMode desktopMode = Lwjgl3ApplicationConfiguration.getDisplayMode(monitor);
```

获取主显示器显示模式也有简写方法：
```java
DisplayMode[] primaryDisplayModes = Lwjgl3ApplicationConfiguration.getDisplayModes();
DisplayMode primaryDesktopMode = Lwjgl3ApplicationConfiguration.getDisplayMode();
```

取得显示模式后，可以将其设置到 `Lwjgl3ApplicationConfiguration`：
```java
DisplayMode primaryMode = Lwjgl3ApplicationConfiguration.getDisplayMode();
Lwjgl3ApplicationConfiguration config = new Lwjgl3ApplicationConfiguration();
config.setFullscreenMode(primaryMode);
new Lwjgl3Application(new MyAppListener(), config);
```
这会让应用在主显示器上以全屏模式启动，并使用该显示器的当前分辨率。如果传入其他显示器的显示模式，应用会在对应显示器上以全屏模式启动。**注意：建议始终使用显示器的当前显示模式，其他显示模式可能失败。**

要让应用以窗口模式启动，请在配置上调用此方法：
```java
Lwjgl3ApplicationConfiguration config = new Lwjgl3ApplicationConfiguration();
config.setWindowedMode(800, 600);
```

这会让应用在主显示器上以窗口模式启动。要设置窗口位置，请调用：
```java
config.setWindowPosition(100, 100);
```

这会将窗口左上角放置在相对于所有显示器组成的虚拟平面的 `100,100` 坐标处。要检查显示器位置，只需访问其 `virtualX` 和 `virtualY` 成员。这些坐标同样相对于显示器组成的虚拟平面。将窗口定位到这些坐标即可把窗口移动到对应显示器。

还可以指定窗口是否可调整大小，以及是否显示装饰（窗口标题栏和边框）：
```java
config.setResizable(false);
config.setDecorated(false);
```

LWJGL 3 后端还允许指定如何处理 HDPI 显示器。操作系统可能为绘制表面尺寸或鼠标事件报告逻辑尺寸和坐标，而不是基于像素的坐标。例如，在运行 Mac OS X 的 Retina MacBook Pro 上，操作系统只会报告底层像素表面一半的宽度和高度。LWJGL 3 后端可以让 `Gdx.graphics.getWidth()/getHeight()` 返回绘制表面尺寸，并将鼠标坐标报告为逻辑坐标或像素坐标。要配置此行为，请设置 HDPI 模式：

```java
config.setHdpiMode(HdpiMode.Logical);
```

这会以逻辑坐标报告鼠标坐标和绘制表面尺寸，也是该后端的默认行为。如果想使用原始像素，请使用 `HdpiMode.Pixels`。注意，使用逻辑坐标时，需要将其转换为像素坐标才能调用 `glScissor`、`glViewport` 或 `glReadPixels` 等 OpenGL 函数。libGDX 中调用这些函数的类都会考虑所设置的 `HdpiMode`；如果自行调用，请使用 `HdpiUtils`。

## 在运行时查询和设置显示器与显示模式
libGDX 通过 `Graphics` 接口提供 API，可在运行时查询显示器、显示模式及其他相关信息。了解可用配置后，可以设置它们，例如切换全屏模式或切换 vsync。

### 检查是否支持更改显示模式
只有部分平台支持更改显示模式。尤其是 Android 和 iOS 不支持切换到任意全屏显示模式。因此，最好检查应用当前运行的平台是否支持更改显示模式：
```java
if(Gdx.graphics.supportsDisplayModeChange()) {
   // change display mode if necessary
}
```
请注意，在不支持更改显示模式的平台上，`Graphics` 中所有与显示模式相关的函数都不会执行任何操作。

### 查询显示器
要查询所有已连接的显示器，请使用：
```java
Monitor[] monitors = Gdx.graphics.getMonitors();
```

在 Android、iOS、GWT 和 LWJGL 2 后端中，只会报告主显示器。LWJGL 3 后端会报告所有已连接的显示器。

要查询主显示器，请使用：
```java
Monitor primary = Gdx.graphics.getPrimaryMonitor();
```

要查询窗口当前所在的显示器，请使用：
```java
Monitor currMonitor = Gdx.graphics.getMonitor();
```

最好在窗口所在的显示器上切换全屏，而不是始终使用主显示器。这样用户可以先将应用窗口移动到其他显示器，再在那里启用全屏模式。

### 查询显示模式
取得 `Monitor` 实例后，可以查询其支持的显示模式：
```java
DisplayMode[] modes = Gdx.graphics.getDisplayModes(monitor);
```

要获取当前显示模式，请使用此方法：
```java
DisplayMode currMode = Gdx.graphics.getDisplayMode(monitor);
```

### 切换到全屏模式
取得指定 `Monitor` 的 `DisplayMode` 后，可以按如下方式切换到全屏模式：
```java
Monitor currMonitor = Gdx.graphics.getMonitor();
DisplayMode displayMode = Gdx.graphics.getDisplayMode(currMonitor);
if(!Gdx.graphics.setFullscreenMode(displayMode)) {
   // switching to full-screen mode failed
}
```
如果切换全屏模式失败，后端会恢复上一次的窗口模式配置。

### 切换到窗口模式
要更改窗口大小，或从全屏模式切换到窗口模式，请使用此方法：
```java
Gdx.graphics.setWindowedMode(800, 600);
```

这会将窗口设为窗口模式，并让它居中显示在调用此方法前所在的显示器上。

## 查询移动设备显示屏缺口
在 Android 和 iOS 上，显示屏不一定是完整矩形，可能存在缺口、圆角或覆盖内容的状态栏。可以使用 `Gdx.graphics.getSafeInsetLeft()`、`Gdx.graphics.getSafeInsetRight()`、`Gdx.graphics.getSafeInsetTop()` 和 `Gdx.graphics.getSafeInsetBottom()` 方法查询不适合放置重要游戏内容的区域。

## LWJGL 3 后端的桌面端与多窗口 API
编辑器等桌面专用工具可以从多窗口配置中受益。LWJGL 3 后端提供了额外的非跨平台 API，用于创建多个窗口。

每个应用都会从一个在配置阶段设置的窗口开始：
```java
Lwjgl3ApplicationConfiguration config = new Lwjgl3ApplicationConfiguration();
config.setWindowedMode(800, 600);
new Lwjgl3Application(new MyMainWindowListener(), config);
```

本例中的窗口由标准 `ApplicationListener` `MyMainWindowListener` 驱动。libGDX 不会直接报告最小化或失去焦点等事件。为此，LWJGL 3 后端引入了桌面专用接口 `Lwjgl3WindowListener`。可以提供该接口的实现来接收并响应这些事件：
```java
config.setWindowListener(new Lwjgl3WindowListener() {
   @Override
   public void iconified() {
      // the window is not visible anymore, potentially stop background
      // work, mute audio, etc.
   }

   @Override
   public void deiconified() {
      // the window is visible again, start-up background work, unmute
      // audio, etc.
   }

   @Override
   public void focusLost() {
      // the window lost focus, pause the game
   }

   @Override
   public void focusGained() {
      // the window received input focus, unpause the game
   }

   @Override
   public boolean windowIsClosing() {
      // if there's unsaved stuff, we may not want to close
      // the window, but ask the user to save her work
      if(isStuffUnsaved) {
         // tell our app listener to show a save dialog
         return false;
      } else {
         // OK, the window may close
         return true;
      }
});
```

如果窗口失去焦点，LWJGL 3 后端不会报告暂停和恢复事件。只有应用被最小化/恢复，或应用正在关闭时，才会报告暂停和恢复事件。

要创建额外窗口，需要将 `Gdx.app` 转换为 `Lwjgl3Application`。这只有在项目直接依赖 LWJGL 3 后端时才可行，因此此类代码无法与其他平台共享。取得 `Lwjgl3Application` 后，可以这样创建新窗口：
```java
Lwjgl3Application lwjgl3App = (Lwjgl3Application)Gdx.app;
Lwjgl3WindowConfiguration windowConfig = new Lwjgl3WindowConfiguration();
windowConfig.setWindowListener(new MyWindowListener());
windowConfig.setTitle("My other window");
Lwjgl3Window window = Lwjgl3App.newWindow(new MyOtherWindowAppListener(), windowConfig);
```

建议让每个窗口拥有自己的 `ApplicationListener`。应用的所有窗口都在同一线程上依次更新。LWJGL 3 后端会确保静态对象 `Gdx.graphics` 和 `Gdx.input` 已针对当前正在更新的窗口进行设置。这意味着你的 `ApplicationListener` 基本可以忽略其他窗口，把自己当作唯一的监听器。

但有一个例外：使用 `Gdx.app.postRunnable()` 时，LWJGL 3 后端无法判断 `Runnable` 是为哪个窗口提交的。例如，该方法可能由工作线程调用，而提交 `Runnable` 时可能正在更新另一个窗口。为解决此问题，建议直接向目标窗口提交专属于该窗口的 `Runnable` 实例：

```java
// e.g. in a worker thread
window.postRunnable(new MyRunnable());
```

这样可以确保执行 `Runnable` 时，静态对象 `Gdx.graphics` 和 `Gdx.input` 已针对指定窗口进行设置。

`Lwjgl3Window` 类还提供了用于修改窗口属性的方法。可以在 `ApplicationListener` 中获取当前窗口，然后修改它：
```java
// in ApplicationListener#render()
Lwjgl3Window window = ((Lwjgl3Graphics)Gdx.graphics).getWindow();
window.setVisible(false); // hide the window
window.iconifyWindow(); // iconify the window
window.deiconifyWindow(); // deiconify window
window.closeWindow(); // close the window, also disposes the ApplicationListener
```
