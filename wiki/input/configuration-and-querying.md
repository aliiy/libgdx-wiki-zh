---
title: 配置与查询
---
有时需要知道支持哪些输入设备。游戏也常常不需要所有受支持的输入设备，例如可能不需要加速度计或指南针。在这种情况下禁用这些输入设备是节省 Android 电量的良好实践。以下部分将介绍如何执行这些操作。


## 禁用加速度计和指南针（Android、iOS 和 Html）
[AndroidApplicationConfiguration](https://github.com/libgdx/libgdx/tree/master/backends/gdx-backend-android/src/com/badlogic/gdx/backends/android/AndroidApplicationConfiguration.java) 类提供了几个 public 字段，可以在将其传给 `AndroidApplication.initialize()` 方法前进行设置。

假设游戏不需要加速度计和指南针，可以按如下方式禁用这些输入设备：

```java
public class MyGameActivity extends AndroidApplication {
   @Override
   public void onCreate (Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      AndroidApplicationConfiguration config = new AndroidApplicationConfiguration();
      config.useAccelerometer = false;
      config.useCompass = false;
      initialize(new MyGame(), config);
   }
}
```

加速度计和指南针默认都已启用。上面的代码会禁用它们，从而节省宝贵的电量。

## 启用陀螺仪（Android 和 Html）
陀螺仪默认禁用以节省电量，可以按如下方式启用：

```java
public class MyGameActivity extends AndroidApplication {
   @Override
   public void onCreate (Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      AndroidApplicationConfiguration config = new AndroidApplicationConfiguration();
      config.useGyroscope = true;
      initialize(new MyGame(), config);
   }
}
```

## 查询可用输入设备
要检查应用程序当前运行的平台是否提供特定输入设备，可以使用 `Input.isPeripheralAvailable()` 方法。

```java
   boolean hardwareKeyboard = Gdx.input.isPeripheralAvailable(Peripheral.HardwareKeyboard);
   boolean multiTouch = Gdx.input.isPeripheralAvailable(Peripheral.MultitouchScreen);
```

其余可用常量请参阅 [Peripheral](https://github.com/libgdx/libgdx/blob/master/gdx/src/com/badlogic/gdx/Input.java#L560) 枚举。

请注意，只有少数 Android 设备配备硬件键盘。即使设备确实有键盘，用户也可能没有将其滑出。在这种情况下，上述方法会返回 false。
