---
title: 加速度计
---
加速度计测量设备沿三个轴的加速度（至少在 Android 上如此）。通过该加速度可以推导设备的倾斜或方向。

加速度以米每二次方秒（m/s²）为单位。如果某个轴正对地心，其加速度约为 -10 m/s²；如果指向相反方向，加速度则为 10 m/s²。

Android 设备中的轴设置如下：

![images/accelerometer.png](/assets/wiki/images/accelerometer.png)

遗憾的是，平板电脑的配置有所不同。Android 设备有一个称为默认方向的概念。对于手机，竖屏模式（如上图所示）是默认方向；对于平板电脑，横屏模式是默认方向。默认横屏方向的设备会旋转其坐标轴，使 y 轴指向设备较短边的上方，x 轴指向设备较宽边的右方。

libGDX 会处理这一差异，无论设备的默认方向如何，都按上图所示方式提供加速度计读数（z 轴正方向从屏幕向外，x 轴正方向沿设备较宽边向右，y 轴正方向沿设备较短边向上）。

## 检查可用性
不同 Android 设备的硬件配置不同。可以按如下方式检查设备是否有加速度计：

```java
boolean available = Gdx.input.isPeripheralAvailable(Peripheral.Accelerometer);
```

## 查询当前/原生方向
如果游戏需要知道设备当前方向，可以使用以下方法：

```java
int orientation = Gdx.input.getRotation();
```

该方法返回 0、90、180 或 270，表示当前方向与原生方向之间的角度差。

原生方向可以是竖屏模式（如上图所示）或横屏模式（主要用于平板）。可以按如下方式查询：

```java
Orientation nativeOrientation = Gdx.input.getNativeOrientation();
```

它返回 Orientation.Landscape 或 Orientation.Portrait。

## 加速度读数

在 libGDX 中只能通过轮询访问加速度计读数：

```java
    float accelX = Gdx.input.getAccelerometerX();
    float accelY = Gdx.input.getAccelerometerY();
    float accelZ = Gdx.input.getAccelerometerZ();
```

不支持加速度计的平台或设备会返回零。

有关加速度计用法的演示，请参阅 [Super Jumper](https://github.com/libgdx/libgdx-demo-superjumper) 示例游戏。

## 旋转矩阵
如果要使用设备方向进行渲染，使用旋转矩阵可能更有帮助。说明请参阅<a href="https://developer.android.com/reference/android/hardware/SensorManager.html#getRotationMatrix(float[], float[], float[], float[])">此链接</a>。可以将得到的矩阵直接用于 OpenGL 渲染：

```java
Matrix4 matrix = new Matrix4();
Gdx.input.getRotationMatrix(matrix.val);
// use the matrix, Luke
```
