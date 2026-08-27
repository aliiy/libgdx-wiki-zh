---
title: 振动器
---
虽然它严格来说不是输入设备，但仍属于一种外设。我们认为它应归入输入模型。

振动器可以让用户的移动设备振动。它可以与音效结合使用，或代替音效为用户提供反馈。

## 启用支持

### Android

在 Android 上，振动需要在 `AndroidManifest.xml` 中声明以下权限，否则尝试振动会导致应用崩溃：

```xml
<uses-permission android:name="android.permission.VIBRATE" />
```

这是一个“普通”的安装时权限，意味着无需用户同意即可自动授予。如果发布到 Google Play 商店，该权限会在应用商店页面中列为“控制振动”。

### iOS

在 iOS 上，需要在 `IOSLauncher` 中启用触觉反馈：

```java
config.useHaptics = true;
```

### GWT

GWT 后端不支持振动。不过，使用[平台特定代码](/wiki/app/interfacing-with-platform-specific-code)实现基本振动非常简单。

```java
native void vibrateJsni(int milliseconds) /*-{
    navigator.vibrate(milliseconds);
}-*/;
```

这仅适用于非静音 Android 设备上的 Chromium 浏览器。尽管 caniuse.com 声称 Android 版 Firefox 支持此功能，但由于滥用，该支持已从 Firefox 79 起禁用。

## 振动

### 简单振动

最简单的振动形式是让马达运行指定的毫秒数。

在此示例中，支持的 Android 和 iOS 设备会振动 1 秒：

```java
Gdx.input.vibrate(1000);
```

对于不支持触觉反馈或运行 iOS 13 之前版本的 iPhone，无论传入什么参数，设备都会振动 400ms。如果不希望这样，可以禁用回退行为：

```java
Gdx.input.vibrate(1000, false);
```

### 振幅

某些设备支持设置振动幅度，即振动的强度，取值范围为 0 到 255。

```java
// Vibrate for 1 second at half amplitude, no fallback
Gdx.input.vibrate(1000, 127, false);

// Vibrate for 1 second at full amplitude, with fallback
Gdx.input.vibrate(1000, 255, true);
```

如果 `fallback` 布尔值为 `true`，不支持幅度控制的 Android 设备会忽略幅度参数，而未运行 iOS 13 或更高版本的 iPhone 会忽略所有参数。

### 预设

libGDX 提供三种预设振动强度：

```java
Gdx.input.vibrate(Input.VibrationType.LIGHT);
Gdx.input.vibrate(Input.VibrationType.MEDIUM);
Gdx.input.vibrate(Input.VibrationType.HEAVY);
```

这些强度会交由系统处理，因此应当与用户使用的其他应用提供一致的体验。这也意味着它们并非在所有设备上都有效。

此方法要求设备至少运行 Android 10 且支持幅度控制，或运行 iOS 13 并支持触觉反馈。在入门级或较旧的设备上，此方法不会产生任何效果。

### 模式

从 libGDX 1.12.0 起，振动模式（也称为波形）不再受支持。对于使用此功能的现有游戏，可以在 `android` 模块中重新实现，或者为了支持跨平台，在单独的线程中解析模式。

```java
public void vibrate (long[] pattern, int repeat) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
        vibrator.vibrate(VibrationEffect.createWaveform(pattern, repeat));
    else vibrator.vibrate(pattern, repeat);
}
```

## 检测振动器支持

你可能需要检测设备是否支持振动或幅度控制。

```java
boolean vibration = Gdx.input.isPeripheralAvailable(Input.Peripheral.Vibrator);
boolean amplitude = Gdx.input.isPeripheralAvailable(Input.Peripheral.HapticFeedback);
```

在上面的示例中，以下情况下各变量会为 `true`：

|操作系统|`vibration`|`amplitude`|
|--|-----------|-----------|
|**Android**|设备支持振动。但这不代表应用拥有振动权限！|设备支持幅度控制振动。|
|**iOS**|`useHaptics` 为 `true`，且设备采用手机外形。这包括没有振动马达的 iPod touch。|`useHaptics` 为 `true`，且设备支持超出 400ms 回退行为的振动。|

尤其是在 Android 上，这对于仅向支持振动的设备显示振动设置，以及为功能较弱的振动设备提供自定义回退方案等场景很有用：

```java
if (Gdx.input.isPeripheralAvailable(Input.Peripheral.HapticFeedback)) {
    Gdx.input.vibrate(Input.VibrationType.MEDIUM);
} else {
    Gdx.input.vibrate(50);
}
```

这些值仅反映设备本身是否能够振动。没有内置振动器的设备仍然可以让外部设备振动。相关内容请参阅 [gdx-controllers](/wiki/input/controllers) 中的 `Controller#canVibrate`。

## 其他注意事项

设计游戏时，可能需要考虑哪些设备支持振动。

* 智能手机和智能手表几乎都配有振动马达，但通常只有旗舰设备支持幅度控制。
* 平板电脑是否支持振动取决于具体型号。Samsung 和 Lenovo 平板通常支持，而 iPad 和 Pixel Tablet 不支持。
* Chromebook 和电视等更大型的设备几乎从不支持振动。

振动可能会让部分用户感到不适，因此应始终允许用户将其关闭。通常可以在游戏设置或主菜单中提供此选项。

一些应用会在用户设备处于静音模式时禁用振动（在 Android 上使用 `AudioManager#getRingerMode`），但这并不是理想做法，因为用户可能希望设备为通知振动，却不希望游戏振动，反之亦然。
