---
title: 陀螺仪
---
部分 Android 设备配备陀螺仪传感器，可提供设备绕 x、y、z 轴的旋转速率（rad/s）。

注意：陀螺仪目前在 iOS 设备上不可用，因为 RoboVM 后端尚未实现。

首先必须在 Android 配置中启用陀螺仪。（通常位于 AndroidLauncher.java 文件中）

```java 
config = new AndroidApplicationConfiguration();
config.useGyroscope = true;  //default is false

//you may want to switch off sensors that are on by default if they are no longer needed.
config.useAccelerometer = false;
config.useCompass = false;
```
可以按如下方式查询陀螺仪是否可用：

```java
boolean gyroscopeAvail = Gdx.input.isPeripheralAvailable(Peripheral.Gyroscope);
```

确定陀螺仪可用后，可以轮询其状态：

```java

if(gyroscopeAvail){
	float gyroX = Gdx.input.getGyroscopeX();
	float gyroY = Gdx.input.getGyroscopeY();
	float gyroZ = Gdx.input.getGyroscopeZ();
} 

```
