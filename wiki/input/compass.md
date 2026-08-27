---
title: 指南针
---
部分 Android 和 iOS 设备配备集成磁场传感器，可提供设备相对于磁北极的方向信息。

注意：指南针目前在 iOS 设备上不可用，因为 RoboVM 后端尚未实现。iOS 上的 Intel MOE 后端似乎提供了指南针功能。

可以按如下方式查询指南针是否可用：

```java
boolean compassAvail = Gdx.input.isPeripheralAvailable(Peripheral.Compass);
```

确定指南针可用后，可以轮询其状态：

```java
float azimuth = Gdx.input.getAzimuth();
float pitch = Gdx.input.getPitch();
float roll = Gdx.input.getRoll();
```

角度以度为单位。这些值的含义如下：

  * **azimuth** 是设备绕 z 轴的方向角。z 轴正方向指向地心。
  * **pitch** 是设备绕 x 轴的方向角。x 轴正方向大致指向西方，并与 z 轴和 y 轴正交。
  * **roll** 是设备绕 y 轴的方向角。y 轴正方向指向地磁北极，同时与另外两个轴正交。

下图展示了轴相对于地球的方向。

![images/compass.png](/assets/wiki/images/compass.png)
